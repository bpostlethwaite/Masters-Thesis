%% Source Stacker
% Testing P-wave impulse alignment, stacking.
clear all
close all

addpath ../../sac
addpath ../functions
rootdir = '/media/TerraS/CN/';
% data attained using python program eventDistribution.py
event = '0611122127';
stns = {'MLON','ILKN','BOXN','COWN','KNDN','GBLN','YKW3',...
        'JERN','SNPN','YKW2','GLWN','MCKN'};


%% Extract SAC data
for ii = 1 : length(stns)
    files{ii} = fullfile(rootdir, stns{ii}, event, 'stack_P.sac');  %#ok<*SAGROW>
end

[trace, header] = getTrace(files);

%% Strip out stations with unique delta
dt = header{1}.DELTA;
for ii = 1: length(header)
    if dt ~= header{ii}.DELTA
        fprintf('Error, station %s has a unique dt\n', header{ii}.KSTNM)
        dtDiff(ii) = 1;
    end
end

dtDiff = dtDiff == 1;
trace(dtDiff, :) = [];
header(dtDiff) = [];
%% Normalize
trace = (diag(1./max( abs(trace), [], 2)) ) * trace;

%% Collect array of Pick times
for ii = 1 : length(header)
    picktimes(ii) = header{ii}.T1 - header{ii}.B;
    endtimes(ii) = header{ii}.T3 - header{ii}.B; 
end

%% Loop through different windows
endwin = 60: -1 : -20;

for ii = 1:length(endwin)
%% Set a window
w1 = round((min(picktimes) + 0) / dt);
w2 = round((max(endtimes) - endwin(ii) ) / dt);

%% normalize traces
wtrace = (diag(1./max( abs(trace(:, w1 : w2)), [], 2)) ) * trace(:, w1 : w2 );

%% Get lags
[tdel, rmean, sigr] = mccc(wtrace, dt);
%% Shift unwindowed traces
strace = lagshift(trace, tdel, dt);

%% PLOT
%figure(2)
%plot(lagtrace(:, 200:600)')
Y(ii) = norm(var(strace, 0, 1));

numt = size(strace,1);
figure(3)
subplot(3,1,1)
    plot(trace(1,:))
    line([w1, w2; w1, w2] , [-1, -1; 1, 1])
subplot(3,1,2)
    plot(strace(:, 2400:2800)', '--')
    title(sprintf('w2 set at %i, norm of variances = %1.4f', endwin(ii), Y(ii)))
subplot(3,1,3)
    plot(sum(strace(:, 2400:2800)) / numt )
pause(0.1)
end

figure()
plot(Y)

