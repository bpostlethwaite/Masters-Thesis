%
% Align and Stack P-wave coda for source estimation
%
clear all
close all

loadtools;
addpath([userdir,'/programming/matlab/jsonlab'])
addpath ../../sac
addpath ../functions
rootdir = '/media/TerraS/CN/';

json = loadjson([userdir,'/thesis/data/eventSources.json']);

fields = fieldnames(json);

events = cell(1, length(fields));

split = @(s) (s(7:end));

for ii = 1:length(fields)
    events{ii} = split(fields{ii});
end

%fid = fopen([userdir, '/thesis/data/repicks.txt'], 'w');
for num = 1:length(events);

    stns = cellstr(json.(fields{num}));
    
    
    %% Extract SAC data
    files = {};
    for ii = 1 : length(stns)
        files{ii} = fullfile(rootdir, stns{ii}, events{num}, 'stack_P.sac');  %#ok<*SAGROW>
    end
    
    [trace, header] = getTrace(files);
    
    %% Remove stations with unpicked T1 and T3 and minority dt's
    dts = [];
    kill = zeros(1, length(header));
    
    for ii = 1: length(header)
        dts(ii) = header{ii}.DELTA;
        if isnan(header{ii}.T1) || isnan(header{ii}.T3)
            %fprintf(fid, '%s\n', fullfile(rootdir, stns{ii}, events{num}));
            kill(ii) = 1;
        end
    end

    kill = kill == 1;
    % Need to have something to kill and something left after killing
    if sum(~kill) < 2
        continue
    elseif (sum(kill) > 0) 
        trace(kill, :) = [];
        header(kill) = [];
        dts(kill) = [];
    end

    numbers = unique(dts);       %#provides sorted unique list of elements
    if length(numbers) > 1
        [count ix] = max(hist(dts, numbers));
        kill = ~(dts == numbers(ix));
        if sum(~kill) > 1
            trace(kill, :) = [];
            header(kill) = [];
            dts(kill) = [];
        else
            continue
        end
    end
    
    dt = unique( dts );
    
    %% Normalize
    trace = (diag(1./max( abs(trace), [], 2)) ) * trace;
    
    %% Collect array of Pick times
    picktimes = [];
    endtimes = [];
    for ii = 1 : length(header)
        picktimes(ii) = header{ii}.T1 - header{ii}.B;
        endtimes(ii) = header{ii}.T3 - header{ii}.B;
    end
     
    %% Set a window
    w1 = round((min(picktimes) - 2) / dt);
    w2 = round(( 0.75 * max(endtimes) + 0.25 * w1 * dt ) / dt);
    %w2 = round( max(endtimes) / dt) ;
    %% normalize traces
    wtrace = (diag(1./max( abs(trace(:, w1 : w2)), [], 2)) ) * trace(:, w1 : w2 );
    
    %% Get lags
    [tdel, rmean, sigr] = mccc(wtrace, dt);
    %% Shift unwindowed traces
    strace = lagshift(trace, tdel, dt);
    
    %% PLOT
    %figure(2)
    
    Y = norm(var(strace, 0, 1));
    numt = size(strace,1);
    figure(3)
    subplot(2,1,1)
    plot(trace(1,:))
    line([w1, w2; w1, w2] , [-1, -1; 1, 1])
    subplot(2,1,2)
    plot(sum(strace(:, w1: round(max(endtimes) /dt) )) / numt )
end
