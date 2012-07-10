% Final Project for Wavelet class

clear all; close all
userdir = getenv('HOME');
f = fullfile(userdir, 'programming','matlab'); %Set base path
getd = @(p)path(p,path);  %easy path function
getd([f,'/spotbox-v1.0/']); %Path to spot box
%addpath(genpath([f,'/CurveLab-2.1.3'])) %Path to curvelet toolbox
%addpath(genpath([f,'/spotbox-v1.0/+spot/+rwt'])) %Path to rice toolbox
%loadtools;  
load('source.mat'); % Load p-coda array
%s = s(:,1); % Trim to 1 seismic source for testing
n = size(s,1);
N = length(s(:));
% Create reciever function
rec = zeros(n,1);
rec(round(n/16)) = 1;
rec(round(n*(7/16))) = -0.25;
rec(round(n*(8/16))) = 0.4;

% Noise Gaussian
sigma = .80;
noise = randn(N,1)*sigma;

% Noise Jitter, replace diracs with gaussians in rec function
%{
ind = find(rec);
gx = zeros(n,1);
tx = (1:n)';
for ii = 1:length(ind)
    a = rec(ind(ii)); % Amplitude of first spike
    b = ind(ii);      % Location of first spike
    c = 3;
    if ii ~= 1
        c = 3*c;
    end
    gx = gx + a*exp(- ((tx - b).^2)/(2*c^2));
end
%}
%rec = gx; % Use jittered receiver function

% Convolve using spot operators to generate noisy signal y
% A = Fadj*diag(F*s)*F   y = Ax + gaussian noise
%si = sin([1:n]*pi*0.01)'; % Practise signal

dim = size(s,2);
e = opOnes(dim,1);
f = opDFT(n);
% Extend DFT operator for multiple source / traces
F = kron(opEye(dim),f); % 
F2 = kron(ones(size(s,2),1),f);
Ft = kron(opEye(dim),f'); % Transpose scaled operator
Fs = opDiag(F*s(:));
w = opWavelet(n,1,'Daubechies',8,0,true,'min');
%w = opWavelet(n,1);
%W = kron(e,w); % kron out wavelet operator
Wt = kron(e,w'); % Inverse transform and kron out wavelet operator



C = Ft*Fs*F2;

A = Ft*Fs*F*Wt;
y = C*rec;
y = y/max(y) + noise;

%% dottest
%{
q = randn(n,1);
p = randn(N,1);

qp = p'*(A*q);
pq = (A'*p)'*q;
fprintf('dottest gives %f\n', pq - qp)
%}
%% Michaels simdecf.
%
wft = fft(s);
vft = fft(reshape(y,size(s)));
[rft,xft,betax] = simdecf(wft',vft',-1,0);
crec = real(ifft(rft));
crec = crec/max(crec);
%}


%% Wavelet threshold algorithm
%{
options.ti = 1; %  Translation invariant wavelet transform
Jmin = 4;
nsteps = 50;
tau = 0.05;
lambda = 0.1;
%x = y(1:n);
x = crec';
scond = 100;
itermax = 80;
iter = 0;
% Curvelet options
%{
%options.null = 0;
options.finest = 0;
options.nbscales = 2;
options.nbangles_coarse = 8;
options.is_real = 1;
options.n = 1;
%}

while scond > 0.001 && iter < itermax
xprev = x;    
x = x - tau*A'*(A*x - y);
%xW = perform_wavelet_transf(x,Jmin,+1,options);
%xWT = perform_thresholding(xW,lambda*tau,'soft');
x = perform_thresholding(x,lambda*tau,'soft');
%J = size(xW,3)-2;   
%x = perform_wavelet_transf(xWT,Jmin,-1,options);
scond = norm(x - xprev);
iter = iter + 1;
figure(23456)
    plot(x,'b--')
    title(sprintf('Simultaneus Deconvolution - ||x-xprev|| = %1.4f',scond))
end

x = x/max(x);
%}

%% SPGL1
%
addpath /home/bpostlet/programming/matlab/spgl1
%addpath /home/bpostlet/programming/matlab/spgl1/private
opts = spgSetParms('verbosity',1);         % Turn on the SPGL1 log output
opts = spgSetParms('iterations',25);         % Turn on the SPGL1 log output
x = spg_bpdn(A, y,sigma,opts);
x = x/max(x);
%}
%% Plot
%
figure(23456)
    subplot(3,1,1)
    plot(rec,'k')
    title('Receiver function')
    subplot(3,1,2)
    plot(x,'b--')
    title('Wavelet Deconvolution')
    subplot(3,1,3)
    plot(crec(end:-1:1),'r--')
    title('Simultaneus Deconvolution')
%}



