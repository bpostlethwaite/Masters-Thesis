% This program when run will suck up the Process Driver parameters into a
% Structure and append it into structure saved under database.mat.
% Parameters will turn on various functionality.
% Read about function getfield, setfield, rmfield, isfield,
% This function will automatically name resaved stations as ULMa ULMb etc
% so that additional mods can be made and saved for comparison. This
% feature can be turned off.

clear all
close all
addpath sac
addpath Data
addpath Functions

%% Variables
user = getenv('USER');
sacfolder = '/media/TerraS/CNSN';
datadir = ['/home/',user,'/Dropbox/ComLinks/Programming/matlab/thesis/Data'];
rfile = 'STACK_R.sac';
zfile = 'STACK_Z.sac';
%%  Select Station folder to process
station = 'ULM';
workingdir = fullfile(sacfolder,station);
%workingdir = fullfile(['/home/',user,'/Programming/data/'],station);

%% Select Workmode, Load database
overwrite = true; % Overwrite Station data
append    = false; % Append additional station data with prefix a,b,c,d etc
remove    = false; % Remove all data associated with station

load(sprintf('%s/database.mat',datadir))

%% Run though stations, remove or find next available prefix.
% This either removes all fields associated with station or appends a new
% structure with fieldname station+postfix a,b,c etc. It automatically
% appends the next available postfix. 
stID = [station,'a'];
if append == true || remove == true
    ii = 1;
    while isfield(db,stID)
        if remove == true
            db = rmfield(db,stID);
        end
        stID = [station,char(double('a')+ii)];
        ii = ii + 1;
    end
end
%% Run ProcessTraces
% Run ProcessTraces then collect results into structure
if ~remove
    try
        ProcessTraces
        s = results;   % Begin with all  results from GridSearch
        s.scanstatus = scanstatus;  % Creat some method to update these
        s.failmessage = 'None';  % Creat some method to update these
        s.badpicks = badpicks;   %Bad picks which come from ConvertFilterTraces.m
        s.rec = brec;            % Filtered traces
        s.pslow = pslow;         % Binned slowness values used
        s.dt = dt;               % dt for station
        s.npb = npb; % average number of traces per pbin
        s.filterLow = fLow; % Low frequency cut-off
        s.filterHigh = fHigh; %High Frequency cut-off
        s.t1 = t1; % These are the time windows constraining the automatic
        s.t2 = t2; % pick of reciever function impulses
        
    catch e
        s.scanstatus = false;
        s.failmessage = e.identifier;
        fprintf('Encountered error: %s\n',e.identifier)
    end   
    % Name processed structure StationName+prefix
    s.station = stID;
    % Add processed structure to database
    db.(stID) = s;
    % Plot the results if we completed the processing
    if s.scanstatus
        plotStack(db.(stID));
    end
end

% Save the database.
save(sprintf('%s/database.mat',datadir),'db')



