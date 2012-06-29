clear all

iflag=0;

  load HYBrx.mat
  i1=[3:6,9:90];
  dum=(pbin(1:90)+pbin(2:91))/2;
  rv1=gv(i1,:);
  pslow1=dum(i1);
  dt1=0.1;

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


