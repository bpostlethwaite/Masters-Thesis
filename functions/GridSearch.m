function [ results ] = GridSearch(rec,tps,dt,pslow)
%GRIDSEARCH Summary of this function goes here
%   
% FUNCTION [vbest,rbest,hbest] = GRIDSEARCH(REC,DT,PSLOW,T1,T2);
%
% Function computes best homogeneous crustal model for 
% a suite of receiver functions REC of dimensions NTRACE
% by NTIMES, given the sample interval DT, the corresponding
% slownesses PSLOW (of dimension NTRACE) and a window 
% defined by T1 and T2. This window is specified by user
% to encompass timing of direct Ps conversion from Moho 
% as tightly as possible. Times TPS for conversion are picked
% as location of maxima for traces within this window.
%
% Output parameters are estimate bulk P-velocity VBEST,
% Vp/Vs ratio RBEST and crustal thickness HBEST.

% First find arrival of direct conversions.
% Find timing of direct conversion.


%% Grid parameters.
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
h2=50;
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
for iv=1:nv
  for ir=1:nr
     f1=sqrt((r(ir)/v(iv))^2-p2);
     f2=sqrt((1/v(iv))^2-p2);
     tpps=(f1+f2)./(f1-f2).*tps;
     tpss=2*f1./(f1-f2).*tps;
     stpps(iv,ir)=mean(gvr(round(tpps/dt)+1+[0:np-1]*nt));
     stpss(iv,ir)=-mean(gvr(round(tpss/dt)+1+[0:np-1]*nt));
  end
end
stackvr=(stpps+stpss)/2;

% Find max values indices
smax=max(max(stackvr));
[iv,ir]=find(stackvr == smax);
vbest=v(iv);
rbest=r(ir);

%% Line search for H.

f1=sqrt((rbest/vbest)^2-p2);
f2=sqrt((1/vbest)^2-p2);
for ih=1:nh
  tps=h(ih)*(f1-f2);
  tpps=h(ih)*(f1+f2);
  tpss=h(ih)*2*f1;
  htps(ih)=mean(gvr(round(tps/dt)+1+[0:np-1]*nt));
  htpps(ih)=mean(gvr(round(tpps/dt)+1+[0:np-1]*nt));
  htpss(ih)=-mean(gvr(round(tpss/dt)+1+[0:np-1]*nt));
end

% Find max values indices
stackh=(htps+htpps+htpss)/3;
[hmax,ih]=max(stackh);
hbest=h(ih);

%% Results & Errors
% See Paper by Eaton et al.
tps = hbest*(f1-f2);
tpps = hbest*(f1+f2);
tpss = 2*hbest*f1;
sterr1=sqrt( mean(var([gvr(round(tpps/dt)+1+[0:np-1]*nt),...
    gvr(round(tpss/dt)+1+[0:np-1]*nt)])/(2*np)));

sterr2 = sqrt(mean(var([gvr(round(tps/dt)+1+[0:np-1]*nt),...
                 gvr(round(tpps/dt)+1+[0:np-1]*nt),...
                 -gvr(round(tpss/dt)+1+[0:np-1]*nt)])/(3*np)));

%% Plots Results
%{
figure(23)
  subplot(2,1,1)
    set(gca,'FontName','Helvetica','FontSize',16,...
        'Clipping','off','layer','top');
    imagesc(r,v,stackvr);
    axis xy
    axis square
    colorbar
    hold on
    plot(rbest,vbest,'w+')
    plot(rbest,vbest,'ko')
    contour(r,v,stackvr,[smax-sterr1,smax-sterr1],'k-')
    hold off
    xlab=xlabel('R');
    ylab=ylabel('V_P [km/s]');
    set(xlab,'FontName','Helvetica','FontSize',16);
    set(ylab,'FontName','Helvetica','FontSize',16);
    title(sprintf('R = %1.3f  Vp = %1.3f km/s',rbest,vbest));

  subplot(2,1,2)
    set(gca,'FontName','Helvetica','FontSize',16,...
    'Clipping','off','layer','top');
    plot(h,stackh)
    hold on
    hlim=axis;
    plot([hbest,hbest],[hlim(3),hlim(4)],'g')
    plot([hlim(1),hlim(2)],[hmax-sterr2,hmax-sterr2],'r')
    hold off
    xlab=xlabel('H [km]');
    ylab=ylabel('Stack Ampltitude');
    set(xlab,'FontName','Helvetica','FontSize',16);
    set(ylab,'FontName','Helvetica','FontSize',16);
    title(sprintf('H = %3.2f km',hbest));
    
figure(29)
    csection(rec(:,1:round(26/dt)),0,dt);   
    hold on
    plot(tps,'k+')
    plot(tpps,'k+')
    plot(tpss,'k+')
    hold off

%}
%% Pack results into struct  
results.method = 'bostock';
results.rbest = rbest;
results.vbest = vbest;
results.hbest = hbest;
results.stackvr = stackvr;
results.stackh = stackh;
results.rRange = r;
results.vRange = v;
results.hRange = h;
results.stderr1 = sterr1;
results.stderr2 = sterr2;
results.smax = smax;
results.hmax = hmax;
results.tps = tps;
results.tpps = tpps;
results.tpss = tpss;

end




