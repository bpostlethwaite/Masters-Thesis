% Plot 3D sections

clear all;
close all
loadtools;

addpath functions
addpath([userdir,'/programming/matlab/subtightplot'])

opts = {[.001, .05], [0.05, .02], [.1, .15]};
subplot = @(m,n,p) subtightplot(m,n,p,opts{:}); 

database = '/media/bpostlet/TerraS/database';


station1 = 'DORN';
dbfile = fullfile(database, [station1, '.mat']);

load(dbfile)


%% Run FullGridsearch
lim = 150;
[v1, r1, h1, s1, V1, R1, H1, stack] = gridsearch3DC_stack( db.rec', db.dt, db.pslow', lim );



figure(2)
subplot(1,2,1)
p2 = db.pslow.^2;

f1 = sqrt((r1 / v1)^2 - p2);
f2 = sqrt((1 / v1)^2 - p2);
tps = h1 * (f1 - f2);
tpps = h1 * (f1 + f2);
tpss = h1 * 2 * f1;

csection(db.rec(:, 1 : round(26/db.dt)), 0, db.dt);
axis square
hold on
plot(tps,'k+')
plot(tpps,'k+')
plot(tpss,'k+')
hold off



ms = max(stack);
stack = stack/ms;
s1 = s1/ms;

stdR1 = db.fg.stdR;
stdVp1 = db.fg.stdVp;
stdH1 = db.fg.stdH;
stdS1 = db.fg.stdS / ms;
%% Cube results
G = reshape(stack, lim, lim, lim); % G(h,r,v)
%% Slice through stack

% slice through optimum r
tmp = abs(R1 - r1);
[~, idx] = min(tmp);
vhslice1 = squeeze(G(:,idx,:));
% slice through optimum h
tmp = abs(H1 - h1);
[~, idx] = min(tmp);
vrslice1 = squeeze(G(idx,:,:));
% slice through optimum v
tmp = abs(V1 - v1);
[~, idx] = min(tmp);
rhslice1 = squeeze(G(:,:,idx));
clear tmp

top1 = max( [max(max(vhslice1)), ...
    max(max(vrslice1)), ...
    max(max(rhslice1))] );
bottom1 = min( [min(min(vhslice1)), ...
    min(min(vrslice1)), ...
    min(min(rhslice1))] );
    


station2 = 'ULM';
dbfile = fullfile(database, [station2, '.mat']);

load(dbfile)




%% Run FullGridsearch
lim = 150;
[v2, r2, h2, s2, V2, R2, H2, stack] = gridsearch3DC_stack( db.rec', db.dt, db.pslow', lim );

subplot(1,2,2)
p2 = db.pslow.^2;

f1 = sqrt((r2 / v2)^2 - p2);
f2 = sqrt((1 / v2)^2 - p2);
tps = h2 * (f1 - f2);
tpps = h2 * (f1 + f2);
tpss = h2 * 2 * f1;

csection(db.rec(:, 1 : round(26/db.dt)), 0, db.dt);
axis square
hold on
plot(tps,'k+')
plot(tpps,'k+')
plot(tpss,'k+')
hold off




ms = max(stack);
stack = stack/ms;
s2 = s2/ms;

stdR2 = db.fg.stdR;
stdVp2 = db.fg.stdVp;
stdH2 = db.fg.stdH;
stdS2 = db.fg.stdS / ms;
%% Cube results
G = reshape(stack, lim, lim, lim); % G(h,r,v)
%% Slice through stack

% slice through optimum r
tmp = abs(R2 - r2);
[~, idx] = min(tmp);
vhslice2 = squeeze(G(:,idx,:));
% slice through optimum h
tmp = abs(H2 - h2);
[~, idx] = min(tmp);
vrslice2 = squeeze(G(idx,:,:));
% slice through optimum v
tmp = abs(V2 - v2);
[~, idx] = min(tmp);
rhslice2 = squeeze(G(:,:,idx));
clear tmp

top2 = max( [max(max(vhslice1)), ...
    max(max(vrslice1)), ...
    max(max(rhslice1))] );
bottom2 = min( [min(min(vhslice1)), ...
    min(min(vrslice1)), ...
    min(min(rhslice1))] );

top = max([top1,top2]);
bottom = min([bottom1,bottom2]);


figure(1)
%%%
subplot(2,3,1)
plotSlice(station1, h1, v1, '', 'Vp [km/s]',...
    s1, stdH1, stdVp1, stdS1, H1, V1, vhslice1')

caxis manual
caxis([bottom top]);
%%%
subplot(2,3,2)
plotSlice(station1, r1, v1, '', 'Vp [km/s]',...
    s1, stdR1, stdVp1, stdS1, R1, V1, vrslice1')

caxis manual
caxis([bottom top]);
%%%
subplot(2,3,3)
plotSlice(station1, h1, r1, '', 'R',...
    s1, stdH1, stdR1, stdS1, H1, R1, rhslice1')

caxis manual
caxis([bottom top]);
%%%
%%%
subplot(2,3,4)
plotSlice(station2, h2, v2, 'H [km]', 'Vp [km/s]',...
    s2, stdH2, stdVp2, stdS2, H2, V2, vhslice2')

caxis manual
caxis([bottom top]);
%%%
subplot(2,3,5)
plotSlice(station2, r2, v2, 'R', 'Vp [km/s]',...
    s2, stdR2, stdVp2, stdS2, R2, V2, vrslice2')

caxis manual
caxis([bottom top]);
%%%
subplot(2,3,6)
plotSlice(station2, h2, r2, 'H [km]', 'R',...
    s2, stdH2, stdR2, stdS2, H2, R2, rhslice2')

caxis manual
caxis([bottom top]);

axes('Position', [0.05 0.15 0.95 0.7], 'Visible', 'off');
% Set colormap.
r1=[(0:31)/31,ones(1,32)];
g1=[(0:31)/31,(31:-1:0)/31];
b1=[ones(1,32),(31:-1:0)/31];
rwb=[r1',g1',b1'];
colormap(rwb);
%colormap(flipud(colormap('jet')))
colorbar;



%title(sprintf('%s', station) )



