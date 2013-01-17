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
sel = 19;

header = readsac( fullfile(dlist{sel}, 'stack_P.sac'));
evp = header.DATA1;
header = rmfield(header, 'DATA1');
[~, s] = readsac( fullfile(dlist{sel}, 'stack_P.sac'));

if length(s) > N
    s(N+1:end) = [];
end
% Pad with zeros if shorter
if length(s) < N
    s(end+1 : N) = 0;
end

ph =  load(fullfile(slist{sel}, 'stack.mat'));
stp = ph.stack.data' .* tukeywin( length(ph.stack.data) );

%% Detrend and Normalize
dt = header.DELTA;

s = detrend(s);
evp = detrend(evp);
stp = detrend(stp);

s = s / max(s);
evp = evp / max(evp);
stp = stp / max(stp);

%% Window with Taper and fourier transform
b = round( (header.T1 - header.B)/dt );
e = round( (header.T3 - header.B)/dt );

evp = [zeros(b - 1, 1);...
    evp(b:e) .* tukeywin(length(evp(b:e)), 0.1); ...
    zeros(N - e, 1)];

stp(end : N) = 0;

wevent = fft(evp);
wstack = fft(stp);
vft = fft(s);

%% Initial plots
figure()
plot(evp, 'b')
hold on
plot(stp, 'r')
hold off
%% Deconvolve
[fre, ~, betax] = simdecf(wevent, vft, -1); 
[frs, ~, betax] = simdecf(wstack, vft, -1); 

re = real(ifft(fre));
rs = real(ifft(frs));

%% Filter
figure()
plot(re, 'b')
hold on
plot(rs, 'r')

%% GridSearch

%% Plot and compare