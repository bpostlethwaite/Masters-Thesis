% Automatic Kanamori Algorithm

clear all; close all
loadtools;
addpath([userdir,'/thesis/matlab/functions']);
addpath([userdir,'/programming/matlab/jsonlab']);
databasedir = '/media/TerraS/database';
 
%Setup parallel toolbox
if ~matlabpool('size')
    workers = feature('numCores');
    matlabpool('local', workers)
end

lim3D = 150;

stns = {'ULM'};

for stn = stns'

    station = stn{1};
    
    load(fullfile(databasedir, station));
        
    [ v, r, h, ~] = gridsearch3DC(db.rec', db.dt, db.pslow, lim3D);
    tic
    [Vp, R, H] = bootstrap3D(db.rec, db.dt, db.pslow, lim3D, 10);    
    toc
 
    fprintf('--- 3Dsearch -----\n')
    fprintf('Vp = %f\n', v)
    fprintf('R = %f\n', r)
    fprintf('H = %f\n', h)
    
end
