function [ vbest, rbest, hbest ] = fastgrid(rec,tps,dt,pslow) %#codegen
%GRIDSEARCH Summary of this function goes here
%
% FUNCTION [vbest,rbest,hbest] = fastgrid(REC,DT,PSLOW,T1,T2);
%
% Same as gridsearch.m but trimmed of unnecessary stuff for speed.
%% Grid parameters.
adjtpps = 0.7;
adjtpss = 0.3;

% P-velocity
nv=200; %num  pvelocity paramters
v1=5;   % Range of v searched
v2=8;
dv=(v2-v1)/(nv-1);
v=v1:dv:v2;

% Vp/Vs Ratio.
nr=200;
r1=1.65;
r2=1.95;
dr=(r2-r1)/(nr-1);
r=r1:dr:r2;

% thickness h
nh=200;
h1=25;
h2=45;
dh=(h2-h1)/(nh-1);
h=[h1:dh:h2];

% Miscellaneous.
p2=pslow.^2;
np=length(pslow);
nt=length(rec);

% Reshape for fast element removal.
gvr = rec'; %rotate
gvr = gvr(:); %vectorize

%% Grid search for Vp,R.
stpps = zeros(nv,nr);
stpss = stpps;
for iv=1:nv
  for ir=1:nr
     f1=sqrt((r(ir)/v(iv))^2-p2);
     f2=sqrt((1/v(iv))^2-p2);
     tpps=(f1+f2)./(f1-f2).*tps;
     tpss=2*f1./(f1-f2).*tps;
     stpps(iv,ir) = mean(gvr(round(tpps/dt)+1+[0:np-1]*nt));
     stpss(iv,ir) = -mean(gvr(round(tpss/dt)+1+[0:np-1]*nt));
  end
end
stackvr=(adjtpps*stpps + adjtpss*stpss);
% Find max values indices
smax=max(max(stackvr));
[iv,ir]=find(stackvr == smax);
vbest=v(iv);
rbest=r(ir);
%% Line search for H.

f1=sqrt((rbest/vbest)^2-p2);
f2=sqrt((1/vbest)^2-p2);
htps = zeros(1,nh);
htpps = htps;
htpss = htps;

for ih=1:nh
  tps=h(ih)*(f1-f2);
  tpps=h(ih)*(f1+f2);
  tpss=h(ih)*2*f1;
  htps(ih)=mean(gvr(round(tps/dt)+1+[0:np-1]*nt));
  htpps(ih)=mean(gvr(round(tpps/dt)+1+[0:np-1]*nt));
  htpss(ih)=-mean(gvr(round(tpss/dt)+1+[0:np-1]*nt));
end

% Find max values indices
stackh = (0.5*htps + 0.3*htpps + 0.2*htpss);

[~,ih]=max(stackh);
hbest=h(ih);


end
