% Automatic Kanamori Algorithm

clear all; close all
loadtools;
addpath([userdir,'/thesis/matlab/functions']);
addpath([userdir,'/programming/matlab/jsonlab']);
databasedir = '/media/TerraS/database';


json = loadjson([userdir,'/thesis/data/darbyshirePaper.json']);
stns = fieldnames(json);

fhout = fopen([userdir,'/thesis/data/darbyshireProcessed.json'], 'w');
            
%Setup parallel toolbox
if ~matlabpool('size')
    workers = 4;
    matlabpool('local', workers)
end

for stn = stns'

    station = stn{1};
    load(fullfile(databasedir, station));
    vp = 6.39; %Eaton & DARBYshire
    %vp = 6.5; % Thompson
    
    method = 'kanamori';
    [ results ] = gridsearchKan(db.rec, db.dt, db.pslow, vp);

    % Run Bootstrap
    [ boot ] = bootstrap(db.rec, db.dt, db.pslow, 1048, method, [], vp);    

    %[ kr, kh, ~ ] = fastgridsearchKAN(db.rec', db.dt, db.pslow);
    %[ bv, br, bh, ~, ~ ] = fastgridsearch(db.rec', db.Tps, db.dt, db.pslow);
    %[ v, r, h, ~] = G3Dsearch(db.rec', db.dt, db.pslow, 150);
    
    fprintf('--- %s -----\n', station)
    fprintf('R = %f\n', results.rbest)
    fprintf('H = %f\n', results.hbest)
    fprintf('old R = %f\n', db.hk.rbest)
    fprintf('old H = %f\n', db.hk.hbest)
    
%     fprintf('--- Bostock -----\n')
%     fprintf('Vp = %f\n', bv)
%     fprintf('R = %f\n', br)
%     fprintf('H = %f\n', bh)
%     fprintf('--- 3Dsearch -----\n')
%     fprintf('Vp = %f\n', v)
%     fprintf('R = %f\n', r)
%     fprintf('H = %f\n', h)
    
%    s.(station).('Vp') = v;
    s.(station).('R') = results.rbest;
    s.(station).('H') = results.hbest;
    s.(station).('stdR') = std(boot.R);
    s.(station).('stdH') = std(boot.H);
    
end

opt.ForceRootName = 0;
json = savejson('', s, opt);
fprintf('%s',json);
fprintf(fhout,'%s',json);

fclose(fhout);