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
station = 'YOSQ';
%{
ACKN
AP3N 
CLPO
COWN 
DELO
DSMN
DVKN
FRB
GALN
GIFN
ILON
LAIN 
MALO
MLON
ORIO
PEMO
PLVO
SEDN
SILO
SNPN 
SRLN
TYNO
ULM
WAGN
WLVO
YBKN
YOSQ
%}
dbfile = fullfile(databasedir, [station,'.mat'] );
workingdir = fullfile(sacfolder,station);
loadflag = 0;
clear db
if exist(dbfile, 'file')
    load(dbfile)
    loadflag = 1;
end
%% Run ToolChain
ProcessTraces
%% Assign Data
dbn.station = station;
dbn.processnotes = '';
dbn.scanstatus = true;
dbn.failmessage = 'None';
dbn.method = results.method;
dbn.rbest = results.rbest;
dbn.vbest = results.vbest;
dbn.hbest = results.hbest;
dbn.stackvr = results.stackvr;
dbn.stackh = results.stackh;
dbn.rRange = results.rRange;
dbn.vRange = results.vRange;
dbn.hRange = results.hRange;
dbn.smax = results.smax;
dbn.hmax = results.hmax;
dbn.bootVp = bootVp;
dbn.bootR = bootR;
dbn.bootH = bootH;
dbn.bootVpRx = bootVpRx;
dbn.bootHx = bootHx;
dbn.stdVp = std(bootVp);
dbn.stdR = std(bootR);
dbn.stdH = std(bootH);
dbn.tps = results.tps;
dbn.tpps = results.tpps;
dbn.tpss = results.tpss;
dbn.rec = brec(:,1:round(35/dt));
dbn.pslow = pslow;
dbn.Tps = Tps;
dbn.dt = dt;
dbn.npb = npb;
dbn.filterLow = fLow;
dbn.filterHigh = fHigh;
dbn.thresh = thresh;
dbn.t1 = t1;
dbn.t2 = t2;
%% Plot the results if we completed the processing
close all
%plotStack(dbn);
%plotStack(db);
fprintf('Old Data:\n')
fprintf('Vp is %f +/- %1.3f km/s\n',db.vbest, db.stdVp)
fprintf('R is %f +/- %1.3f \n',db.rbest, db.stdR )
fprintf('H is %f +/- %1.3f \n',db.hbest, db.stdH )

fprintf('\nKanamori data\n')
fprintf('R is %f \n',Rkan)
fprintf('H is %f kms\n',Hkan)

fprintf('\nNew Data:\n')
fprintf('Vp is %f +/- %1.3f km/s\n',dbn.vbest, dbn.stdVp )
fprintf('R is %f +/- %1.3f \n',dbn.rbest, dbn.stdR )
fprintf('H is %f +/- %1.3f \n',dbn.hbest, dbn.stdH )
%% Enter Processing Notes:
notes = input('Enter Processing Notes: ', 's');
dbn.processnotes = notes;
%% Save entry
saveit = input('Save data to .mat file? (y|n): ','s');
switch lower(saveit)
    case 'y'
        db = dbn; %#ok<NASGU>
        save(dbfile,'db') % Save .mat file with bulk data
        fprintf('Saved data\n')
    otherwise
        fprintf('Warning: data not saved\n')
end

close all

