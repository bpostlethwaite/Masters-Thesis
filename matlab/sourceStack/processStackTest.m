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
for ii = 1:length(event);

hdr = readsac( fullfile(event{ii}, 'stack_P.sac'));
evp = hdr.DATA1;
hdr = rmfield(hdr, 'DATA1');
[~, s] = readsac( fullfile(event{ii}, 'stack_S.sac'));

dt = hdr.DELTA;

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
%% Normalize
ptrace = (diag(1./max( abs(ptrace), [], 2)) ) * ptrace;
strace = (diag(1./max( abs(strace), [], 2)) ) * strace;
stack =  (diag(1./max( abs(stack), [], 2)) ) * stack;

%% Align Events
fp = fft(ptrace, N);
fs = fft(stack, N);
ccf = real( ifft(conj(fp) .* fs, N) );
[~, tcc] = max(ccf);

stack = lagshift(stack, -tcc, dt);

%% Window with Taper
b = round( (header.T1 - header.B)/dt );
e = round( (header.T3 - header.B)/dt );
e = e;
evp = [zeros(b - 1, 1);...
    evp(b:e) .* tukeywin(length(evp(b:e)), 0.1); ...
    zeros(N - e, 1)];

stp = [zeros(b - 1, 1);...
    stp(b:e) .* tukeywin(length(stp(b:e)), 0.1); ...
    zeros(N - e, 1)];

%% Initial plots
%{
    figure()
    plot(evp, 'b')
    hold on
    plot(stp, 'r')
    hold off
%}
%% Fourier transform
wevent = fft(evp);
wstack = fft(stp);
vft = fft(s);

%% Deconvolve
[fre, ~, betare] = simdecf(wevent, vft, -1);
[frs, ~, betars] = simdecf(wstack, vft, -1);

re = real(ifft(fre));
rs = real(ifft(frs));

%% Filter
re = fbpfilt(re', dt, 0.04, 3, 2, 0);
rs = fbpfilt(rs', dt, 0.04, 3, 2, 0);

%% Plot
%{
t1 = round(2 / dt);
t2 = round(30 / dt);

% figure(13353)
% subplot(2,1,1)
% plot(re(t1 : t2), 'b')
% title(sprintf('\beta = %f', betare))
% subplot(2,1,2)
% plot(rs(t1 : t2), 'r')
% title(sprintf('\beta = %f', betars))
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
%%
%pause
%% GridSearch

%% Plot and compare