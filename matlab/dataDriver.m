% This program when run will suck up the ProcessTraces parameters into a
% Structure and add the entry into the database.
% Parameters will turn on various functionality.
% Read about function getfield, setfield, rmfield, isfield,

clear all
close all
loadtools;
addpath ../sac
addpath functions
addpath sourceStack
addpath([userdir,'/programming/matlab/toolbox_general'])
addpath([userdir,'/programming/matlab/toolbox_signal'])
addpath([userdir,'/programming/matlab/jsonlab'])
%% Variables
sacfolder = '/media/bpostlet/TerraS/CN';
databasedir = '/media/bpostlet/TerraS/database';
pfile = 'stack_P.sac';
sfile = 'stack_S.sac';
load stnsjson.mat
%%  Select Station to Process and load station data
method = 'kanamori';
station = 'STCO'; %

%{

%}
dbfile = fullfile(databasedir, [station,'.mat'] );
workingdir = fullfile(sacfolder,station);
clear db dbold
if exist(dbfile, 'file')
    load(dbfile)
    dbold = db;
else
    db = struct();
end

%% Run ToolChain
% attempt to get two side by side comparisons of events - one using the
% souce stack approach, one using the regular method. If there are problems
% need to get it to compare singular event as it moves  thorugh procssing
% chain.
%ProcessStack
ProcessTraces
%% Assign Data

[ db ] = assigndb( db, method, station, brec(:,1:round(45/dt)), ...
    pslow, dt, npb, fLow, fHigh, results, boot);

%% Plot the results if we completed the processing
close all
plotStack(db, method);

if strcmp(method, 'bostock')
    fprintf('Vp is %f +/- %1.3f \n',db.mb.vbest, db.mb.stdVp )
    fprintf('R is %f +/- %1.3f \n',db.mb.rbest, db.mb.stdR )
    fprintf('H is %f +/- %1.3f \n',db.mb.hbest, db.mb.stdH )
    if exist('dbold','var')
        if isfield(dbold,'mb')
            fprintf('Old MB Vp is %f +/- %1.3f \n',dbold.mb.vbest, dbold.mb.stdVp )
            fprintf('Old MB R is %f +/- %1.3f \n',dbold.mb.rbest, dbold.mb.stdR )
            fprintf('Old MB H is %f +/- %1.3f \n',dbold.mb.hbest, dbold.mb.stdH )
        end
        if isfield(dbold,'hk')
            fprintf('Old hk R is %f +/- %1.3f \n',dbold.hk.rbest, dbold.hk.stdR )
            fprintf('Old hk H is %f +/- %1.3f \n',dbold.hk.hbest, dbold.hk.stdH )
        end
    end
end

if strcmp(method, 'kanamori')
    fprintf('R is %f +/- %1.3f \n',db.hk.rbest, db.hk.stdR )
    fprintf('H is %f +/- %1.3f \n',db.hk.hbest, db.hk.stdH )
    if exist('dbold','var')
        if isfield(dbold,'hk')
            fprintf('Old hk R is %f +/- %1.3f \n',dbold.hk.rbest, dbold.hk.stdR )
            fprintf('Old hk H is %f +/- %1.3f \n',dbold.hk.hbest, dbold.hk.stdH )
        end
        if isfield(dbold,'mb')
            fprintf('Old MB R is %f +/- %1.3f \n',dbold.mb.rbest, dbold.mb.stdR )
            fprintf('Old MB H is %f +/- %1.3f \n',dbold.mb.hbest, dbold.mb.stdH )
            fprintf('Old MB Vp is %f +/- %1.3f \n',dbold.mb.vbest, dbold.mb.stdVp )
        end
    end
end

if strcmp(method, 'fullgrid')
    fprintf('Vp is %f +/- %1.3f \n',db.fg.vbest, db.fg.stdVp )
    fprintf('R is %f +/- %1.3f \n',db.fg.rbest, db.fg.stdR )
    fprintf('H is %f +/- %1.3f \n',db.fg.hbest, db.fg.stdH )
    if exist('dbold','var')
        if isfield(dbold,'fg')
            fprintf('Old FG Vp is %f +/- %1.3f \n',dbold.fg.vbest, dbold.fg.stdVp )
            fprintf('Old FG R is %f +/- %1.3f \n',dbold.fg.rbest, dbold.fg.stdR )
            fprintf('Old FG H is %f +/- %1.3f \n',dbold.fg.hbest, dbold.fg.stdH )
        end
        if isfield(dbold,'hk')
            fprintf('Old hk R is %f +/- %1.3f \n',dbold.hk.rbest, dbold.hk.stdR )
            fprintf('Old hk H is %f +/- %1.3f \n',dbold.hk.hbest, dbold.hk.stdH )
        end
    end
end

%% Enter Finishing commands:

saveit = input('Save data to .mat file? (y|n): ','s');
switch lower(saveit)
    case 'y'
        save(dbfile,'db') % Save .mat file with bulk data
        fprintf('Saved data\n')
    otherwise
        fprintf('Warning: data not saved\n')
end

close all