%ProcessTraces
% Script to load up sac files, extract out some info, p-value etc
% Rotate traces, deconvolve traces -> then off to be stacked.
%% Main Control
npb = 2; % Average number of traces per bin
discardBad = 1; % Discard traces that do not find minimum during decon
%pscale = @(pslow) wrev(1./pslow.^2 ./ max(1./pslow.^2) )'; % Weight higher slowness traces
pscale = @(pslow) 1;
fLow = 0.04; % Lower frequency cutoff
fHigh = 3.0; % Upper frequency cutoff
wavelet = 0;
snrlim = 0;
%% 1) Filter Event Directories
%
printinfo = 0; % On and off flag to print out processing results
dlist = filterEventDirs(workingdir, printinfo);
%% 2)  Convert sac file format, filter bad picks
%
picktol  = 1; % The picks should be more than PICKTOL seconds apart, or something may be wrong
splitAzimuth = 0;
cluster = 1;
[ptrace, strace, header, pslows, ~] = ...
    ConvertFilterTraces(dlist, pfile, sfile,...
    picktol, printinfo, splitAzimuth, cluster);
%fclose('all'); % Close all open files from reading
clear picktol printinfo dlist splitAzimuth cluster
%% 3) Bin by p value (build pIndex)
%
%numbin = round((1/npb) * size(ptrace, 1));
numbin = 40;
pbinLimits = linspace(min(pslows) - 0.001, max(pslows) + 0.001, numbin);
checkind = 1;
[pIndex, pbin] = pbinIndexer(pbinLimits, pslows, checkind);
Pslow = pbin(any(pIndex)); % Strip out pbins with no traces
pIndex = pIndex(:,any(pIndex)); % Strip out indices with no traces
nbins = length(Pslow); % Number of bins we now have.
clear numbin pbinLimits checkind
%% 4) Normalize
dt = header{1}.DELTA;
ptrace = (diag(1./max( abs(ptrace), [], 2)) ) * ptrace;
strace = (diag(1./max( abs(strace), [], 2)) ) * strace;
%wdiag = 1 * normtrace( ptrace, strace, header, dt , printwdiag);
%ptrace = wdiag * ptrace;
%strace = wdiag * strace;

%% Filter seismograms
% numPoles = 2;
% ptrace = fbpfilt(ptrace, dt, fLow, fHigh, numPoles, 0);
% strace = fbpfilt(strace, dt, fLow, fHigh, numPoles, 0);
% 
% clear numPoles

%% Setup parallel toolbox
if ~matlabpool('size')
    workers = 4;
    matlabpool('local', workers)
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
%% Wavelet denoise

if wavelet > 0
    Jmin = 4;
    options.ti = 1;
    m = 4;    
    T = wavelet;
    
    parfor jj = 1:size(rec,1)
        
        rs = rec(jj, :)';
        
        fTI = zeros(length(rs), 1);
        %T = 0.1;
        % Shift invariant wavelet thresholding
        
        for ii = 1:m;
            %Apply the shift, using circular boundary conditions.
            fS = circshift(rs, ii)';
            
            %Apply here the denoising to fS.
            a = perform_wavelet_transf(fS, Jmin, 1, options);
            aT = perform_thresholding(a, T, 'soft');
            fS = perform_wavelet_transf(aT, Jmin, -1, options);
            
            %After denoising, do the inverse shift.
            fS = circshift(fS, -ii);
            
            %Accumulate the result to obtain at the end the denoised image that
            % average the translated results.
            fTI = (ii-1)/ii*fTI + 1/ii*fS;
        end
        
        wrec(jj, :) = fTI';
        
    end
    %     figure(12234)
    %     subplot(2,1,1)
    %     plot(re(t1 : t2), 'b')
    %     title(sprintf('\beta = %f', betare))
    %     subplot(2,1,2)
    %     plot(fTI(t1 : t2), 'r')
    %     title(sprintf('T = %f', T))
    %     pause(0.5)
    brec = wrec;
end
clear wavelet Jmin options m T
%% 6) Filter Impulse Response
numPoles = 2;
brec = fbpfilt(rec, dt, fLow, fHigh, numPoles, 0);
clear numPoles
%% Rescale by slowness
% Scale by increasing p value
brec =  diag( pscale(pslow) ./ max(abs(brec(:, 1:1200)), [], 2) + 0.001 ) * brec;
%% RF SnR
if snrlim > 0
    snr = zeros(size(brec,1), 1);
    for ii = 1:size(brec,1)
        v = detrend(brec(ii, round(2/dt):round(45/dt)));
        delta = 0.1 * max(abs(v)) + 0.001;
        [maxtab, mintab] = peakdet(v, delta);
        if isempty(maxtab)
            snr(ii) = 0;
            continue
        end
        % To much frequency for given length of signal window
        if length(maxtab) > 60 || size(maxtab,1) < 5
            snr(ii) = 0;
            continue
        end
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
clear maxtab mintab delta v bigpeak noisepeak peakmin peakmax
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

end

% Run Bootstrap
[ boot ] = bootstrap(brec(:, 1:round(45/dt)), dt, pslow, 1048, method, TTps', vp);    
