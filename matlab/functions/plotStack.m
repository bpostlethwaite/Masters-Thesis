function plotStack(db, method)
% PLOTSTACK plots the station structure data db.

% Some Linux Java bugfix voodoo
set(0, 'DefaultFigureRendererMode', 'manual')
set(0,'DefaultFigureRenderer','zbuffer')

startsec = 0;

hfig = figure(23);
pos = get(hfig,'OuterPosition');
pos1 = pos; % save backup for next window
    
if strcmp(method,'bostock')

    pos(4) = pos(4) * 2; % Increase height by 2
    pos(2) = floor(pos(2) / 4); % Lower the figure so it fits in window
    set(hfig,'OuterPosition', pos)
      subplot(2,1,1)
        set(gca,'FontName','Helvetica','FontSize',16,...
            'Clipping','off','layer','top');
        imagesc(db.mb.rRange,db.mb.vRange,db.mb.stackvr);
        axis xy
        axis square
        colorbar
        hold on
        plot(db.mb.rbest, db.mb.vbest, 'w+')
        plot(db.mb.rbest, db.mb.vbest, 'ko')
        contour(db.mb.rRange,db.mb.vRange,db.mb.stackvr,...
            [db.mb.smax - db.mb.stdsmax, db.mb.smax - db.mb.stdsmax], 'k-')
        hold off
        xlab=xlabel('R');
        ylab=ylabel('V_P [km/s]');
        set(xlab,'FontName','Helvetica','FontSize',16);
        set(ylab,'FontName','Helvetica','FontSize',16);
        title(sprintf('%s\nVp = %1.3f +/- %1.3f km/s\nR = %1.3f +/- %1.3f',...
            db.station, db.mb.vbest, db.mb.stdVp, db.mb.rbest, db.mb.stdR));

      subplot(2,1,2)
        set(gca,'FontName','Helvetica','FontSize',16,...
            'Clipping','off','layer','top');
        plot(db.mb.hRange,db.mb.stackh)
        hold on
        hlim=axis;
        plot([db.mb.hbest,db.mb.hbest],[hlim(3),hlim(4)],'g')
        plot([hlim(1),hlim(2)],...
            [db.mb.hmax - db.mb.stdhmax, db.mb.hmax - db.mb.stdhmax],'r')
        hold off
        xlab=xlabel('H [km]');
        ylab=ylabel('Stack Ampltitude');
        set(xlab,'FontName','Helvetica','FontSize',16);
        set(ylab,'FontName','Helvetica','FontSize',16);
        title(sprintf('H = %3.2f +/- %1.3f km',db.mb.hbest, db.mb.stdH));

       hfig = figure(29);
        pos1(1) = floor(pos(1)/4);
        set(hfig,'OuterPosition',pos1)
        csection(db.rec(:, 1 : round(26/db.dt)), startsec, db.dt);
        hold on
        plot(db.mb.tps,'k+')
        plot(db.mb.tpps,'k+')
        plot(db.mb.tpss,'k+')
        title(sprintf('%s', db.station) )
        hold off

        
elseif strcmp(method,'kanamori')

        set(gca,'FontName','Helvetica','FontSize',16,...
            'Clipping','off','layer','top');
        imagesc(db.hk.hRange, db.hk.rRange, db.hk.stackhr);
        axis xy
        axis square
        colorbar
        hold on
        plot(db.hk.hbest, db.hk.rbest,'w+')
        plot(db.hk.hbest, db.hk.rbest,'ko')
        contour(db.hk.hRange, db.hk.rRange, db.hk.stackhr,...
            [db.hk.smax - db.hk.stdsmax, db.hk.smax - db.hk.stdsmax], 'k-')
        hold off
        xlab=xlabel('H [km]');
        ylab=ylabel('R [Vp/Vs]');
        set(xlab,'FontName','Helvetica','FontSize',16);
        set(ylab,'FontName','Helvetica','FontSize',16);
        title(sprintf('%s\nH = %1.3f +/- %1.3f km/s\nR = %1.3f +/- %1.3f',...
            db.station, db.hk.hbest, db.hk.stdH, db.hk.rbest, db.hk.stdR));
     

        hfig = figure(29);
        pos1(1) = floor(pos(1)/4);
        set(hfig,'OuterPosition',pos1)
        csection(db.rec(:, 1 : round(26/db.dt)), startsec,db.dt);
        hold on
        plot(db.hk.tps,'k+')
        plot(db.hk.tpps,'k+')
        plot(db.hk.tpss,'k+')
        title(sprintf('%s',db.station) )
        hold off
end