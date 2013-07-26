% Plot 3D sections

clear all;
close all

addpath functions

database = '/media/bpostlet/TerraS/database';


station = 'DORN';
dbfile = fullfile(database, [station, '.mat']);

load(dbfile)


%% Run FullGridsearch
lim = 150;
[v, r, h, s, V, R, H, stack] = gridsearch3DC_stack( db.rec', db.dt, db.pslow', lim );

%% Cube results
G = reshape(stack, lim, lim, lim); % G(h,r,v)
%% Slice H vs Vp

% slice through optimum r
tmp = abs(R - r);
[~, idx] = min(tmp);
slice = squeeze(G(:,idx,:));
clear tmp

plotSlice(station, h, v, 'H', 'Vp',...
    s, db.fg.stdH, db.fg.stdVp, db.fg.stdS, H, V, slice')

%% Slice R vs Vp

% slice through optimum h
tmp = abs(H - h);
[~, idx] = min(tmp);
slice = squeeze(G(idx,:,:));
clear tmp

plotSlice(station, r, v, 'R', 'Vp',...
    s, db.fg.stdR, db.fg.stdVp, db.fg.stdS, R, V, slice')

%% Slice H vs R

% slice through optimum v
tmp = abs(V - v);
[~, idx] = min(tmp);
slice = squeeze(G(:,:,idx));
clear tmp

plotSlice(station, h, r, 'H', 'R',...
    s, db.fg.stdH, db.fg.stdR, db.fg.stdS, H, R, slice')

%% Csection
figure()
p2 = db.pslow.^2;

f1 = sqrt((r / v)^2 - p2);
f2 = sqrt((1 / v)^2 - p2);
tps = h * (f1 - f2);
tpps = h * (f1 + f2);
tpss = h * 2 * f1;

csection(db.rec(:, 1 : round(26/db.dt)), 0, db.dt);
hold on
plot(tps,'k+')
plot(tpps,'k+')
plot(tpss,'k+')
title(sprintf('%s', station) )
hold off

figure(2)
