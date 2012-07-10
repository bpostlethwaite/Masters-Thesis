%% Ben Postlethwaite 76676063
% Wavelet Seismic Test
%%
clear all; close all;
loadtools;   % Load wavelet toolboxes

% First, Generate seismic traces.
% Import ULM.mat:
load('/home/bpostlet/programming/matlab/thesis/data/ULM.mat')
adj = 0.2;
[atoms sigt] = window(ptrace,strace,header,adj);
%{
for ii = 1:size(atoms,2)
    figure(12345)
    plot(atoms(:,ii))
    pause(0.05)
end
%}


% dimension of the signal
n = length(atoms);

h = atoms(:,1);
h = h-mean(h);
% normalize it
h = h/norm(h);
% recenter the filter for periodic boundary conditions
h1 = fftshift(h);
%We compute the filtering matrix. To stabilize the recovery, we sub-sample by a factor of 2 the filtering.
% sub-sampling (distance between wavelets)
sub = 1;
% number of atoms in the dictionary
p = n/sub;
% the dictionary, with periodic boundary conditions
[Y,X] = meshgrid(1:sub:n,1:n);
%D = reshape( h1(mod(X-Y,n)+1), [n p]);
%We generate a sparse signal to recover.
% spacing min and max between the spikes.
mesh(D)

%{



m = 5; M = 40;
k = floor( (p+M)*2/(M+m) )-1;
spc = linspace(M,m,k)';
% location of the spikes
sel = round( cumsum(spc) );
sel(sel>p) = [];
% randomization of the signs and values
x = zeros(p,1);
si = (-1).^(1:length(sel))'; si = si(randperm(length(si)));
% creating of the sparse spikes signal.
x(sel) = si;
x = x .* (1-rand(p,1)*.5);
% sparsity of the solution
M = sum(x~=0);
%Now we perform the measurements.
% noise level
sigma = .06*max(h);
% noise
w = randn(n,1)*sigma;
% measures
y = D*x + w;
xbp = zeros(p,1);

for ii = 1:round(2*M)
    % compute the correlation with the residual
    C = D'*(y-D*xbp);
    lambda = max(abs(C));
    % Vectors to track lambda and sparsity
    lambdaV(ii) = lambda;
    sparsityV(ii) = sum(abs(xbp) > 0);
    % find the locations that maximally correlates
    S = find( abs(abs(C/lambda)-1)<1e-9);
    % compute the complementary set
    I = ones(p,1); I(S)=0;
    Sc = find(I);    
    %The direction of descent d(S) on S is computed so that its image by 
    %D(:,S)*d(S) correlates as +1 or -1 with the atoms in S (same speed on 
    %all the coefficients). It is zero outside S.
    d = zeros(p,1);
    d(S) = (D(:,S)'*D(:,S)) \ sign( C(S) );
    
    % Now we compute the value gamma so that either
    % 1) xbp + gamma*d correlates as much as lambda with one atom outside S.
    % 2) xbp + gamma*d correlates as much as -lambda with one atom outside S.
    % 3) one of the coordinates xbp + gamma*d in S becomes 0.
    % In situations 1) and 2), the number of non-zero coordinates of xbp 
    % (its sparsity) increases by 1. In situation 3), its sparsity stays 
    % constant because one coefficients appears and another deasapears.
    v = D(:,S)*d(S);
    %Compute minimum gamma so that situation 1) is in force.
    w = ( lambda-C(Sc) ) ./ ( 1 - D(:,Sc)'*v );
    gamma1 = min(w(w>0));
    %Compute minimum gamma so that situation 2) is in force
    w = ( lambda+C(Sc) ) ./ ( 1 + D(:,Sc)'*v );
    gamma2 = min(w(w>0));
    % Compute minimum gamma so that situation 3) is in force.
    w = -xbp(S)./d(S);
    gamma3 = min(w(w>0));
    % Compute minimum gamma so that 1), 2) or 3) is in force, and update 
    % the solution.
    gamma = min([gamma1 gamma2 gamma3]);
    
    % To compensate coeff underestimates by L1 we use back projection (L2)
    % find the support
    sel = find(xbp~=0);
    % perform the fit
    xproj(:,ii) = zeros(p,1);
    xproj(sel,ii) = D(:,sel) \ y;
    err(ii) = norm(x-xproj(:,ii));
    % Update
    xbp = xbp + gamma*d;
end
figure(3456)
plot(lambdaV,sparsityV,'.-'); axis tight
xlabel('Lambda'); ylabel('sparsity')
figure(123)
subplot(2,1,1);
plot_sparse_diracs(x);
title('Signal x');
subplot(2,1,2);
plot_sparse_diracs(xbp);
title('Recovered by L1 minimization');

%% Exercise 2: Sparse Spikes Deconvolution with L1 Pursuit

xproj = xproj(:,find(err==min(err),1));
lambda_opt = lambdaV(err==min(err));
% display
err_bp = norm(x-xproj)/norm(x);
figure(56434)
subplot(2,1,1);
plot_sparse_diracs(x);
title('Signal x');
subplot(2,1,2);
plot_sparse_diracs(xproj);
title( strcat(['L1 recovery, error = ' num2str(err_bp, 3)]));

%% Exercise 3: Sparse Spikes Deconvolution with L1 Pursuit

% We use the optimal value of lambda already computed. 
% We also save the true solution computed by homotopy.
lambda = lambda_opt;
xbp_opt = xbp;
%The gradient descent step size depends on the conditionning of the matrix.
tau = 2/norm(D).^2;
%The iterative algorithm starts with the zero vector.
xbp = zeros(p,1);
iter = 140;

for ii = 1:iter;
%The gradient step updates the value of the solution by decaying the 
%value of norm(y-D*xbp)^2.
xbp = xbp + tau*D'*( y-D*xbp );
%The thresholding step improves the sparsity of the solution.
xbp_prev = xbp;
xbp = perform_thresholding( xbp, tau*lambda, 'soft' );
energyV(ii) = norm(y-D*xbp)^2;
solnErr(ii) = log10(norm(xbp - x));

end
% display
figure(3464)
subplot(2,1,1)
plot(2:iter,energyV(2:end))
set_graphic_sizes([], 20);
xlabel('iter'); ylabel('energy')
axis tight
subplot(2,1,2)
plot(2:iter,solnErr(2:end))
set_graphic_sizes([], 20);
xlabel('iter'); ylabel('Solution Distance')
axis tight

%}