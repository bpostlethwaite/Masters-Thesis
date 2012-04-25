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
sacfolder = '/media/TerraS/CNSN';
%sacfolder = '/media/TerraS/CNSN';
datadir = ['/home/',user,'/programming/matlab/thesis/data'];
databasedir = [datadir,'/database'];
rfile = 'STACK_R.sac';
zfile = 'STACK_Z.sac';
%%  Select Station to Process and load station data.
%station = 'VTIN';
station = 'ULM';
workingdir = fullfile(sacfolder,station);
%load(fullfile(databasedir,[station,'.mat']))
%workingdir = fullfile(['/home/',user,'/Programming/data/'],station);
%% Select Mode
append = false;    % Appends new station entry (multiple same stations OK)
overwrite = true;  % Overwrites 1st station entry
remove = false;    % Removes all entries associated with particular station
%% Tag on solved window times.

%% Run ProcessTraces
% Run ProcessTraces then collect results into structure
try
    ProcessTraces
    % For a description of data see DataDescription.m
    dbn.station = station;    
    dbn.processnotes = [];
    dbn.scanstatus = true; 
    dbn.failmessage = 'None'; 
    dbn.badpicks = badpicks;
    dbn.method = results.method;
    dbn.rbest = results.rbest;
    dbn.vbest = results.vbest;
    dbn.hbest = results.hbest;
    dbn.stackvr = results.stackvr;
    dbn.stackh = results.stackh;
    dbn.rRange = results.rRange;
    dbn.vRange = results.vRange;
    dbn.hRange = results.hRange;
    dbn.stderr1 = results.stderr1;
    dbn.stderr2 = results.stderr2;
    dbn.smax = results.smax;
    dbn.hmax = results.hmax;
    dbn.tps = results.tps;
    dbn.tpps = results.tpps;
    dbn.tpss = results.tpss;
    dbn.rec = brec;
    dbn.pslow = pslow;  
    dbn.dt = dt;   
    dbn.npb = npb;   
    dbn.filterLow = fLow; 
    dbn.filterHigh = fHigh; 
    dbn.t1 = t1;        
    dbn.t2 = t2;        
    dbn.dlist = dlist;
    
catch e
    dbn.station = station;  
    dbn.scanstatus = false;
    dbn.failmessage = sprintf('Identifier: { %s } \nMessage: { %s } ',...
            e.identifier,e.message);
    fprintf('Encountered error during processing:\n%s\n',...
        dbn.failmessage)
end
%% Plot the results if we completed the processing
if dbn.scanstatus
    plotStack(dbn);
    %plotStack(db(2));
end
%% Enter Processing Notes:
notes = inputdlg('Enter Notes','Processing Notes',[3 80]);
dbn.processnotes = notes; 
%% Save the database.
%% Select next Index, Entry Mode
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
%save(sprintf('%s/database.mat',datadir),'db','-v6')
%}
%% Show database info:


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

