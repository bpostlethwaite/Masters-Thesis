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
%{
n = 10;
t = 4 + randn(n,1);
p = linspace(0.03,0.08,n)';
h = 30;
b = 3.5;
a = 6;
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



 if loadflag
    t1 = db.t1; 
    t2 = db.t2;
else
    t1 = 2.0;
    t2 = 6.5;
end
adjbounds = true;
t1n = ' ';
t2n = ' ';
while adjbounds 
    [~,it] = max(brec(:,round(t1/dt) + 1: round(t2/dt)) + 1,[],2);
    tps = (it + round(t1/dt)-1)*dt;
    h = figure(3311);
        plot(1:length(tps),tps,'*')
        title('Check bounds and tighten and adjust accordingly')
    t1n = input('Enter a new lower bound or "y" to accept or "b" to enter banish mode: ', 's');
    if str2num(t1n) % Check if input is a number
        t1 = str2num(t1n); % If it is use number as lower bound
        t2n = input('Enter a new higher bound or "y" to accept or "b" to enter banish mode: ', 's');
        if str2num(t2n) % Check if 2nd input is a number
            t2 = str2num(t2n); %#ok<*ST2NM> % If it is use num as upper bound
        end
        
    elseif (t1n == 'y') || (t2n == 'y') % If user enters 'y' move on
        adjbounds = false; % break loop
    
    elseif (t1n == 'b') || (t2n == 'b') % If user enters 'b' enter banish mode
        banish = true;
        b1 = t1;
        b2 = t2;
        
        while banish %Stay in banish mode till we get a 'y' or a 'b'
            h = figure(3311);
                hold off
                plot(1:length(tps),tps,'*')
                %plot(1:length(tps), b1, ':r')
                hold on
                title('Enter bounds all traces outside bounds will be removed')
            t1n = input('Enter a new lower bound or "y" to accept or "b" to LEAVE banish mode: ', 's');
            if str2num(t1n) % Check if input is a number
            b1 = str2num(t1n); % If it is use number as lower bound
            plot(1:length(tps), b1, ':r')
            t2n = input('Enter a new higher bound or "y" to accept or "b" to LEAVE banish mode: ', 's');
                if str2num(t2n) % Check if 2nd input is a number
                    b2 = str2num(t2n); % If it is use num as upper bound
                    plot(1:length(tps), b2, ':r')
                end
                
            elseif (t1n == 'y') || (t2n == 'y')
                % If select yes, kill all RFs outside range
                ind = (tps < b1) | (tps > b2);
                tps(ind) = [];
                pslow(ind) = [];
                brec(ind,:) = [];
                banish = false;
                
            elseif (t1n == 'b') || (t2n == 'b')
                banish = false;
            
            else
                fprintf('Sorry %s or %s is bad input', t1n, t2n) 
            end
        end
        
    else
        fprintf('Sorry %s or %s is bad input', t1n, t2n) 
    end
            
end

