% Automatic Kanamori Algorithm

clear all; close all
homedir = getenv('HOME');
addpath([homedir,'/thesis/matlab/functions']);
addpath([homedir,'/programming/matlab/jsonlab']);
databasedir = '/media/TerraS/database';

fhin = fopen('processed-ok.list');
fhout = fopen([homedir,'/thesis/kanStats.json'], 'w');

tline = fgetl(fhin);

while ischar(tline)
    station = tline;
    load(fullfile(databasedir,station))
    [ rbest, hbest, ~ ] = fastgridsearchKAN(db.rec', db.dt, db.pslow);
    disp(station)
    s.(station).('R') = rbest;
    s.(station).('H') = hbest;
    tline = fgetl(fhin);

end

opt.ForceRootName = 0;
json = savejson('', s, opt);
fprintf(fhout,'%s',json);

fclose(fhin);
fclose(fhout);



%load(fullfile(databasedir,station))

    %db.stdVp = std(db.bootVp);
    %db.stdR = std(db.bootR);
    %db.stdH = std(db.bootH);
    %save(fullfile(databasedir, station.name), 'db')

