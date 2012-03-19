function plotStack(db)
% PLOTSTACK plots the station structure data db.


figure(23)
  subplot(2,1,1)
    set(gca,'FontName','Helvetica','FontSize',16,...
        'Clipping','off','layer','top');
    imagesc(db.rRange,db.vRange,db.stackvr);
    axis xy
    axis square
    colorbar
    hold on
    plot(db.rbest,db.vbest,'w+')
    plot(db.rbest,db.vbest,'ko')
    contour(db.rRange,db.vRange,db.stackvr,...
        [db.smax-db.stderr1,db.smax-db.stderr1],'k-')
    hold off
    xlab=xlabel('R');
    ylab=ylabel('V_P [km/s]');
    set(xlab,'FontName','Helvetica','FontSize',16);
    set(ylab,'FontName','Helvetica','FontSize',16);
    title(sprintf('R = %1.3f  Vp = %1.3f km/s',db.rbest,db.vbest));

  subplot(2,1,2)
    set(gca,'FontName','Helvetica','FontSize',16,...
    'Clipping','off','layer','top');
    plot(db.hRange,db.stackh)
    hold on
    hlim=axis;
    plot([db.hbest,db.hbest],[hlim(3),hlim(4)],'g')
    plot([hlim(1),hlim(2)],...
        [db.hmax-db.stderr2,db.hmax-db.stderr2],'r')
    hold off
    xlab=xlabel('H [km]');
    ylab=ylabel('Stack Ampltitude');
    set(xlab,'FontName','Helvetica','FontSize',16);
    set(ylab,'FontName','Helvetica','FontSize',16);
    title(sprintf('H = %3.2f km',db.hbest));
    
figure(29)
    csection(db.rec(:,1:round(26/db.dt)),0,db.dt);   
    hold on
    plot(db.tps,'k+')
    plot(db.tpps,'k+')
    plot(db.tpss,'k+')
    hold off
    
end