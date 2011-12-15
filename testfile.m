% TEST FILE
clear all
close all

dt = 0.001;
Fs = 1/dt;
L = 1000;
t = [0:L-1] * dt;

p = nextpow2(length(t));
NFFT = 2^p;

%f = Fs/2*linspace(0,1,NFFT/2+1);
f = Fs*linspace(0,1,NFFT);



y = sin(t);
for n = 2:10;
    w = 10*n*Fs
    y = y + sin(w*t);
end



Y = (fft(y,NFFT));
Ycut = Y(1:NFFT/2 + 1);
Yjoin = [Ycut,conj(Ycut(end-1:-1:2))];
ynew = real(ifft(Y));
ysplicenew = real(ifft(Yjoin));

X = 1:length(ynew);
figure(80)
%plot(f,abs(Y),f,abs(Yjoin))
plot(X,ynew,X,ysplicenew)


