function plotStack(db)
% PLOTSTACK plots the station structure data db.

type = 1;
if isfield(db,'method')
    if strcmp(db.method,'kanamori')
        type = 0;
    end
end

if type
    hfig = figure(23);
    pos = get(hfig,'OuterPosition');
    pos1 = pos; % save backup for next window
    pos(4) = pos(4) * 2; % Increase height by 2
    pos(2) = floor(pos(2) / 4); % Lower the figure so it fits in window
    set(hfig,'OuterPosition', pos)
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
            [db.smax - std(db.bootVpRx), db.smax - std(db.bootVpRx)],'k-')
        hold off
        xlab=xlabel('R');
        ylab=ylabel('V_P [km/s]');
        set(xlab,'FontName','Helvetica','FontSize',16);
        set(ylab,'FontName','Helvetica','FontSize',16);
        title(sprintf('%s\nVp = %1.3f +/- %1.3f km/s\nR = %1.3f +/- %1.3f',...
            db.station, db.vbest, db.stdVp, db.rbest, db.stdR));
    
      subplot(2,1,2)
        set(gca,'FontName','Helvetica','FontSize',16,...
            'Clipping','off','layer','top');
        plot(db.hRange,db.stackh)
        hold on
        hlim=axis;
        plot([db.hbest,db.hbest],[hlim(3),hlim(4)],'g')
        plot([hlim(1),hlim(2)],...
            [db.hmax - std(db.bootHx), db.hmax - std(db.bootHx)],'r')
        hold off
        xlab=xlabel('H [km]');
        ylab=ylabel('Stack Ampltitude');
        set(xlab,'FontName','Helvetica','FontSize',16);
        set(ylab,'FontName','Helvetica','FontSize',16);
        title(sprintf('H = %3.2f +/- %1.3f km',db.hbest, db.stdH));
    
else
    figure(23)
    set(gca,'FontName','Helvetica','FontSize',16,...
            'Clipping','off','layer','top');
        imagesc(db.hRange,db.rRange,db.stackvr);
        axis xy
        axis square
        colorbar
        hold on
        plot(db.hbest,db.rbest,'w+')
        plot(db.hbest,db.rbest,'ko')
        hold off
        xlab=xlabel('H');
        ylab=ylabel('R [Vp/Vs]');
        set(xlab,'FontName','Helvetica','FontSize',16);
        set(ylab,'FontName','Helvetica','FontSize',16);
        title(sprintf(' H = %1.3f R = %1.3f',db.hbest,db.rbest));
end

    hfig = figure(29);
    pos1(1) = floor(pos(1)/4);
    set(hfig,'OuterPosition',pos1)
    csection(db.rec(:,1:round(26/db.dt)),0,db.dt);
    hold on
    plot(db.tps,'k+')
    plot(db.tpps,'k+')
    plot(db.tpss,'k+')
    title(sprintf('%s',db.station) )
    hold off
end