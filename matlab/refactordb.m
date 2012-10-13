% Refactor the database to new format.


clear all; close all
homedir = getenv('HOME');
addpath([homedir,'/thesis/matlab/functions']);
addpath([homedir,'/programming/matlab/jsonlab']);
databasedir = '/media/TerraS/database';

s = dir(databasedir);
for ii = 1: length(s)
    
    if length(s(ii).name) < 3
        continue
    end
    
    disp(s(ii).name)
    dbfile = fullfile(databasedir, s(ii).name);
    load(dbfile)

    % Shared
    dbn.station = db.station;
    dbn.processnotes = db.processnotes;
    dbn.rec = db.rec;    
    dbn.pslow = db.pslow;
    dbn.dt = db.dt;
    dbn.npb = db.npb;
    dbn.fLow = db.filterLow;
    dbn.fHigh = db.filterHigh;
    dbn.t1 = db.t1;
    dbn.t2 = db.t2;

    % Specific MB
    dbn.mb.rbest = db.rbest;
    dbn.mb.vbest = db.vbest;
    dbn.mb.hbest = db.hbest;
    dbn.mb.stackvr = db.stackvr;
    dbn.mb.stackh = db.stackh;
    dbn.mb.rRange = db.rRange;
    dbn.mb.vRange = db.vRange;
    dbn.mb.hRange = db.hRange;
    dbn.mb.smax = db.smax;
    dbn.mb.hmax = db.hmax;
    dbn.mb.tps = db.tps;
    dbn.mb.tpps = db.tpps;
    dbn.mb.tpss = db.tpss;
    dbn.mb.Tps = db.Tps;
    dbn.mb.stdsmax = std(db.bootVpRx);
    dbn.mb.stdhmax = std(db.bootHx);
    dbn.mb.stdVp = db.stdVp;
    dbn.mb.stdR = db.stdR;
    dbn.mb.stdH = db.stdH;

    db = dbn;
    %save(dbfile, 'db')

end

