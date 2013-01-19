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

%% Run ToolChain
% attempt to get two side by side comparisons of events - one using the
% souce stack approach, one using the regular method. If there are problems
% need to get it to compare singular event as it moves  thorugh procssing
% chain.
N = 16384;
vp = json.(station).wm.Vp;
js = loadjson( [userdir,'/thesis/data/stationStackedEvents.json']);
events = cellstr(js.(station));
%db = processStack(db, events, station, workingdir, method, vp);
dlist = {};
slist = {};
for ii = 1:length(events)
    dlist{end+1} = fullfile(workingdir, events{ii});
    slist{end+1} = fullfile('/media/TerraS/SLAVE', events{ii});
end

%% Select trace and Load.
%for sel = 1:length(dlist);
 sel = 5;   
    header = readsac( fullfile(dlist{sel}, 'stack_P.sac'));
    evp = header.DATA1;
    header = rmfield(header, 'DATA1');
    [~, s] = readsac( fullfile(dlist{sel}, 'stack_S.sac'));
    
    if length(s) > N
        s(N+1:end) = [];
    end
    % Pad with zeros if shorter
    if length(s) < N
        s(end+1 : N) = 0;
    end
    
    load(fullfile(slist{sel}, 'stack.mat'));
    stack = stack.data;
    stp = stack' .* tukeywin( length(stack) , 0.1);
    
    %% Detrend and Normalize
    dt = header.DELTA;
    
    % s = detrend(s);
    % evp = detrend(evp);
    % stp = detrend(stp);
    
    s = s / max(s);
    evp = evp / max(evp);
    stp = stp / max(stp);
    
    %% Window with Taper
    b = round( (header.T1 - header.B)/dt );
    e = round( (header.T3 - header.B)/dt );
    
    evp = [zeros(b - 1, 1);...
        evp(b:e) .* tukeywin(length(evp(b:e)), 0.1); ...
        zeros(N - e, 1)];
    
    stp(end : N) = 0;
    
    %% Align Events
    ff = fft([evp, stp], N);
    ccf = real( ifft(conj(ff(:,1)) .* ff(:, 2), N) );
    [~, tcc] = max(ccf);
    
    stp = circshift(stp, -tcc );
    %% Initial plots
    
%     figure()
%     subplot(2,1,1)
%     plot(evp, 'b')
%     subplot(2,1,2)
%     plot(stp, 'r')
    
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
    %re = fbpfilt(re', dt, 0.04, 3, 2, 0);
    %rs = fbpfilt(rs', dt, 0.04, 3, 2, 0);
    
    %% Plot
    t1 = round(2 / dt);
    t2 = round(30 / dt);
    
    figure(13353)
    subplot(2,1,1)
    plot(re(t1 : t2), 'b')
    title(sprintf('\beta = %f', betare))
    subplot(2,1,2)
    plot(rs(t1 : t2), 'r')
    title(sprintf('\beta = %f', betars))
    
    %% Wavelets

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
%%
%pause
%end
%% GridSearch

%% Plot and compare