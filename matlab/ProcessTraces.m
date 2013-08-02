%ProcessTraces
% Script to load up sac files, extract out some info, p-value etc
% Rotate traces, deconvolve traces -> then off to be stacked.
%% Main Control
npb = 2; % Average number of traces per bin
discardBad = 1; % Discard traces that do not find minimum during decon
pscale = @(pslow) wrev(1./pslow.^2 ./ max(1./pslow.^2) )'; % Weight higher slowness traces
fLow = 0.04; % Lower frequency cutoff
fHigh = 2.7; % Upper frequency cutoff
snrlim = .99;
%% 1) Filter Event Directories
%
printinfo = 0; % On and off flag to print out processing results
dlist = filterEventDirs(workingdir, printinfo);
%% 2)  Convert sac file format, filter bad picks
%
picktol = 1; % The picks should be more than PICKTOL seconds apart, or something may be wrong
splitAzimuth = 0;
cluster = 0;
printinfo = 1; % On and off flag to print out processing results
[ptrace, strace, header, pslows, ~] = ...
    ConvertFilterTraces(dlist, pfile, sfile,...
    picktol, printinfo, splitAzimuth, cluster);
%clear picktol printinfo dlist splitAzimuth cluster
%% 3) Bin by p value (build pIndex)
%
numbin = round((1/npb) * size(ptrace, 1));
pbinLimits = linspace(min(pslows) - 0.001, max(pslows) + 0.001, numbin);
checkind = 1;
[pIndex, pbin] = pbinIndexer(pbinLimits, pslows, checkind);
Pslow = pbin(any(pIndex)); % Strip out pbins with no traces
pIndex = pIndex(:,any(pIndex)); % Strip out indices with no traces
nbins = length(Pslow); % Number of bins we now have.
clear numbin pbinLimits checkind
%% 4) Normalize
dt = header{1}.DELTA;
w = max( abs(ptrace), [], 2);
[~, wx] = sort(w, 'descend');
ptrace = diag(1./w) * ptrace;
strace = diag(1./w ) * strace;


%% Setup parallel toolbox
if ~matlabpool('size')
    workers = 4;
    matlabpool('test1', workers)
end
%% 5)  Window with Taper and fourier transform signal.
adj = 0.1; % This adjusts the Tukey window used.
[wft, vft] = TaperWindowFFT(ptrace, strace, header, adj, 0);
clear adj
%% 5) Impulse Response: Stack & Deconvolve
% prep all signals to same length N (power of 2)
% FFT windowed traces and stack in by appropriate pbin
% Build up spectral stack, 1 stack for each p (need to sort traces by
% p and put them into bins, all need to be length n
% Now fft windowed traces
Rec = zeros(nbins,size(wft,2));

parfor ii = 1:nbins
    [r,~,betax(ii)] = simdecf(wft(pIndex(:,ii),:), vft(pIndex(:,ii),:), -1); %#ok<PFBNS>
    Rec(ii,:) = real(ifft(r));
end

% if discardBad flag set simdecf will return Nan arrays where it did not
% find a minimum, the following strips NaNs out and strips out appropriate
% Pslow indices.
clear wft vft
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
clear numPoles
%% RF SnR
if snrlim > 0
    N = round(45 / dt);
    N2 = round(N/2);
    f = (0:(N-1)) * 1 / (N*dt);
    Fs = fft(brec(:, 1:round(45/dt))');
    Fs = conj(Fs(2:N2, :)) .* Fs(2:N2, :);
    Fs = (diag( 1./ max(Fs) ) * Fs')';
    imp = sum(Fs( f(2: N2) < 3, : )) ./ sum(Fs);
    brec( imp < snrlim , : ) = [];
    pslow( imp < snrlim ) = [];
end

%% Rescale by slowness
% Scale by increasing p value
brec =  diag( pscale(pslow) ./ max(abs(brec(:, 1:round(45/dt)) ), [], 2) + 0.001 ) * brec;


%% Run Processing suite

vp = json.(station).wm.Vp;
% Load Mooney Crust 2.0 database Vp estimate
% from stations.json database
%[brec, pslow, Tps, t1, t2] = nlregression(brec, pslow, dt); 

TTps = [];
if strcmp(method, 'bostock')
    [results ] = gridsearchKan(brec(:, 1:round(45/dt)), dt, pslow, vp);   
    TTps = results.tps;
    [ results ] = gridsearchMB(brec(:, 1:round(45/dt)), dt, pslow, TTps);

elseif strcmp(method, 'kanamori')      
    [ results ] = gridsearchKan(brec(:, 1:round(45/dt)), dt, pslow, vp);
    [ boot ] = bootstrap(brec(:, 1:round(45/dt)), dt, pslow, 1024, method, TTps', vp);        
    
elseif strcmp(method, 'fullgrid')      
    [ v, r, h, smaxss] = gridsearch3DC(brec(:, 1:round(45/dt))', dt, pslow, 150);
    %[Vp, R, H, SMax] = bootstrap3D(brec(:, 1:round(45/dt)), dt, pslow, 150, 400);   
    results.r = r;
    results.v = v;
    results.h = h;
    %boot.Vp = Vp;
    %boot.R = R;
    %boot.H = H;
    %boot.SMax = SMax;
    boot = 0;
end

% Run Bootstrap

