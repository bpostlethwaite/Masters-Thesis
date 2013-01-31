% Side by side comparison of the stacked approach and the single-event
% source method.

clear all
close all
loadtools;
addpath ../../sac
addpath ../functions
addpath([userdir,'/programming/matlab/jsonlab'])
%% Variables
sacfolder = '/media/TerraS/CN';
databasedir = '/media/TerraS/database';
pfile = 'stack_P.sac';
sfile = 'stack_S.sac';
load ../stnsjson.mat
%% Setup parallel toolbox
if ~matlabpool('size')
    workers = 4;
    matlabpool('local', workers)
end
%%  Select Station to Process and load station data
method = 'kanamori';
station = 'ACKN';


dbfile = fullfile(databasedir, [station,'.mat'] );
workingdir = fullfile(sacfolder,station);
clear db dbold
if exist(dbfile, 'file')
    load(dbfile)
    dbold = db;
else
    db = struct();
end

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
fid = 0;
%fid = fopen('/home/bpostlet/thesis/data/nanfiles.list','a');
[stack, event] = stackSources(events, station, stns, fid);
%% filter dlist??
% Either filter list and do not include events that have only 1 stn data or
% also include all the p files for events without other station records.
event = cellfun( @(x) fullfile(workingdir, x), event , 'UniformOutput', false);
%% Run ToolChain
% attempt to get two side by side comparisons of events - one using the
% souce stack approach, one using the regular method. If there are problems
% need to get it to compare singular event as it moves  thorugh procssing
% chain.
N = 16384;
vp = json.(station).wm.Vp;

%% Select trace and Load.
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
[pslows,I] = sort(pslows);
header = header(I);
ptrace = ptrace(I,:);
strace = strace(I,:);
stack = stack(I,:);
%% Normalize
dt = header{1}.DELTA;
ptrace = (diag(1./max( abs(ptrace), [], 2)) ) * ptrace;
strace = (diag(1./max( abs(strace), [], 2)) ) * strace;
stack =  (diag(1./max( abs(stack), [], 2)) ) * stack;

%% Align Events
fp = fft(ptrace', N);
fs = fft(stack', N);
ccf = real( ifft(conj(fp) .* fs, N) );
[~, ncc] = max(ccf);

stack = lagshift(stack, ncc);

%% Initial plots
%
ind = 4;
figure()
    plot(ptrace(ind, :), 'b')
    hold on
    plot(stack(ind, :), 'r')
    hold off
%}
%% Window with Taper
parfor ii = 1 : size( stack, 1)
    
    pt = ptrace(ii, :)';
    st = stack(ii, :)';
    s = strace(ii, :)';    
    hdr = header{ii};
    
    b = round( (hdr.T1 - hdr.B)/dt );
    e = round( (hdr.T3 - hdr.B)/dt );
    
    pt = [zeros(b - 1, 1);...
        pt(b:e) .* tukeywin(length(pt(b:e)), 0.1); ...
        zeros(N - e, 1)];
    
    st = [zeros(b - 1, 1);...
        st(b:e) .* tukeywin(length(st(b:e)), 0.1); ...
        zeros(N - e, 1)];
    

    %% Fourier transform
    wevent(ii, :) = fft(pt);
    wstack(ii, :) = fft(st);
    vft(ii, :) = fft(s);
end

%% 3) Bin by p value (build pIndex)
%
%numbin = round((1/npb) * size(ptrace, 1));
numbin = 50;
pbinLimits = linspace(min(pslows) - 0.001, max(pslows) + 0.001, numbin);
checkind = 1;
[pIndex, pbin] = pbinIndexer(pbinLimits, pslows, checkind);
Pslow = pbin(any(pIndex)); % Strip out pbins with no traces
pIndex = pIndex(:,any(pIndex)); % Strip out indices with no traces
nbins = length(Pslow); % Number of bins we now have.

%% Deconvolve
parfor ii = 1 : nbins
[fre, ~, betare(ii)] = simdecf(wevent(ii, :), vft(ii, :), -1);
[frs, ~, betars(ii)] = simdecf(wstack(ii, :), vft(ii, :), -1);

re(ii, :) = real(ifft(fre));
rs(ii, :) = real(ifft(frs));
end
%% Filter
re = fbpfilt(re, dt, 0.04, 3, 2, 0);
rs = fbpfilt(rs, dt, 0.04, 3, 2, 0);

%% Plot
%{
t1 = round(2 / dt);
t2 = round(30 / dt);

figure(13353)
subplot(2,1,1)
plot(re(t1 : t2), 'b')
title(sprintf('\beta = %f', betare))
subplot(2,1,2)
plot(rs(t1 : t2), 'r')
title(sprintf('\beta = %f', betars))
%}
%% Wavelets
%{
% Just keep the first 35 seconds or so of the rec function. or whatever we
% are using in the main processing scripts.
Jmin = 4;
options.ti = 1;
m = 4;
t2 = N/4;
re = re(1:t2);
rs = rs(1:t2);

for T = 0.01:0.01:0.2
    
    fTI = zeros(t2, 1);
    %T = 0.1;
    % Shift invariant wavelet thresholding
    
    for ii = 1:m;
        %Apply the shift, using circular boundary conditions.
        fS = circshift(rs, ii);
        
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
    
    figure(12234)
    subplot(2,1,1)
    plot(re(t1 : t2), 'b')
    title(sprintf('\beta = %f', betare))
    subplot(2,1,2)
    plot(fTI(t1 : t2), 'r')
    title(sprintf('T = %f', T))
    pause(0.5)
end
%}
%% Run Processing suite
TTps = [];
pslow = Pslow;
brec = re;
fLow = 1;
fHigh = 1;

if strcmp(method, 'bostock')
    [results ] = gridsearchKan(brec(:, 1:round(45/dt)), dt, pslow, vp);   
    TTps = results.tps;
    [ results ] = gridsearchMB(brec(:, 1:round(45/dt)), dt, pslow, TTps);

elseif strcmp(method, 'kanamori')      
    [ results ] = gridsearchKan(brec(:, 1:round(45/dt)), dt, pslow, vp);

end

% Run Bootstrap
[ boot ] = bootstrap(brec(:, 1:round(45/dt)), dt, pslow, 1048, method, TTps', vp); 

[ dbre ] = assigndb( db, method, station, brec(:,1:round(45/dt)), ...
    pslow, dt, npb, fLow, fHigh, results, boot);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
brec = rs;
if strcmp(method, 'bostock')
    [results ] = gridsearchKan(brec(:, 1:round(45/dt)), dt, pslow, vp);   
    TTps = results.tps;
    [ results ] = gridsearchMB(brec(:, 1:round(45/dt)), dt, pslow, TTps);

elseif strcmp(method, 'kanamori')      
    [ results ] = gridsearchKan(brec(:, 1:round(45/dt)), dt, pslow, vp);

end

% Run Bootstrap
[ boot ] = bootstrap(brec(:, 1:round(45/dt)), dt, pslow, 1048, method, TTps', vp); 


[ dbrs ] = assigndb( db, method, station, brec(:,1:round(45/dt)), ...
    pslow, dt, npb, fLow, fHigh, results, boot);


%% Plot and compare

close all
plotStack(dbrs, method);

if strcmp(method, 'bostock')
    fprintf('Vp is %f +/- %1.3f \n',db.mb.vbest, db.mb.stdVp )
    fprintf('R is %f +/- %1.3f \n',db.mb.rbest, db.mb.stdR )
    fprintf('H is %f +/- %1.3f \n',db.mb.hbest, db.mb.stdH )
    if exist('dbold','var')
        if isfield(dbold,'mb')
            fprintf('Old MB Vp is %f +/- %1.3f \n',dbold.mb.vbest, dbold.mb.stdVp )
            fprintf('Old MB R is %f +/- %1.3f \n',dbold.mb.rbest, dbold.mb.stdR )
            fprintf('Old MB H is %f +/- %1.3f \n',dbold.mb.hbest, dbold.mb.stdH )
        end
        if isfield(dbold,'hk')
            fprintf('Old hk R is %f +/- %1.3f \n',dbold.hk.rbest, dbold.hk.stdR )
            fprintf('Old hk H is %f +/- %1.3f \n',dbold.hk.hbest, dbold.hk.stdH )
        end
    end
end

if strcmp(method, 'kanamori')
    fprintf('R is %f +/- %1.3f \n',db.hk.rbest, db.hk.stdR )
    fprintf('H is %f +/- %1.3f \n',db.hk.hbest, db.hk.stdH )
    if exist('dbold','var')
        if isfield(dbold,'hk')
            fprintf('Old hk R is %f +/- %1.3f \n',dbold.hk.rbest, dbold.hk.stdR )
            fprintf('Old hk H is %f +/- %1.3f \n',dbold.hk.hbest, dbold.hk.stdH )
        end
        if isfield(dbold,'mb')
            fprintf('Old MB R is %f +/- %1.3f \n',dbold.mb.rbest, dbold.mb.stdR )
            fprintf('Old MB H is %f +/- %1.3f \n',dbold.mb.hbest, dbold.mb.stdH )
            fprintf('Old MB Vp is %f +/- %1.3f \n',dbold.mb.vbest, dbold.mb.stdVp )
        end
    end
end

