% Access Database

clear all
close all
addpath ../sac
addpath functions


homedir = getenv('HOME');
sacfolder = '/media/TerraS/CN';
databasedir = '/media/TerraS/database';

stations = dir(databasedir);
for ii = 1:length(stations)
    station = stations(ii).name;
    try 
       load(fullfile(databasedir,station))
    catch exception
        fprintf('skipping %s\n', station)
        continue
    end
    
    db.stdVp = std(db.bootVp);
    db.stdR = std(db.bootR);
    db.stdH = std(db.bootH);

    save(fullfile(databasedir, station), 'db')
end
