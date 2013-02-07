function [stack, lags] = sourceStacker(files, fid)

stack = [];
lags = [];

[trace, header] = getTrace(files);

%% Remove stations with unpicked T1 and T3 and minority dt's
dts = [];
kill = zeros(1, length(header));

for ii = 1: length(header)
    dts(ii) = header{ii}.DELTA;
    if isnan(header{ii}.T1) || isnan(header{ii}.T3)
        fprintf('Found NaN in %s\n', files{ii});
        if fid
            fprintf(fid, '%s\n', files{ii});
        end
        kill(ii) = 1;
    end
end

kill = kill == 1;
% Need to have something to kill and something left after killing
if (sum(kill) > 0)
    disp('Killing NaN T1 or T3 traces')
    trace(kill, :) = [];
    header(kill) = [];
    dts(kill) = [];
end

numbers = unique(dts);       %#provides sorted unique list of elements
if length(numbers) > 1
    [count ix] = max(hist(dts, numbers));
    kill = ~(dts == numbers(ix));
    trace(kill, :) = [];
    header(kill) = [];
    dts(kill) = [];
end

if size(trace, 1) < 2
    fprintf('Only %i trace in. Skipping\n', size(trace, 1) )
    return
end
dt = unique( dts );

%% Normalize
trace = (diag(1./max( abs(trace), [], 2)) ) * trace;

%% Collect array of Pick times
picktimes = zeros(1, length(header));
endtimes = picktimes;
for ii = 1 : length(header)
    picktimes(ii) = header{ii}.T1 - header{ii}.B;
    endtimes(ii) = header{ii}.T3 - header{ii}.B;
end

%% Set a window
w1 = round((min(picktimes) - 2) / dt); % 2 seconds before earliest
w2 = round(( 0.75 * max(endtimes) + 0.25 * w1 * dt ) / dt);
w3 = round( max(endtimes) / dt) ; % max end of envelope
%% normalize traces
wtrace = (diag(1./max( abs(trace(:, w1 : w2)), [], 2)) ) * trace(:, w1 : w2 );

%% Get lags
[lags, ~, ~] = mccc(wtrace, dt);
%% Shift unwindowed traces

strace = lagshift(trace, lags, dt);

%% Stack
%stack.dt = dt;
stack = sum( strace ) / size(strace, 1);

%% Get new windows
%{
    pick = stalta(stack.data, 5, 3, 1, dt);
    plot(stack.data)
    hold on
    line( [pick, pick] , [ -1, 1] , 'Color', 'r')
    hold off
    pause()
%}
%% Write data to .mat
%{
%folder = fullfile('/media/TerraS/SLAVE', events{num});
%if ~exist( folder, 'dir')
%    mkdir( folder )
%end
%save(fullfile( folder, 'stack.mat'), 'stack')
%}
%% PLOT
%{
%figure(2)

%Y = norm(var(strace, 0, 1));
%numt = size(strace,1);
%figure(3)
%subplot(2,1,1)
%plot(trace(1,:))
%line([w1, w2; w1, w2] , [-1, -1; 1, 1])
%subplot(2,1,2)
%plot(sum(strace(:, w1: round(max(endtimes) /dt) )) / numt )
%}
end
