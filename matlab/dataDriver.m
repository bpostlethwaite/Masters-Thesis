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

%%  Select Station to Process and load station data.
station = 'SADO';
dbfile = fullfile(databasedir, [station,'.mat'] );
workingdir = fullfile(sacfolder,station);
loadflag = 0;
if exist(dbfile, 'file')
    load(dbfile)
    loadflag = 1;
end
%% Run ToolChain
ProcessTraces
%% Assign Data
% For a description of data see DataDescription.m
dbn.station = station;    
dbn.processnotes = [];
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
dbn.stdVp = 2*std(bootVp);
dbn.stdR = 2*std(bootR);
dbn.stdH = 2*std(bootH);
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
plotStack(dbn);
fprintf('Vp is %f +/- %1.3f km/s\n',dbn.vbest, dbn.stdVp )
fprintf('R is %f +/- %1.3f \n',dbn.rbest, dbn.stdR )    
fprintf('H is %f +/- %1.3f \n',dbn.hbest, dbn.stdH )     
%% Enter Processing Notes:
notes = input('Enter Processing Notes: ', 's');
dbn.processnotes = notes; 
%% Save entry
saveit = input('Save data to .mat file and results to stations.json? (y|n): ','s');
switch lower(saveit)
    case 'y'
        db = dbn;
        save(dbfile,'db') % Save .mat file with bulk data
        % Update stations.json
        opt.FileName = [homedir,'/thesis/stations.json'];
        opt.ForceRootName = 0;
        sts = loadjson(opt.FileName);
        sts.(station).Vp = db.vbest;
        sts.(station).R = db.rbest;
        sts.(station).H = db.hbest;
        sts.(station).stdVp = db.stdVp;
        sts.(station).stdR = db.stdR;
        sts.(station).stdH = db.stdH;
        savejson('', sts, opt);
        fprintf('Saved data\n')
    otherwise
        fprintf('Warning: data not saved\n')
end

clear db
