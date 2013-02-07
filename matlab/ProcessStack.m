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
snrlim = 0.9;
%% Get list of stations within bounds
mindist = 250;
maxdist = 1200;
stns = distantStations(station, mindist, maxdist);
clear mindist maxdist

%% Filter stns for processed-ok / processed-notok stns
kill = zeros(length(stns));
for ii = 1:length(stns)
    if isempty(strfind(json.(stns{ii}).status, 'processed'))
        kill(ii) = 1;
    end
end
stns(kill == 1) = [];
clear kill
%% Get all events in stn directory
printinfo = 0;
dlist = filterEventDirs(workingdir, printinfo);
clear printinfo

cut = @(x) x(end - 9 : end);
events = cellfun(cut, dlist, 'UniformOutput', false);

%% Check for other stn matching events and stack
% Note if you set the fid, all the traces with NANs will be written to a
% file given with the fid. Note this thing appends,,, so turn it off before
% repeates, or use sort & uniq to parse it back.
%fid = fopen([userdir, '/thesis/data/nanfiles.list'], 'a');
fid = 0;
%fid = fopen('/home/bpostlet/thesis/data/nanfiles.list','a');
[stack, event, lags] = stackSources(events, station, stns, fid);

%% filter dlist??
% Either filter list and do not include events that have only 1 stn data or
% also include all the p files for events without other station records.
event = cellfun( @(x) fullfile(workingdir, x), event , 'UniformOutput', false);

%% Select trace and Load.
N = 16384;
parfor ii = 1:length(event);

hdr = readsac( fullfile(event{ii}, 'stack_P.sac'));
evp = hdr.DATA1;
hdr = rmfield(hdr, 'DATA1');
[~, s] = readsac( fullfile(event{ii}, 'stack_S.sac'));

if length(s) > N
    s(N+1:end) = [];
end
% Pad with zeros if shorter
if length(s) < N
    s(end+1 : N) = 0;
end

if length(evp) > N
   evp(N+1:end) = [];
end
% Pad with zeros if shorter
if length(evp) < N
    evp(end+1 : N) = 0;
end

header{ii} = hdr;
pslows(ii) = hdr.USER0; %#ok<*AGROW>
ptrace(ii,:) = evp;
strace(ii,:) = s;

end
%% Sort by pslows
% Sort by ascending pslows
[~,I] = sort(pslows);
header = header(I);
ptrace = ptrace(I,:);
strace = strace(I,:);
stack = stack(I,:);
lags = lags(I);
%% Align Events
dt = header{1}.DELTA;
%fp = fft(ptrace', N);
%fs = fft(stack', N);
%ccf = real( ifft(conj(fp) .* fs, N) );
%[~, ncc] = max(ccf);

stack = lagshift(stack, -lags, dt);
%clear lags
%% Bin by p value (build pIndex)
%
%numbin = round((1/npb) * size(ptrace, 1));
numbin = 40;
pbinLimits = linspace(min(pslows) - 0.001, max(pslows) + 0.001, numbin);
checkind = 1;
[pIndex, pbin] = pbinIndexer(pbinLimits, pslows, checkind);
pslow = pbin(any(pIndex)); % Strip out pbins with no traces
pIndex = pIndex(:,any(pIndex)); % Strip out indices with no traces
nbins = length(pslow); % Number of bins we now have.
clear numbin pbinLimits checkind
%% 4) Normalize
ptrace = (diag(1./max( abs(ptrace), [], 2)) ) * ptrace;
strace = (diag(1./max( abs(strace), [], 2)) ) * strace;
stack = (diag(1./max( abs(stack), [], 2)) ) * stack;
%wdiag = 1 * normtrace( ptrace, strace, header, dt , printwdiag);
%ptrace = wdiag * ptrace;
%strace = wdiag * strace;

%% Setup parallel toolbox
if ~matlabpool('size')
    workers = 4;
    matlabpool('local', workers)
end
%% Window with Taper and fourier transform signal.

pad = 0.1;    % make taper x% wider so we don't cut out source function signal
steps = size(ptrace,1);
n = size(ptrace, 2);
dt = header{1}.DELTA;
adj = 0.1;

parfor ii = 1 : steps
    
    begintaper = round( (header{ii}.T1 - header{ii}.B)/dt );
    endtaper   = round( (header{ii}.T3 - header{ii}.B)/dt );
    Ntaper = endtaper - begintaper;
    npad = round(pad*Ntaper); % Pad 10% before
    Ntaper = Ntaper + npad; % So we don't cut off useful info
    nbegintaper = begintaper - npad;
    if nbegintaper < 1   % We don't want to index off begining of the trace
        nbegintaper = 1;
    end
    
    if nbegintaper + Ntaper - 1 >= n % don't want it to be larger than  array
        Ntaper = n - nbegintaper;
    end
    wft(ii,:) = fft(ptrace(ii,:) .* [ zeros(1, nbegintaper),...
            tukeywin(Ntaper,adj)', zeros(1, n - Ntaper - nbegintaper)]);
        
    sft(ii,:) = fft(stack(ii,:) .* [ zeros(1, nbegintaper),...
            tukeywin(Ntaper,adj)', zeros(1, n - Ntaper - nbegintaper)]);
        
    vft(ii,:) = fft(strace(ii,:));

end 

%% 5) Impulse Response: Stack & Deconvolve
% prep all signals to same length N (power of 2)
% FFT windowed traces and stack in by appropriate pbin
% Build up spectral stack, 1 stack for each p (need to sort traces by
% p and put them into bins, all need to be length n
% Now fft windowed traces

parfor ii = 1:nbins
    [r,~,betax(ii)] = simdecf(wft(pIndex(:,ii),:), vft(pIndex(:,ii),:), -1); %#ok<PFBNS>
    rec(ii,:) = real(ifft(r));
    [rs,~,betax(ii)] = simdecf(sft(pIndex(:,ii),:), vft(pIndex(:,ii),:), -1); %#ok<PFBNS>
    recStack(ii,:) = real(ifft(rs));
end
% if discardBad flag set simdecf will return Nan arrays where it did not
% find a minimum, the following strips NaNs out and strips out appropriate
% Pslow indices.
clear wft vft

%rec = recStack;

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
%% Rescale by slowness
% Scale by increasing p value
brec =  diag( pscale(pslow) ./ max(abs(brec(:, 1:1200)), [], 2)) * brec;
%% RF SnR
if snrlim > 0
    N = round(45 / dt);
    N2 = round(N/2);
    f = (0:(N-1)) * 1 / (N*dt);
    Fs = fft(brec(:, 1:round(45/dt))');
    Fs = conj(Fs(1:N2, :)) .* Fs(1:N2, :);
    Fs = (diag( 1./ max(Fs) ) * Fs')';
    imp = sum(Fs( f(1: N2) < 3, : )) ./ sum(Fs);
    imp = imp < snrlim;
    brec( imp , : ) = [];
    pslow( imp ) = [];
    clear N N2 f Fs imp
end
%% Run Processing suite

vp = json.(station).wm.Vp;


TTps = [];
if strcmp(method, 'bostock')
    [results ] = gridsearchKan(brec(:, 1:round(45/dt)), dt, pslow, vp);   
    TTps = results.tps;
    [ results ] = gridsearchMB(brec(:, 1:round(45/dt)), dt, pslow, TTps);

elseif strcmp(method, 'kanamori')      
    [ results ] = gridsearchKan(brec(:, 1:round(45/dt)), dt, pslow, vp);

end

% Run Bootstrap
[ boot ] = bootstrap(brec(:, 1:round(45/dt)), dt, pslow, 1048, method, TTps', vp);    




%% Old SNR
%{
% if snrlim > 0
%     snr = zeros(size(brec,1), 1);
%     for ii = 1:size(brec,1)
%         v = detrend(brec(ii, round(2/dt):round(45/dt)));
%         delta = 0.1 * max(abs(v)) + 0.001;
%         [maxtab, mintab] = peakdet(v, delta);
%         if isempty(maxtab)
%             snr(ii) = 0;
%             continue
%         end
%         % To much frequency for given length of signal window
%         if length(maxtab) > 60 || size(maxtab,1) < 5
%             snr(ii) = 0;
%             continue
%         end
%         [~,I] = sort(maxtab(:,2),'descend');
%         peakmax = maxtab(I,:);
%         [~ ,I] = sort(mintab(:,2),'ascend');
%         peakmin = mintab(I,:);
%         bigpeak = (0.5 * peakmax(1,2) + 0.3 * peakmax(2, 2) - 0.2 * peakmin(1,2));
%         noisepeak = mean(peakmax(3:end,2)) ;
%         snr(ii) = bigpeak / noisepeak;
%         %{
%          plot(v);
%          hold on
%          plot(peakmax(:,1), peakmax(:,2), 'ro')
%          plot(peakmin(:,1), peakmin(:,2), 'mo')
%          title(sprintf('delta %1.3f SNR = %1.3f', delta, snr(ii)))
%          hold off
%          
%          pause()
%         %}
%     end
%     %brec = diag(snr) * brec;
%     ind = snr < snrlim;
%     brec( ind  , : ) = [];
%     pslow( ind ) = [];
% end
% clear maxtab mintab delta v bigpeak noisepeak peakmin peakmax
%}