clear all;
close all

addpath functions

database = '/media/TerraS/database';
dfullgrid = '/media/TerraS/dfullgrid';

flist=dir([dfullgrid,'/*.mat']); 

mergeFLAG = false;
plotFLAG = false;

for ii=1:length(flist)

    station = flist(ii).name(1:end-4);
    disp(station)
    dbfile = fullfile(databasedir, flist(ii).name);
    fullgfile = fullfile(dfullgrid, flist(ii).name);
    load(dbfile)
    S = load(fullgfile); %#ok<NASGU>

if mergeFLAG
    
    db.fg.rbest = S.r;
    db.fg.vbest = S.v;
    db.fg.hbest = S.h;
    db.fg.bootVp = S.Vp;
    db.fg.bootR = S.R;
    db.fg.bootH = S.H;
    db.fg.stdVp = std(S.Vp);
    db.fg.stdR = std(S.R);
    db.fg.stdH = std(S.H);
    
    save(dbfile,'db') % Save .mat file with bulk data
    fprintf('Saved data\n')
    
end

if plotFLAG
    
    p2 = db.pslow.^2; %#ok<*UNRCH>
    f1 = sqrt((S.r / S.v)^2 - p2);
    f2 = sqrt((1 / S.v)^2 - p2);
    tps = S.h * (f1 - f2);
    tpps = S.h * (f1 + f2);
    tpss = S.h * 2 * f1;

    csection(db.rec(:, 1 : round(26/db.dt)), 0, db.dt);
    hold on
    plot(tps,'k+')
    plot(tpps,'k+')
    plot(tpss,'k+')
    title(sprintf('%s', station) )
    hold off
    
    pause()
end

    clear S db

end