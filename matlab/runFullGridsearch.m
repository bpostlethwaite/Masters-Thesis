% Run fullgrid search

clear all;
close all
loadtools;


addpath functions
addpath ../sac
addpath functions
addpath sourceStack
addpath([userdir,'/programming/matlab/toolbox_general'])
addpath([userdir,'/programming/matlab/toolbox_signal'])
addpath([userdir,'/programming/matlab/jsonlab'])
%% Variables
sacfolder = '/media/bpostlet/TerraS/CN';
database = '/media/TerraS/database';
databasedir = '/media/bpostlet/TerraS/database';

station = 'ULM';

dbfile = fullfile(databasedir, [station,'.mat'] );
workingdir = fullfile(sacfolder,station);
clear db dbold
load(dbfile)

%% Run FullGridsearch
lim = 150;
[V, R, H, HRx, v, r, h, stack3d] = gridsearch3DC_stack( db.rec', db.dt, db.pslow', lim );


G = reshape(stack3d, lim, lim, lim); % G(h,r,v)

%% Find optimum R slice

tmp = abs(r - db.fg.rbest);
[~, idx] = min(tmp);
clear tmp

Rslice = squeeze(G(:,idx,:));

%% Plot section

figure()
set(gca,'FontName','Helvetica','FontSize',16,...
    'Clipping','off','layer','top');
imagesc(h, v, Rslice);
axis xy
axis square
colorbar
hold on
plot(db.fg.hbest, db.fg.vbest, 'w+')
plot(db.fg.hbest, db.fg.vbest, 'ko')
contour(h, v, Rslice,...
    [HRx - db.mb.stdsmax, HRx - db.mb.stdsmax], 'k-')
hold off
xlab=xlabel('R');
ylab=ylabel('V_P [km/s]');
set(xlab,'FontName','Helvetica','FontSize',16);
set(ylab,'FontName','Helvetica','FontSize',16);
title(sprintf('%s\nVp = %1.3f +/- %1.3f km/s\nR = %1.3f +/- %1.3f',...
    db.station, db.mb.vbest, db.mb.stdVp, db.mb.rbest, db.mb.stdR));



