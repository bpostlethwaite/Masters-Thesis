% TEST FILE
%clear all
%close all

%{
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
%plot(X,ynew,X,ysplicenew)



time = t;
% Data vector
x = cos(2*pi*60*time)+sin(2*pi*120*time)+randn(size(time));
d=fdesign.lowpass('N,F3dB',5,20,Fs); %lowpass filter specification object
% Invoke Butterworth design method
Hd=design(d,'butter');
y=filter(Hd,x);

plot(t,x,t,y)
%}

%% L1 Solver Test
%{
t = linspace(0,1,100)';
x = [3,2,1.2]';
e = ones(length(t),1);

A = [e,t,t.^2];

y = A*x;

ybias = [12,22,25,45,70,90];

noise = 0.1*norm(y,'inf')*randn(length(y),1);
yn = y + noise;
yn(ybias) = yn(ybias) + 1 + 2*randn(length(ybias),1);
yn([3,9]) = 10;

%%

xL2 = A\yn;
yL2 = A*xL2;
xL1 = IRLSsolver(A,yn,30,0.001);
yL1 = A*xL1;

fprintf('norm yL2: %f   norm yL1: %f \n',norm(y - yL2), norm(y - yL1))

plot(t,y,'g',t,yn,'k*',t,yL2,'r',t,yL1,'b')
legend('actual curve','data','L2 solution','L1 solution')

%}

%% Math tests
%}

%% JSON testing
%{
opt.FileName = '/media/TerraS/database/test.json';
opt.ForceRootName = 0;

sts = loadjson(opt.FileName);

results = struct('Vp',10,'R',2.3,'H',37.2);

sts.('SADO').results = results;
 
savejson('', sts, opt);
%}

%% Polytope testing
%loadtools;
%mpt_init;
%addpath(genpath([userdir,'/programming/matlab/mpt/']));
%clear all
%close all
%load 3Dpolytopes.mat


%% Tern testing
%{
addpath functions

br = 7.84;
qz = 6.05;
an = 6.35;
vp = 7.0;

[ A, B, C ] = terntransform(an, br, qz, vp, 100);

disp(C)
%}

N = round(40/dt);
fs = 1/dt;
df = fs / N;
N2 = round(N/2);
% calculate unshifted frequency vector
f = (0:(N-1))*df;

close all
for ii = 1:size(brec, 1)
    s = brec(ii, 1:N );
    Fs = fft(s');
    Fs = conj(Fs(1:N2)) .* Fs(1:N2);
    Fs = Fs / max(Fs); 
    f = f(1:N2);
    
    subplot(2,1,1)
    plot(brec(ii, 1:N))
    
    subplot(2,1,2)
    plot(f, Fs)


    imp = sum(Fs( f < 2 )) / sum(Fs);
    
    title(sprintf('impulsivness = %2.4f', imp))
    
    pause
end
% 
% for ii = 1:size(ptrace, 1)
%     plot(ptrace(ii,2000:4000))
%     hold on
%     plot(stack(ii, 2000:4000), 'r')
%     pause
%     clf
% end