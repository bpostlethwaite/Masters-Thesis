function csection(seis,beg,dt,aflag,xdist)
% CSECTION(SEIS,BEG,DT,AFLAG,XDIST) plots a color seismogram 
% section of seismograms in 2D array SEIS. BEG is begin time 
% of section, DT is sample interval and AFLAG determines amplitude 
% scaling. If AFLAG < 0 (the default setting if AFLAG not specified)
% each trace is scaled to its maximum amplitude, if  AFLAG = 0 
% each trace is scaled to the maximum amplitude of the
% entire section, and if AFLAG > 0 then each trace is scaled to
% that amplitude (note this option allows direct comparison of 
% plots produced by different calls to SECTION). XDIST is vector
% containing spatial locations. If specified, traces are scaled
% and plotted to represent spatial distribution.
 
ny=size(seis,1);
nt=size(seis,2);
if nargin < 4
  aflag=-1;
end

% Note that pcolor with shading flat chops off the last column for some
% reason so we have to add an additional column to get all data plotted.
xymat=zeros(ny,nt);
if nargin < 5
  xymat=zeros(ny+1,nt);
  xdist=[1:ny+1];
end

% Set colormap.
r1=[(0:31)/31,ones(1,32)];
g1=[(0:31)/31,(31:-1:0)/31];
b1=[ones(1,32),(31:-1:0)/31];
rwb=[r1',g1',b1'];
colormap(rwb);

% Normalize traces as specified.
if aflag < 0
  for iy=1:ny
    xymat(iy,:)=seis(iy,:)/max(abs(seis(iy,:))+0.000000001);
  end
elseif aflag == 0
  for iy=1:ny
    xymat(iy,:)=seis(iy,:)/max(max(abs(seis))+0.000000001);
  end
else
  for iy=1:ny
    xymat(iy,:)=seis(iy,:)/aflag;
  end
end
time=[0:nt-1]*dt+beg;

pcolor(xdist,time,xymat');
shading flat
%image(xdist,time,xymat');

axis('ij');
if aflag > 0
  caxis([-aflag,aflag]);
end
ylab=ylabel('Time [seconds]');
xlab=xlabel('Bin #');
set(gca,'FontName','Helvetica','FontSize',16,'Clipping','off','layer','top');
set(xlab,'FontName','Helvetica','FontSize',16);
set(ylab,'FontName','Helvetica','FontSize',16);
