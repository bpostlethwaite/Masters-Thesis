% This program when run will suck up the ProcessTraces parameters into a
% Structure and add the entry into the database.
% Parameters will turn on various functionality.
% Read about function getfield, setfield, rmfield, isfield,

clear all
close all
addpath ../sac
addpath functions

%% Variables
user = getenv('USER');
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
dbn.rec = brec(:,1:round(26/dt));
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
saveit = questdlg('Save the parameters?', ...
	'Save the sucker?', ...
	'Yes','No','No');
% Handle response
switch saveit
    case 'Yes'
        if loadflag
            db(end + 1) = dbn; %#ok<NASGU>
        else
             db = dbn;
        end
        save(dbfile,'db')
        
    case 'No'
       fprintf('fine')
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

