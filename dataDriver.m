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
%%  Select Station, Load Database
station = 'INK';
notes = 'May need to partition data into two sets based on tps picks';
workingdir = fullfile(sacfolder,station);
%workingdir = fullfile(['/home/',user,'/Programming/data/'],station);
load(sprintf('%s/database.mat',datadir))

%% Select next Index, Entry Mode
append = false;     % Appends new station entry (multiple same stations OK)
overwrite = true; % Overwrites 1st station entry
remove = false;    % Removes all entries associated with particular station

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

%% Run ProcessTraces
% Run ProcessTraces then collect results into structure

try
    ProcessTraces
    % For a description of data see DataDescription.m
    db(new).station = station;    
    db(new).processnotes = notes;
    db(new).scanstatus = true; 
    db(new).failmessage = 'None'; 
    db(new).badpicks = badpicks;  
    db(new).rbest = results.rbest;
    db(new).vbest = results.vbest;
    db(new).hbest = results.hbest;
    db(new).stackvr = results.stackvr;
    db(new).stackh = results.stackh;
    db(new).rRange = results.rRange;
    db(new).vRange = results.vRange;
    db(new).hRange = results.hRange;
    db(new).stderr1 = results.stderr1;
    db(new).stderr2 = results.stderr2;
    db(new).smax = results.smax;
    db(new).hmax = results.hmax;
    db(new).tps = results.tps;
    db(new).tpps = results.tpps;
    db(new).tpss = results.tpss;
    db(new).rec = brec;
    db(new).pslow = pslow;  
    db(new).dt = dt;   
    db(new).npb = npb;   
    db(new).filterLow = fLow; 
    db(new).filterHigh = fHigh; 
    db(new).t1 = t1;        
    db(new).t2 = t2;        
    db(new).dlist = dlist;
    
catch e
    db(new).station = station;  
    db(new).scanstatus = false;
    db(new).failmessage = sprintf('Identifier: { %s } \nMessage: { %s } ',...
            e.identifier,e.message);
    fprintf('Encountered error during processing:\n%s\n',...
        db(new).failmessage)
end


% Plot the results if we completed the processing
if db(new).scanstatus
    plotStack(db(new));
end

%% Sort new entry by station and save
[tmp ind]=sort({db.station});
db=db(ind);

% Save the database.
save(sprintf('%s/database.mat',datadir),'db')

%% Show database info:






