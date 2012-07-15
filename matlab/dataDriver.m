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
dbn.stderr1 = results.sterr1;
dbn.stderr2 = results.sterr2;
dbn.errV = results.errV;
dbn.errR = results.errR;
dbn.errH = results.errH;
dbn.smax = results.smax;
dbn.hmax = results.hmax;
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
fprintf('Vp is %f +/- %1.3f km/s\n',results.vbest, results.errV)
fprintf('R is %f +/- %1.3f \n',results.rbest, results.errR)    
fprintf('H is %f +/- %1.3f \n',results.hbest, results.errH)    
    
%% Enter Processing Notes:

notes = inputdlg('Enter Notes','Processing Notes',[3 80]);
dbn.processnotes = notes; 

%% Save entry
saveit = questdlg('Save data to .mat file and results to stations.json?', ...
	'Save the sucker?', ...
	'Yes','No','No');
% Handle response
switch saveit
    case 'Yes'
        db = dbn; %#ok<NASGU>
        save(dbfile,'db')
        % Update stations.json
        opt.FileName = [homedir,'/thesis/stations.json'];
        opt.ForceRootName = 0;
        sts = loadjson(opt.FileName);
        res.Vp = results.vbest;
        res.R = results.rbest;
        res.H = results.hbest;
        sts.(station).results = res;
    case 'No'
       fprintf('fine\n')
end

clear db

%}
%% Compare database stations to station folder
%{
% Tests if folder looks like a station folder than tests if the station is
% in the database station, returns those that are not.
%runcompare = false;
%if runcompare
%    sts = dir(sacfolder);
%    fprintf('Stations left unprocessed:\n')
%    for ii = 1:length(sts)
%        st = sts(ii).name;
%        if strcmp(upper(st),st) && length(st) > 2 && ~any(strcmp(st,{db.station}))
%            fprintf('%s\n',st)
%        end
%    end     
%end
%}

