% Synthetic Recs
close all; clear all
loadtools;
addpath functions
databasedir = '/media/TerraS/database';
station = 'ULM'; %
sacfolder = '/media/TerraS/CN';

dbfile = fullfile(databasedir, [station,'.mat'] );
workingdir = fullfile(sacfolder,station);



load(dbfile)

s  = db.rec(7,:);
p = db.pslow(7);
dt = db.dt;

t1 = db.hk.tps(7);
t2 = db.hk.tpps(7);
t3 = db.hk.tpss(7);
p2 = p^2;

%% R vs H
v = db.hk.v;
r = db.hk.rRange;

f1 = sqrt((r / v).^2 - p2);
f2 = sqrt((1 / v).^2 - p2);

h1 = t1 ./ (f1 - f2);
h2 = t2 ./ (f1 + f2);
h3 = t3 ./ (2*f1);

plot(h1, r, h2, r, h3, r)
axis tight
title('R Vs H')
xlabel('H [km]')
ylabel('R [Vp/Vs]')
%% Vp vs R

v = linspace(5,8,200);
h = db.hk.hbest;


f2 = sqrt((1 ./ v).^2 - p2);

r1 = sqrt( v.^2 .* ((t1/h).^2 + 2 .* (t1/h) .* f2 + f2.^2 + p2) );
r2 = sqrt( v.^2 .* ((t2/h).^2 - 2 .* (t2/h) .* f2 + f2.^2 + p2) );
r3 = sqrt( v.^2 .* ( (t3 / (2*h)).^2 + p2) );

figure()
plot(r1, v, r2, v, r3, v)
axis tight
title('Vp Vs R')
ylabel('Vp [km/s]')
xlabel('R [Vp/Vs]')
%% Vp vs H

v = linspace(5,8,200);
r = db.hk.rbest;

f1 = sqrt((r ./ v).^2 - p2);
f2 = sqrt((1 ./ v).^2 - p2);

h1 = t1 ./ (f1 - f2);
h2 = t2 ./ (f1 + f2);
h3 = t3 ./ (2*f1);

figure()
plot(h1, v, h2, v, h3, v)
axis tight
title('Vp Vs H')
xlabel('H [km]')
ylabel('Vp [km/s]')

%% Planes

v = linspace(5,8,200);
r = db.hk.rRange;

[V, R] = meshgrid(v, r);

f2 = sqrt((1 ./ V).^2 - p2);
f1 = sqrt((R ./ V).^2 - p2);
h1 = t1 ./ (f1 - f2);
h2 = t2 ./ (f1 + f2);
h3 = t3 ./ (2*f1);

figure()
hsurf1 = surf(v,r,h1);
shading flat
hold on
hsurf2 = surf(v,r,h2);
shading flat
hsurf3 = surf(v,r,h3);
shading flat
hold off

set(hsurf1,'FaceColor',[0 0 1],'FaceAlpha',0.5);
set(hsurf2,'FaceColor',[0 1 0],'FaceAlpha',0.5);
set(hsurf3,'FaceColor',[1 0 0],'FaceAlpha',0.5);

%% Error obloid
% 
% res = gridsearch3D(db.rec, db.dt, db.pslow);
% 
% [R,H,V] = meshgrid(res.rRange,res.hRange,res.vRange);
% p = patch(isosurface(R,H,V,res.stackhr, res.smax - 0.005*res.smax));
% isonormals(R,H,V,res.stackhr,p)
% set(p,'FaceColor','red','EdgeColor','none');
% daspect([1,1,1])
% view(3); axis tight
% camlight 
% lighting gouraud
% axis square
% grid on