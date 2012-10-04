% Automatic Kanamori Algorithm

clear all; close all
homedir = getenv('HOME');
addpath([homedir,'/thesis/matlab/functions']);
addpath([homedir,'/programming/matlab/jsonlab']);
databasedir = '/media/TerraS/database';

fhin = fopen('processed-ok.list');
fhout = fopen([homedir,'/thesis/3DStats.json'], 'w');
            
tline = fgetl(fhin);   

while ischar(tline)
    station = tline;
    load(fullfile(databasedir,station));
    %[ kr, kh, ~ ] = fastgridsearchKAN(db.rec', db.dt, db.pslow);
    %[ bv, br, bh, ~, ~ ] = fastgridsearch(db.rec', db.Tps, db.dt, db.pslow);
    [ v, r, h, ~] = G3Dsearch(db.rec', db.dt, db.pslow, 150);
    
    fprintf('%s\n',station)
%     fprintf('--- Kanamori -----\n')
%     fprintf('R = %f\n', kr)
%     fprintf('H = %f\n', kh)
%     fprintf('--- Bostock -----\n')
%     fprintf('Vp = %f\n', bv)
%     fprintf('R = %f\n', br)
%     fprintf('H = %f\n', bh)
%     fprintf('--- 3Dsearch -----\n')
    fprintf('Vp = %f\n', v)
    fprintf('R = %f\n', r)
    fprintf('H = %f\n', h)
    
    s.(station).('Vp') = v;
    s.(station).('R') = r;
    s.(station).('H') = h;
    tline = fgetl(fhin);
end

opt.ForceRootName = 0;
json = savejson('', s, opt);
fprintf('%s',json);
fprintf(fhout,'%s',json);

fclose(fhin);
fclose(fhout);



%load(fullfile(databasedir,station))

    %db.stdVp = std(db.bootVp);
    %db.stdR = std(db.bootR);
    %db.stdH = std(db.bootH);
    %save(fullfile(databasedir, station.name), 'db')

