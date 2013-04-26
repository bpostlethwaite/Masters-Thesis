% Produce csection plots

clear all
close all
loadtools;
addpath functions
addpath([userdir,'/programming/matlab/jsonlab'])
databasedir = '/media/TerraS/database';
% Function to go from Vp/Vs -> Poisson's ratio
poisson = @(R) ( (R^2 - 2) / (2*(R^2 - 1)));
startsec = 0;

% Load up some data from json file
js = loadjson('../data/stations.json');
stns = fieldnames(js);

for i = 1 : numel(stns)
    % Get data
    clear db
    stn = stns{i};
    dbfile = fullfile(databasedir, [stn,'.mat'] );
    if exist(dbfile, 'file')
        load(dbfile)
    else
        continue
    end
    
    % Make sure we have the necessary fields
    if ~(isfield(db, 'hk') && ...
       isfield(db, 'rec') && ...
       isfield(db.hk, 'tps') && ...
       isfield(db.hk, 'tpps') && ...
       isfield(db.hk, 'tpss'))
        continue
    end
                   
    % Plot Figure
    hf = figure(20);
        
    csection(db.rec(:, 1 : round(26/db.dt)), startsec,db.dt);
    hold on
    plot(db.hk.tps,'k+')
    plot(db.hk.tpps,'k+')
    plot(db.hk.tpss,'k+')
    title(sprintf('%s',db.station) )
    hold off
    
    savename = [userdir,'/thesis/mapping/web/public/images/csect_',stn,'.png'];
    set(hf, 'Position', [1000 500 650 550])
    set(hf,'PaperPositionMode','auto')
    print('-dpng','-zbuffer','-r72', savename)
        
end