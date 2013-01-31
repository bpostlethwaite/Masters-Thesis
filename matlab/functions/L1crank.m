function [xrec] = L1crank(pcomp,scomp,xwarm,iters)

%% Reshape
s = pcomp';
u = scomp';
xwarm = xwarm(:);
%% Build spot operators
dim = size(s,2);
n = size(s,1);
e = opOnes(dim,1);
f = opDFT(n);
% Extend DFT operator for multiple source / traces
F = kron(opEye(dim),f); %
%F2 = kron(ones(size(s,2),1),f);
Ft = kron(opEye(dim),f'); % Transpose scaled operator
Fs = opDiag(F*s(:));
%w = opWavelet(n,1,'Daubechies',8,5,true,'min');
w = opSplineWavelet(n,1,128,3,5,'*bspline');
Wt = kron(e,w'); %
A = Ft*Fs*F*Wt;
%

%% Estimate noise
sigma = 0;
for jj = 1:dim
    sigma = sigma + norm(u(1:20/0.025,jj));
end
sigma = sigma/dim;
%

%% Run SPGL1
opts = spgSetParms('verbosity',0,'iterations', iters);  % Turn on the SPGL1 log output
x = spgl1(A, u(:), 0, sigma, xwarm, opts);
xrec = w'*x;
xrec = xrec/max(xrec);