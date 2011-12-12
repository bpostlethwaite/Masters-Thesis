function [y]=fbpfilt_vec(x,dt,lf,hf,n,type);
% FUNCTION [Y]=FBPFILT(X,DT,LF,HF,N,TYPE);
%  FBPFILT Bandpass Butterworth filter.
%         FBPFILT(X,DT,FC,N,TYPE) takes a time series sampled at DT
%         and filters it with an Nth order butterworth
%         filter with cutoff frequency FC (in Hz). TYPE=0 specifies
%         zero phase filter, TYPE=1 specifies minimum phase.
%

% Parameters
nt=length(x);
nx=min(size(x));
n2=2^ceil(log(nt)/log(2));

% Frequency values.
omega=(0:n2/2)*2*pi/(n2*dt);

% Compute cut-off and center frequencies.
omegac=pi*(hf-lf);
omegam=pi*(lf+hf);

% Amplitude spectrum.
Fl=sqrt(1./(1+((omega-omegam)/omegac).^(2*n)));
Fl(n2/2+2:n2)=Fl(n2/2:-1:2);

% Phase spectrum for minimum phase.
if type == 1

% Check for spectral zeros and substitute with smallest
% square root of possible floating point number to avoid
% taking log of zero when computing log spectrum.
  iz=find(Fl==0);
  Fl(iz)=sqrt(realmin);

  flog=log(Fl);
  lcor=real(ifft(flog,n2));
  lcor(2:n2/2)=lcor(2:n2/2)*2;
  lcor(n2/2+2:n2)=zeros(1,n2/2-1);
  flcor=fft(lcor,n2);
  Fl=exp(flcor);
end

Fl = ones(nx,1)*Fl;

%-- Vectorize
fx = fft(x,n2,2);
temp1 = fx(:,1:n2/2+1).*Fl(:,1:n2/2+1);
fb = [temp1 conj(fliplr(temp1(:,2:n2/2)))];
bb = real(ifft(fb,n2,2));
y = bb(:,1:nt);

return
