function [ vbest,rbest,hbest ] = GridSearch(rec,tps,dt,pslow)
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


% Grid parameters.
% P-velocity
nv=200;
v1=5;
v2=8;
dv=(v2-v1)/(nv-1);
v=v1:dv:v2;

% Vp/Vs Ratio.
nr=200;
r1=1.6;
r2=1.9;
dr=(r2-r1)/(nr-1);
r=r1:dr:r2;

% Miscellaneous.
p2=pslow.^2;
np=length(pslow);
nt=length(rec);

% Reshape for fast element removal.
gvr=reshape(rec',1,numel(rec));
%gvr = gv(:)';

% Grid search for Vp,R.
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

% Gauge errors and plot results.
figure(23)
    subplot(2,1,1)
    set(gca,'FontName','Helvetica','FontSize',16,'Clipping','off','layer','top');
    imagesc(r,v,stackvr);
    axis xy
    axis square
    colorbar
    hold on

smax=max(max(stackvr));
    disp('best points')
[iv,ir]=find(stackvr == smax);

iv1=iv(1);
ir1=ir(1);
vbest=v(iv1);
rbest=r(ir1);

% Error limits.
%vbest=6.6;
%rbest=1.75;
%vbest=5.8;
%rbest=1.766;

% Error computation after Eaton et al.
f1=sqrt((rbest/vbest)^2-p2);
f2=sqrt((1/vbest)^2-p2);
tpps=(f1+f2)./(f1-f2).*tps;
tpss=2*f1./(f1-f2).*tps;
sterr1=sqrt(var([gvr(round(tpps/dt)+1+[0:np-1]*nt),gvr(round(tpss/dt)+1+[0:np-1]*nt)])/(2*np));

plot(rbest,vbest,'w+')
plot(rbest,vbest,'ko')
contour(r,v,stackvr,[smax-sterr1,smax-sterr1],'k-')

hold off
xlab=xlabel('R');
ylab=ylabel('V_P [km/s]');
set(xlab,'FontName','Helvetica','FontSize',16);
set(ylab,'FontName','Helvetica','FontSize',16);
title(['R = ',num2str(rbest),'  Vp = ',num2str(vbest),' km/s']);

% Line search for H.
nh=200;
h1=25;
h2=50;
dh=(h2-h1)/(nh-1);
h=[h1:dh:h2];

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
stackh=(htps+htpps+htpss)/3;

% Error computation and plot results.
subplot(2,1,2)
set(gca,'FontName','Helvetica','FontSize',16,'Clipping','off','layer','top');
[hmax,ih]=max(stackh);
hbest=h(ih);

tps=hbest*(f1-f2);
tpps=hbest*(f1+f2);
sterr2=sqrt(var([gvr(round(tps/dt)+1+[0:np-1]*nt),...
                 gvr(round(tpps/dt)+1+[0:np-1]*nt),...
                 -gvr(round(tpss/dt)+1+[0:np-1]*nt)])/(3*np));

plot(h,stackh)
hold on
hlim=axis;
plot([hbest,hbest],[hlim(3),hlim(4)],'k')
%plot([hlim(1),hlim(2)],[hmax-sterr2,hmax-sterr2],'k')
hold off
xlab=xlabel('H [km]');
ylab=ylabel('Stack Ampltitude');
set(xlab,'FontName','Helvetica','FontSize',16);
set(ylab,'FontName','Helvetica','FontSize',16);
%title(['H = ',num2str(hbest),' km']);
tlab=text(35,0.6,['H = ',num2str(hbest),' km']);
set(tlab,'FontName','Helvetica','FontSize',16);

figure(29)
f1=hbest*sqrt((rbest/vbest)^2-p2);
f2=hbest*sqrt((1/vbest)^2-p2);
f3=hbest*sqrt((1/vbest)^2-p2);
tps=f1-f2;
tpps=f1+f2;
tpss=2*f1;
csection(rec(:,1:round(22/dt)),0,dt);
hold on
plot(tps,'k+')
plot(tpps,'k+')
plot(tpss,'k+')
hold off



end

