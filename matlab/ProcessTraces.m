%ProcessTraces
% Script to load up sac files, extract out some info, p-value etc
% Rotate traces, deconvolve traces -> then off to be stacked.

loadtools;
thresh = 0;
%% 1) Filter Event Directories
%
printinfo = 0; % On and off flag to print out processing results
dlist = filterEventDirs(workingdir,printinfo);
%% 2)  Convert sac file format, filter bad picks
%
picktol  = 2; % The picks should be more than PICKTOL seconds apart, or something may be wrong
[ptrace,strace,header,pslows,badpicks] = ...
    ConvertFilterTraces(dlist,pfile,sfile,picktol,printinfo);
fclose('all'); % Close all open files from reading
%% 3) Bin by p value (build pIndex)
%
npb = 2; % Average number of traces per bin
numbin = round((1/npb)*size(ptrace,1));
pbinLimits = linspace(.035,.08,numbin);
checkind = 1;
[pIndex, pbin] = pbinIndexer(pbinLimits, pslows, checkind);
pslow = pbin(any(pIndex)); % Strip out pbins with no traces
pIndex = pIndex(:,any(pIndex)); % Strip out indices with no traces
nbins = length(pslow); % Number of bins we now have.
%% 4) Normalize
modnorm = 0;
dt = header{1}.DELTA;
if modnorm
    modratio = zeros(1,size(ptrace,1));
    
    for ii = 1:size(ptrace,1)
        t1 = round( (header{ii}.T1 - header{ii}.B) / dt);
        t3 = round( (header{ii}.T3 - header{ii}.B) / dt);
        t0 = t1 - round(20/dt);
        if t0 < 1
            t0 = 1;
        end
        m1 = var(ptrace(ii,  t1 : t3 ));
        m0 = var(ptrace(ii, t0 : t1 - round(2/dt)));
        modratio(ii) = m1/m0;

    end

    modratio(modratio < 20) = 1;
    modratio( (modratio < 100) & (modratio > 1) ) = 2;
    modratio(modratio < 500 & modratio > 2) = 3;
    modratio(modratio > 5) = 4;
    ptrace = diag(modratio) * diag(1./max(ptrace,[],2)) * ptrace;
    strace = diag(modratio) * diag(1./max(strace,[],2)) * strace;

else
    ptrace = diag(1./max(ptrace,[],2)) * ptrace;
    strace = diag(1./max(strace,[],2)) * strace;
end

%% 5)  Window with Taper and fourier transform signal.
viewtaper  = 0;
adj = 0.1; % This adjusts the Tukey window used.
[wft,vft,WIN] = TaperWindowFFT(ptrace,strace,header,adj,viewtaper);
%% Setup parallel toolbox
if ~matlabpool('size')
    workers = 4;
    matlabpool('local', workers)
end
%% 5) Impulse Response: Stack & Deconvolve
% prep all signals to same length N (power of 2)
% FFT windowed traces and stack in by appropriate pbin
% Build up spectral stack, 1 stack for each p (need to sort traces by
% p and put them into bins, all need to be length n
% Now fft windowed traces
viewFncs = 0;
discardBad = 0;
rec = zeros(nbins,size(wft,2));
parfor ii = 1:nbins
    [r,~,~] = simdecf(wft(pIndex(:,ii),:), vft(pIndex(:,ii),:), -1, viewFncs, discardBad);
    rec(ii,:) = real(ifft(r));
end

% if discardBad flag set simdecf will return Nan arrays where it did not
% find a minimum, the following strips NaNs out and strips out appropriate
% Pslow indices.
if discardBad
    ind = isnan(rec(:,1));
    rec( ind  , : ) = [];
    pslow( ind ) = [];
end
%% 6) Filter Impulse Response
if loadflag
    fLow = db.filterLow;
    fHigh = db.filterHigh;
else
    fLow = 0.04;
    fHigh = 1.1;
end    
numPoles = 2;
brec = fbpfilt(rec,dt,fLow,fHigh,numPoles,0);
%brec = rec;
%% Run a few L1 iterations
%{
userdir = getenv('HOME');
f = fullfile(userdir, 'programming','matlab'); %Set base path
addpath(genpath([f,'/spotbox-v1.0/'])) %Path to spot toolbox
addpath(genpath([f,'/spotbox-v1.0/+spot/+rwt'])) 
addpath(genpath([f,'/spgl1'])) %Path to L1 solver
addpath(genpath([f,'/spotbox-v1.0/Splines'])) %Path to rice toolbox

parfor ii = 1:nbins
    lrec(ii,:) = L1crank(ptrace(pIndex(:,ii),:), strace(pIndex(:,ii),:),rec(ii,:), 10);
end
%}
%% Rescale by slowness
% Scale by increasing p value
pscale = (pslow + min(pslow)).^2;
pscale = pscale/max(pscale);

for ii=1:size(brec,1);
    brec(ii,:) = brec(ii,:)/max(abs(brec(ii,1:1200))) * pscale(ii);
    %brec(ii,:)=brec(ii,:)/pslow(ii)^.2;    
end
%% Curvelet Denoise
%{
thresh = 0.3;
brec = performCurveletDenoise(brec,dt,thresh);
%}

%% 7) Get tps and IRLS Newtons Method to find regression Tps
if loadflag
    t1 = db.t1; 
    t2 = db.t2;
else
    t1 = 2.0;
    t2 = 6.5;
end
adjbounds = true;
while adjbounds
     
    [~,it] = max(brec(:,round(t1/dt) + 1: round(t2/dt)) + 1,[],2);
    tps = (it + round(t1/dt)-1)*dt;
    h = figure(3311);
        plot(1:length(tps),tps,'*')
        title('Check bounds and tighten and adjust accordingly')
    t1n = input('Enter a new lower bound or 0 to skip process: ');
    if t1n ~= 0
        t1 = t1n;
        t2n = input('Enter a new higher bound or 0 to skip process: ');
        if t2n ~= 0
            t2 = t2n;
        end
    end
    if t1n == 0 || t2n == 0
        adjbounds = false;
    end

end
close(h)
% Copy final agreed values for saving.
% Starting guesses for physical paramaters
% The conditional system is a crude way of stabilizing newtons method by
% a smarter first guess based on the mean P/S travel time difference
if mean(tps) < 4
    H = 30; 
elseif mean(tps) < 4.4
    H = 33;
elseif mean(tps) < 4.6
    H = 36;
else
    H = 40;
end
alpha = 6.6;
beta = 3.5;
tol = 1e-4;  % Tolerance on interior linear solve is 10x of Newton solution
itermax = 300; % Stop if we go beyond this iteration number
damp = 0.2;
warning off MATLAB:plot:IgnoreImaginaryXYPart
warning off MATLAB:nearlySingularMatrix
[ Tps,H,alpha,beta ] = newtonFit(H,alpha,beta,pslow',tps,itermax,tol,damp);

%% 8) Grid and Line Search
[ results ] = GridSearch( brec(:,1:round(45/dt)), Tps', dt, pslow);
%[ results ] = GsearchKanamori(brec,dt,pslow);
%% 9) Bootstrap Error calculation
nmax = 1024; % number of bootstrap iterations
[bootVp, bootR, bootH, bootVpRx, bootHx] = bootstrap( brec(:,1:round(45/dt)), Tps, dt, pslow, nmax);
%% Close parallel system
%matlabpool close
%% Viewers
%{
    
    figure(567)
    bar(pbin,sum(pIndex,1))
    title(sprintf('pvalue histogram from station %s',station))
    xlabel('pvalue')
    ylabel('number of traces in pbin')
%}
%%
% View Earth Response
%{
t = [1:size(brec,2)] * dt;
    for ii = 1:size(brec,1)
        figure(5)
        plot(brec(ii,round(t1/dt) + 1: round(t2/dt)))
        title(sprintf('trace %i',ii))
        %hold on
        %plot(brtrace(ii,:))
        pause(1)
    end
%}


