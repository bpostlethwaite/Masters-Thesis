% Access Database

clear all
close all
%addpath ../sac
%addpath functions


%homedir = getenv('HOME');
%sacfolder = '/media/TerraS/CN';
databasedir = '/media/TerraS/database';
stations = {dir([databasedir,'*.mat'])};
for station = dir(databasedir)
    try 
       load(fullfile(databasedir,station.name))
        fprintf('loaded %s\n', station.name)
    catch exception
        fprintf('skipping %s\n', station.name)
        continue
    end
    
    %db.stdVp = std(db.bootVp);
    %db.stdR = std(db.bootR);
    %db.stdH = std(db.bootH);
    %save(fullfile(databasedir, station.name), 'db')
end
