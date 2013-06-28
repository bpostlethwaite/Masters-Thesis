% Automatic Kanamori Algorithm

clear all; close all
loadtools;
addpath([userdir,'/thesis/matlab/functions']);
addpath([userdir,'/programming/matlab/jsonlab']);
databasedir = '/media/TerraS/database';

author = 'eaton';

json = loadjson([userdir,'/thesis/data/',author,'Paper.json']);
s = loadjson([userdir,'/thesis/data/', author, 'Processed.json']);

%%
stns = fieldnames(json);


%Setup parallel toolbox
if ~matlabpool('size')
    workers = 4;
    matlabpool('local', workers)
end
%%
for stn = stns'

    station = stn{1};
    load(fullfile(databasedir, station));
    if strcmp(author, 'thompson')
        vp = 6.5;
    else
        vp = 6.39;
    end
    
    method = 'kanamori';
    [ results ] = gridsearchKan(db.rec, db.dt, db.pslow, vp);

    % Run Bootstrap
    [ boot ] = bootstrap(db.rec, db.dt, db.pslow, 1048, method, [], vp);    

    fprintf('--- %s -----\n', station)
    fprintf('R = %f\n', results.rbest)
    fprintf('H = %f\n', results.hbest)
    fprintf('old R = %f\n', db.hk.rbest)
    fprintf('old H = %f\n', db.hk.hbest)
     
%    s.(station).('Vp') = v;
    s.(station).('R') = results.rbest;
    s.(station).('H') = results.hbest;
    s.(station).('stdR') = std(boot.R);
    s.(station).('stdH') = std(boot.H);
    
end

opt.ForceRootName = 0;
opt.FileName = [userdir, '/thesis/data/',author,'Processed.json'];            
savejson('', s, opt);
