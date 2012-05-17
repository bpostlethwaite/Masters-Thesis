% New plotter
%addpath data
%addpath functions
%close all; clear all

%user = getenv('USER');
%datadir = ['/home/',user,'/programming/matlab/thesis/data'];

%load(fullfile(datadir,'database.mat'))
%dbn = db(1);

figure(342)
set(gca,'FontName','Helvetica','FontSize',16,...
            'Clipping','off','layer','top');
        imagesc(dbn.rRange,dbn.vRange,dbn.stackvr);
        axis xy
        axis square
        colorbar
        hold on
        plot(dbn.rbest,dbn.vbest,'w+')
        plot(dbn.rbest,dbn.vbest,'ko')
        contour(dbn.rRange,dbn.vRange,dbn.stackvr,...
            [dbn.smax-dbn.stderr1,dbn.smax-dbn.stderr1],'k-')
        hold off
        xlab=xlabel('R');
        ylab=ylabel('V_P [km/s]');
        set(xlab,'FontName','Helvetica','FontSize',16);
        set(ylab,'FontName','Helvetica','FontSize',16);
        title(sprintf('Station: %s \n R = %1.3f +/- %1.3f \nVp = %1.3f +/- %1.3f km/s',...
            dbn.station, dbn.rbest ,dbn.errR, dbn.vbest, dbn.errV));
        
        
figure(1197)
    csection(dbn.rec(:,1:round(26/dbn.dt)),0,dbn.dt);
    title(sprintf('Receiver Function Stack,  station: %s',dbn.station))
    hold on
    plot(dbn.tps,'k+')
    plot(dbn.tpps,'k+')
    plot(dbn.tpss,'k+')
    hold off