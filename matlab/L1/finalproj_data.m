% Wavelet Deconvolution 
% Data application file 
clear all; close all
userdir = getenv('HOME');
f = fullfile(userdir, 'programming','matlab'); %Set base path
snr = @(x,y)20*log10(norm(x(:))/norm(x(:)-y(:)));
addpath(genpath([f,'/spotbox-v1.0/+spot/+rwt'])) %Path to rice toolbox
addpath(genpath([f,'/spgl1'])) %Path to L1 solver
addpath(genpath([f,'/spotbox-v1.0/Splines'])) %Path to rice toolbox
load('D1.mat')
for ii = 1:36
   u = cell2mat(D1{ii}{1});
   s = cell2mat(D1{ii}{2});
   pslow(ii) = cell2mat(D1{ii}{3});
   % 
   %% Reshape
   s = s';
   u = u';

   %% Build spot operators
   dim = size(s,2);
   n = size(s,1);
   e = opOnes(dim,1);
   f = opDFT(n);
   % Extend DFT operator for multiple source / traces
   F = kron(opEye(dim),f); % 
   F2 = kron(ones(size(s,2),1),f);
   Ft = kron(opEye(dim),f'); % Transpose scaled operator
   Fs = opDiag(F*s(:));
   %w = opWavelet(n,1,'Daubechies',8,5,true,'min');
   w = opSplineWavelet(n,1,128,3,5,'*ortho');
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
   opts = spgSetParms('verbosity',1,'iterations',1);         % Turn on the SPGL1 log output
   x = spgl1(A,u(:),0,sigma,[],opts);
   xrec = w'*x;
   xrec = xrec/max(xrec);
   %
 
   %% Run Michael's Simdecf 
   sft = fft(s);
   uft = fft(u);
   [rft, xft, betax] = simdecf(sft',uft',-1.0);
   crec = real(ifft(rft));
   crec = crec/max(crec);
   %

   %% Plot 
   % 
   figure(ii)
   subplot(2,1,1)
   plot(xrec,'b--')
   title('Wavelet Deconvolution')
   subplot(2,1,2)
   plot(crec(end:-1:1),'r--')
   title('Simultaneus Deconvolution')
   CREC(ii,:) = crec(end:-1:1); 
   REC(ii,:) = xrec;
end	
