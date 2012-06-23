  function [pcomp,scomp]=freetran(rcomp,zcomp,pslow,a0,b0,iflag)

% function [pcomp,scomp]=freetran(rcomp,zcomp,pslow,a0,b0,iflag)
%
% Function FREETRAN converts radial and vertical component
% displacement seismograms to P and S components assuming
% a given slowness PSLOW, and surface velocities A0, B0.
% (Using 6.06 and 3.5 for A0 and B0)
% If IFLAG < 0, the reverse operation is performed (note
% in this case interchange pcomp/rcomp and scomp/zcomp.

    a02=a0*a0;
    b02=b0*b0;
    p2=pslow*pslow;
    qa=sqrt(1/a02-p2);
    qb=sqrt(1/b02-p2);
    vpz=-(1-2*b02*p2)/(2*a0*qa);
    vpr=pslow*b02/a0;
    vsr=(1-2*b02*p2)/(2*b0*qb);
    vsz=pslow*b0;
    trn=[-vpr,vpz;-vsr,vsz];
    if iflag < 0
       trn=inv(trn);
    end
    dum=trn*[rcomp;zcomp];
    pcomp=dum(1,:);
    scomp=dum(2,:);
