% This program when run will suck up the ProcessTraces parameters into a
% Structure and add the entry into the database.
% Parameters will turn on various functionality.
% Read about function getfield, setfield, rmfield, isfield,

clear all
close all
addpath sac
addpath data
addpath functions

%% Variables
user = getenv('USER');
sacfolder = '/media/TerraS/X5';
%sacfolder = '/media/TerraS/CNSN';
datadir = ['/home/',user,'/programming/matlab/thesis/data'];
databasedir = [datadir,'/database'];
rfile = 'stack_R.sac';
zfile = 'stack_Z.sac';
%%  Select Station to Process and load station data.
%station = 'VTIN';
station = 'CTSN';
workingdir = fullfile(sacfolder,station);
%workingdir = fullfile(['/home/',user,'/Programming/data/'],station);
%% Select Mode
append = false;    % Appends new station entry (multiple same stations OK)
overwrite = true;  % Overwrites 1st station entry
remove = false;    % Removes all entries associated with particular station
%% Tag on solved window times.

%% Run ProcessTraces
% Run ProcessTraces then collect results into structure
try
    % ProcessTraces
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
    dbn.dt = dt;   
    dbn.npb = npb;   
    dbn.filterLow = fLow; 
    dbn.filterHigh = fHigh; 
    dbn.thresh = thresh;
    dbn.t1 = t1;        
    dbn.t2 = t2;        
    dbn.processnotes = [];
    
catch e
    dbn.station = station;  
    dbn.scanstatus = false;
    dbn.failmessage = sprintf('Identifier: { %s } \nMessage: { %s } ',...
            e.identifier,e.message);
    fprintf('Encountered error during processing:\n%s\n',...
        dbn.failmessage)
end
%% Plot the results if we completed the processing
close all
if dbn.scanstatus
    plotStack(dbn);
    fprintf('Vp is +/- %1.3f km/s\n',results.errV)
    fprintf('R is +/- %1.3f \n',results.errR)    
    fprintf('H is +/- %1.3f \n',results.errH)    
    
end
%% Enter Processing Notes:
%notes = inputdlg('Enter Notes','Processing Notes',[3 80]);
%dbn.processnotes = notes; 

%% Load Database and Save entry
%{
if ~append
    k = strcmp(station, {db.station});
    if overwrite && any(k)
        % Find first entry and replace
        new = find(k,1); %#ok<*UNRCH>
    elseif remove && any(k) 
        % Remove entries, save and exit
        db(k) = []; %#ok<NASGU>
        save(sprintf('%s/database.mat',datadir),'db')
        exit
    else
        new = length(db)+1; % Get next entry in database for appending
        fprintf('Did not find entries associated with station %s',station)
    end
else
    new = length(db)+1; % Get next entry in database for appending
end
%}

load(fullfile(datadir,'database.mat'))
db(end + 1) = dbn; %#ok<NASGU>
save(sprintf('%s/database.mat',datadir),'db','-v6')
clear db

%}
%% Load and Plot
load(fullfile(datadir,'database.mat'))
dbn = db(x);
plotStack(dbn);

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

