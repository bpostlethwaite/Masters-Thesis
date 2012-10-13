% This program when run will suck up the ProcessTraces parameters into a
% Structure and add the entry into the database.
% Parameters will turn on various functionality.
% Read about function getfield, setfield, rmfield, isfield,

clear all
close all
addpath ../sac
addpath functions

%% Variables
homedir = getenv('HOME');
sacfolder = '/media/TerraS/CN';
databasedir = '/media/TerraS/database';
pfile = 'stack_P.sac';
sfile = 'stack_S.sac';

%%  Select Station to Process and load station data
method = 'kanamori';
station = 'ACKN';
%{
%}
dbfile = fullfile(databasedir, [station,'.mat'] );
workingdir = fullfile(sacfolder,station);
loadflag = 0;
clear db dbold
if exist(dbfile, 'file')
    load(dbfile)
    loadflag = 1;
    dbold = db;
end
%% Run ToolChain
ProcessTraces

%% Assign Data
    % Shared
    db.station = station;
    db.processnotes = '';
    db.rec = rec;    
    db.pslow = pslow;
    db.dt = dt;
    db.npb = npb;
    db.fLow = fLow;
    db.fHigh = fHigh;
    db.t1 = t1;
    db.t2 = t2;

    % Specific MB
if strcmp(method, 'bostock')
    db.mb.rbest = results.rbest;
    db.mb.vbest = results.vbest;
    db.mb.hbest = results.hbest;
    db.mb.stackvr = results.stackvr;
    db.mb.stackh = results.stackh;
    db.mb.rRange = results.rRange;
    db.mb.vRange = results.vRange;
    db.mb.hRange = results.hRange;
    db.mb.smax = results.smax;
    db.mb.hmax = results.hmax;
    db.mb.tps = results.tps;
    db.mb.tpps = results.tpps;
    db.mb.tpss = results.tpss;
    db.mb.Tps = Tps;
    db.mb.stdsmax = std(bootVpRx);
    db.mb.stdhmax = std(bootHx);
    db.mb.stdVp = std(bootVp);
    db.mb.stdR = std(bootR);
    db.mb.stdH = std(bootH);

    % Specific Kanamori
elseif strcmp(method, 'kanamori')   
    db.km = results.method;
    db.km = results.rbest;
    db.km = results.v;
    db.km = results.hbest;
    db.km = results.stackhr;
    db.km = results.rRange;
    db.km = results.hRange;
    db.km = results.smax;
    db.km = results.tps;
    db.km = results.tpps;
    db.km = results.tpss;
    db.km.stdsmax = std(bootRHx);
    db.km.stdR = std(bootR);
    db.km.stdH = std(bootH);

else
     ME = MException('ProcessMethodNotFound', ...
             'Must be "bostock" or "kanamori."');
     throw(ME);
end
%% Plot the results if we completed the processing
close all
plotStack(db);
fprintf('Old Data:\n')

%if strcmp(method, 'bostock')
%    fprintf('Vp is %f +/- %1.3f km/s\n',dbold.vbest, dbold.stdVp)
%end
%fprintf('R is %f +/- %1.3f \n',dbold.rbest, dbold.stdR )
%fprintf('H is %f +/- %1.3f \n',dbold.hbest, dbold.stdH )
%
%fprintf('\nKanamori data\n')
%fprintf('R is %f \n',Rkan)
%fprintf('H is %f kms\n',Hkan)
%
%fprintf('\nNew Data:\n')
%fprintf('Vp is %f +/- %1.3f km/s\n',db.vbest, db.stdVp )
%fprintf('R is %f +/- %1.3f \n',db.rbest, db.stdR )
%fprintf('H is %f +/- %1.3f \n',db.hbest, db.stdH )

%% Enter Processing Notes:
notes = input('Enter Processing Notes: ', 's');
db.processnotes = notes;
%% Save entry
saveit = input('Save data to .mat file? (y|n): ','s');
switch lower(saveit)
    case 'y'
        save(dbfile,'db') % Save .mat file with bulk data
        fprintf('Saved data\n')
    otherwise
        fprintf('Warning: data not saved\n')
end

close all

