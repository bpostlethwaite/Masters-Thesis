clear all
close all

iflag=0;

addpath('../sac')
addpath('../Data')
addpath('../Functions')

if iflag == 0
  load HYBrx.mat
  i1=[3:6,9:11,13:89];
%  i1=[1:size(gv,1)];
  pavg=(pbin(1:90)+pbin(2:91))/2;
  rv=gv(i1,:);
  pslow=pavg(i1);
  dt=0.1;
else

% Load PKP data.
  load rvpkp
  dum1=squeeze(rv);
  load avslopkp
  duma=avslo;
  i1=[21,24:27,29,32:34,36:38,66:69,71:74,76];

% Load P data
  load rvpap.mat
  dum2=rv;
  load slopap.mat
  dumb=avslo;
  i2=[1:4,6:90];

% Remove dead traces and compile.
% Both P and PKP.
  rv=[dum1(i1,:);dum2(i2,:)];
  pslow=[duma(i1),dumb(i2)];
%PKP alone.
%  rv=[dum1(i1,:)];
%  pslow=[duma(i1)];
  dt=0.05;
end



% Filter NB - I PRODUCED THE TIMING ESTIMATES 
% FROM DATA FILTERED AS BELOW
brv=fbpfilt(rv,dt,0.03,3.0,2,0);
for iv=1:size(brv,1);
   brv(iv,:)=brv(iv,:)/max(abs(brv(iv,1:100)));
   brv(iv,:)=brv(iv,:)/pslow(iv)^.2;
end

for ii = 1:size(brv,1)
    plot(brv(ii,:))
    pause(1)
end

% Grid search. 
[vbest,rbest,hbest]=crust(brv,dt,pslow,3.7,4.2);

% Now pick times from window.
p2=pslow.*pslow;
f1=hbest*sqrt((rbest/vbest)^2-p2);
f2=hbest*sqrt((1/vbest)^2-p2);
f3=hbest*sqrt((1/vbest)^2-p2);
tps0=f1-f2;
tpps0=f1+f2;
tpss0=2*f1;

for iv=1:size(brv,1)
   [dum,it]=max(brv(iv,round((tps0(iv)-0.5)/dt)+1:round((tps0(iv)+0.5)/dt)+1)');
    tps(iv)=(it+round((tps0(iv)-0.5)/dt)-1)*dt;
   
   [dum,it]=max(brv(iv,round((tpps0(iv)-0.5)/dt)+1:round((tpps0(iv)+0.7)/dt)+1)');
   tpps(iv)=(it+round((tpps0(iv)-0.5)/dt)-1)*dt;

   [dum,it]=min(brv(iv,round((tpss0(iv)-0.7)/dt)+1:round((tpss0(iv)+0.7)/dt)+1)');
   tpss(iv)=(it+round((tpss0(iv)-0.7)/dt)-1)*dt;
end

%csection(brv(:,1:round(22/dt)),0,dt);

%hold on
%plot(tps,'k+')
%plot(tpps,'k+')
%plot(tpss,'k+')
%hold off
%avslo=pslow;
%
%save timesppkp_new tps tpps tpss avslo

