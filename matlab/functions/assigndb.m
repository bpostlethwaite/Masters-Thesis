function [ db ] = assigndb( db, method, station, brec, ...
    pslow, dt, npb, fLow, fHigh, results, boot)
%ASSIGNDB Assigns data to database object


    % Shared
    db.station = station;
    db.processnotes = ''; % Default
    db.rec = brec;    
    db.pslow = pslow;
    db.dt = dt;
    db.npb = npb;
    db.fLow = fLow;
    db.fHigh = fHigh;
%    db.t1 = t1;
%    db.t2 = t2;
    db.usable = 1; % Default, later ask for value
%    db.Tps = Tps;


    % Specific MB
if strcmp(method, 'bostock')
    db.mb.rbest = results.rbest;
    db.mb.vbest = results.vbest;
    db.mb.hbest = results.hbest;
    db.mb.stackvr = results.stackvr;
    db.mb.stackh = results.stackh;
    db.mb.rRange = results.rRange;
    db.mb.vRange = results.vRange;
    db.mb.hRange = results.hRange;
    db.mb.smax = results.smax;
    db.mb.hmax = results.hmax;
    db.mb.tps = results.tps;
    db.mb.tpps = results.tpps;
    db.mb.tpss = results.tpss;
    db.mb.stdsmax = std(boot.VpRx);
    db.mb.stdhmax = std(boot.Hx);
    db.mb.stdVp = std(boot.Vp);
    db.mb.stdR = std(boot.R);
    db.mb.stdH = std(boot.H);

    % Specific Kanamori
elseif strcmp(method, 'kanamori')
    db.hk.rbest = results.rbest;
    db.hk.v = results.v;
    db.hk.hbest = results.hbest;
    db.hk.stackhr = results.stackhr;
    db.hk.rRange = results.rRange;
    db.hk.hRange = results.hRange;
    db.hk.smax = results.smax;
    db.hk.tps = results.tps;
    db.hk.tpps = results.tpps;
    db.hk.tpss = results.tpss;
    db.hk.stdsmax = std(boot.RHx);
    db.hk.stdR = std(boot.R);
    db.hk.stdH = std(boot.H);
    
elseif strcmp(method, 'fullgrid')
    db.fg.rbest = results.r;
    db.fg.vbest = results.v;
    db.fg.hbest = results.h;
    if (boot)
        db.fg.stdVp = std(boot.Vp);
        db.fg.stdR = std(boot.R);
        db.fg.stdH = std(boot.H);
        db.fg.stdS = std(boot.SMax);
    end
    
    
else
     ME = MException('ProcessMethodNotFound', ...
             'Must be "bostock" or "kanamori."');
     throw(ME);
end

end

