function [stack, event] = stackSources(events, stn, stns, fid)
% STACKSOURCES finds all common events in stns and stacks the P components.
% EVENTS should be a cell array of events, 10 digits numbers. STNS should
% be a cell array of stns to look for common events in.

rootdir = '/media/TerraS/CN/';
fs = {};
%% Get list of all events for stns directories
for ii = 1:length(stns)
    fs = ls(fullfile(rootdir, stns{ii}));
    fs = textscan(fs, '%s');
    fs = fs{1};
    fs = fs(~isnan(str2double(fs)));
    evarray{ii} = fs; 
end

%% Find all matches between stn events and stns events

stack = [];
event = [];
stxind = 1;

for ii = 1 : length(events)
    % Put stn event as first in list (we want this in stack too!)
    evlist = {fullfile( rootdir, stn, events{ii}, 'stack_P.sac')};
    for jj = 1: size(evarray, 2)
        % Get all matches with each station for that event
        a = strcmp(events{ii}, evarray{jj});
            if any(a)
                matches = evarray{jj}(a);
                for kk = 1:length(matches)
                    evlist = [ evlist, fullfile(rootdir,...
                        stns{jj}, matches{kk}, 'stack_P.sac') ];
                end
            end
    
    end
    %% STACK
    if size(evlist, 2) > 1
        stx = sourceStacker(evlist, fid);
    end
    if ~isempty(stx)
        stack(stxind, :) = stx; %#ok<*SAGROW>
        event{stxind} = events{ii}; %#ok<*AGROW>
        stxind = stxind + 1;
    end
    evlist = {};
end