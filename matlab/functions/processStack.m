function db = processStack(db, events, station, workingdir, method, vp)
%ProcessTraces
% Script to load up sac files, extract out some info, p-value etc
% Rotate traces, deconvolve traces -> then off to be stacked.
%% Main Control
npb = 2; % Average number of traces per bin
discardBad = 0; % Discard traces that do not find minimum during decon
%pscale = @(pslow) wrev(1./pslow.^2 ./ max(1./pslow.^2) )'; % Weight higher slowness traces
pscale = @(pslow) 1;
fLow = 0.04; % Lower frequency cutoff
fHigh = 3.0; % Upper frequency cutoff
snrlim = 0;
%% 1) Filter Event Directories
%
printinfo = 0; % On and off flag to print out processing results


dlist = {};
slist = {};

for ii = 1:length(events)
    d = events{ii};
    dlist{end+1} = fullfile(workingdir, d);  %#ok<*AGROW>
    slist{end+1} = fullfile('/media/TerraS/SLAVE', d);
end

assert(length(dlist) > 1,'No Directories accumulated in Dlist!')

%% Load Stacks and re-filter dlist
pfile = 'stack.mat';
sfile = 'stack_S.sac';
picktol  = 1; % The picks should be more than PICKTOL seconds apart, or something may be wrong
[strace, header, ptrace, pheader, pslows, badpick] = ...
    loadStacktraces(dlist, pfile, slist, sfile, picktol, printinfo);
    

%% 3) Bin by p value (build pIndex)
%
numbin = round((1/npb) * size(ptrace, 1));
pbinLimits = linspace(min(pslows) - 0.001, max(pslows) + 0.001, numbin);
checkind = 1;
[pIndex, pbin] = pbinIndexer(pbinLimits, pslows, checkind);
Pslow = pbin(any(pIndex)); % Strip out pbins with no traces
pIndex = pIndex(:,any(pIndex)); % Strip out indices with no traces
nbins = length(Pslow); % Number of bins we now have.

%% 4) Normalize
dt = header{1}.DELTA;
strace = diag(1./max(strace,[],2)) * strace;
%% Setup parallel toolbox
if ~matlabpool('size')
    workers = 4;
    matlabpool('local', workers)
end
%% 5)  Window with Taper and fourier transform signal.
adj = 0.1; % This adjusts the Tukey window used.
pad = 0.1;    % make taper x% wider so we don't cut out source function signal

for ii = 1 : size(ptrace,1)
    wft(ii,:) = fft(ptrace(ii,:));
    vft(ii,:) = fft(strace(ii,:));
end 

%% 5) Impulse Response: Stack & Deconvolve
% prep all signals to same length N (power of 2)
% FFT windowed traces and stack in by appropriate pbin
% Build up spectral stack, 1 stack for each p (need to sort traces by
% p and put them into bins, all need to be length n
% Now fft windowed traces
Rec = zeros(nbins, size(wft, 2));
parfor ii = 1:nbins
    [r,~,betax(ii)] = simdecf(wft(pIndex(:,ii),:), vft(pIndex(:,ii),:), -1); %#ok<PFBNS>
    Rec(ii,:) = real(ifft(r));
end
% if discardBad flag set simdecf will return Nan arrays where it did not
% find a minimum, the following strips NaNs out and strips out appropriate
% Pslow indices.
%% Renew
% So we don't have to run simdecf again to renew variables in manual rerun
rec = Rec;
pslow = Pslow;
%% Weed out poor rf results
% Cut out traces where no betax was found during simdecf
if discardBad
    ind = isinf(betax);
    rec( ind  , : ) = [];
    pslow( ind ) = [];
end
%% 6) Filter Impulse Response
numPoles = 2;
brec = fbpfilt(rec, dt, fLow, fHigh, numPoles, 0);
%% Rescale by slowness
% Scale by increasing p value
brec =  diag( pscale(pslow) ./ max(abs(brec(:, 1:1200)), [], 2)) * brec;
%% RF SnR
if snrlim > 0
    snr = zeros(size(brec,1), 1);
    for ii = 1:size(brec,1)
        v = detrend(brec(ii, round(2.5/dt):round(45/dt)));
        delta = 0.1 * max(abs(v));
        [maxtab, mintab] = peakdet(v, delta);
        [~,I] = sort(maxtab(:,2),'descend');
        peakmax = maxtab(I,:);
        [~ ,I] = sort(mintab(:,2),'ascend');
        peakmin = mintab(I,:);
        bigpeak = (0.5 * peakmax(1,2) + 0.3 * peakmax(2, 2) - 0.2 * peakmin(1,2));
        noisepeak = mean(peakmax(3:end,2)) ;
        snr(ii) = bigpeak / noisepeak;
%{        
         plot(v);
         hold on
         plot(peakmax(:,1), peakmax(:,2), 'ro')
         plot(peakmin(:,1), peakmin(:,2), 'mo')
         title(sprintf('delta %1.3f SNR = %1.3f', delta, snr(ii)))
         hold off
         pause()   
%}
    end
    %brec = diag(snr) * brec;
    ind = snr < snrlim;
    brec( ind  , : ) = [];
    pslow( ind ) = [];
end
%% Run Processing suite
TTps = [];
if strcmp(method, 'bostock')
    [ results ] = gridsearchKan(brec(:, 1:round(45/dt)), dt, pslow, vp);   
    TTps = results.tps;
    [ results ] = gridsearchMB(brec(:, 1:round(45/dt)), dt, pslow, TTps);

elseif strcmp(method, 'kanamori')      
    [ results ] = gridsearchKan(brec(:, 1:round(45/dt)), dt, pslow, vp);

end

% Run Bootstrap

[ boot ] = bootstrap(brec(:, 1:round(45/dt)), dt, pslow, 1024 , method, TTps', vp);   

%% Assign Data
[ db ] = assigndb( db, method, station, brec(:,1:round(45/dt)), ...
                   pslow, dt, npb, fLow, fHigh, results, boot);
