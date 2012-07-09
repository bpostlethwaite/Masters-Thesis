% Final Project for Wavelet class

clear all; close all
%userdir = getenv('HOME');
%f = fullfile(userdir, 'programming','matlab'); %Set base path
%getd = @(p)path(p,path);  %easy path function
%getd([f,'/spotbox-v1.0/']); %Path to spot box
addpath('/home/gmatharu/EOSC513/packages/spotbox-v1.0');
snr = @(x,y)20*log10(norm(x(:))/norm(x(:)-y(:)));
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
delta = .1;
noise = randn(N,1)*delta;
sigma=norm(noise);

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
C = Ft*Fs*F2;
y = C*rec;
y = y/max(y) + noise;
%% Michaels simdecf.
%
wft = fft(s);
vft = fft(reshape(y,size(s)));
[rft,xft,betax] = simdecf(wft',vft',-1,0);
crec = real(ifft(rft));
crec = crec/max(crec);


cases = 3;
D1 = cell(cases,1);
for i = 1:cases;
   D1{i} = cell(2,1);
end
for ii = 1:3
   if ii ==1 
      w = opWavelet(n,1,'Haar',8,5,true,'min');
   else if ii  == 2 
      w = opWavelet(n,1,'Daubechies',8,5,true,'min');
   else    
      w = opSplineWavelet(n,1,128,3,5,'*ortho'); 
     %w = opDirac(n);
     %W = kron(e,w); % kron out wavelet operator
   end    
   end
   Wt = kron(e,w'); % Inverse transform and kron out wavelet operator
   %C = Ft*Fs*F2;
   A = Ft*Fs*F*Wt;
   %y = C*rec;
   %y = y/max(y) + noise;


   %% dottest

   %q = randn(n,1);
   %p = randn(N,1);

   %qp = p'*(A*q);
   %pq = (A'*p)'*q;
   %fprintf('dottest gives %f\n', pq - qp)
   %}
   %% Michaels simdecf.
   %
   %wft = fft(s);
   %vft = fft(reshape(y,size(s)));
   %[rft,xft,betax] = simdecf(wft',vft',-1,0);
   %crec = real(ifft(rft));
   %crec = crec/max(crec);

%% SPGL1
%
   addpath /home/gmatharu/EOSC513/packages/SPGL1/spgl1-1.7
   %addpath /home/bpostlet/programming/matlab/spgl1
   %addpath /home/bpostlet/programming/matlab/spgl1/private
   opts = spgSetParms('verbosity',1);         % Turn on the SPGL1 log output
   opts = spgSetParms('iterations',500);         % Turn on the SPGL1 log output
   %x = spg_bpdn(A, y,sigma,opts);
   % Solve for x with either first guess or no guess.
   %x = spgl1(A,y,0,sigma,[],opts);
   x = spgl1(A,y,0,sigma,w*crec',opts);
   xrec = w'*x;
   %}
   %% Plot
   %
   figure(ii)
       subplot(3,1,1)
       plot(rec,'k')
       title('Receiver function')
       subplot(3,1,2)
       plot(xrec/max(xrec),'b--')
       title(strcat(['Wavelet Deconvolution' num2str(snr(rec,xrec)) 'dB']));
       subplot(3,1,3)
       plot(crec(end:-1:1),'r--')
       title(strcat(['Simultaneus Deconvolution' num2str(snr(rec,crec)) 'dB']));
   %}
   D1{ii}{1} = xrec; 
   D1{ii}{2} = crec;
end


