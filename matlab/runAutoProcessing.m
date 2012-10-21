clear all; close all
loadtools;
addpath([userdir,'/thesis/matlab/functions']);
databasedir = '/media/TerraS/database';

s = dir(databasedir);

method = 'bostock';
for ii = 1: length(s)
    % Get rid of . and .. names
    if length(s(ii).name) < 3
        continue
    end
    
    disp(s(ii).name)
    
    dbfile = fullfile(databasedir, s(ii).name);
    load(dbfile) 
    
    if db.usable
     
        % Run bostock algorithm with Tps = kanamori tps results
        [ results ] = gridsearchMB(db.rec(:, 1:round(45/db.dt)),...
            db.dt, db.pslow, db.hk.tps);
    
        % Run Bootstrap
        [ boot ] = bootstrap(db.rec(:, 1:round(45/db.dt)),...
            db.dt, db.pslow, 1024, method, db.hk.tps', 0);    
        
        % Assign data 
        [ db ] = assigndb( db, method, db.station, db.rec(:, 1:round(45/db.dt)), ...
            db.pslow, db.dt, db.npb, db.fLow, db.fHigh, db.t1,...
            db.t2, db.Tps, results, boot);
    
    else
        
        db.rec = db.rec(:, 1:round(45/db.dt));
        
    end
    

    % Save sequence
    save(dbfile,'db') 
    clear db
end