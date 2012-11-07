clear all
close all
loadtools;
addpath functions
addpath([userdir,'/programming/matlab/jsonlab'])
addpath(genpath([userdir,'/programming/matlab/mpt/']));
%json = loadjson([userdir,'/thesis/stations.json']);

load stnsjson.mat
s = json;
fn = fieldnames(s);
lat = [];
lon = [];
stn = {};
for str = fn'
    
    if isfield(s.(char(str)), 'usable')
        if s.(char(str)).usable
            stn{end+1} = char(str);
            lat(end+1) = s.(char(str)).lat;
            lon(end+1) = s.(char(str)).lon;
        end
    end
end

rads = degtorad([lat', lon']);


radius = 1;


vects = @(V, radius) [
    radius * cos(V(:,1)) .* cos(V(:,2)),...
    radius * cos(V(:,1)) .* sin(V(:,2)),...
    radius * sin(V(:,1)) ];

bounding = [ 46.8 -124
             52.8 -134
             60   -145.5
             70.3 -141.8
             73.2 -127.4
             79   -119.3
             82.3 -95.7
             82   -60.3
             74.5 -71.26
             65.8 -60.2
             58   -59.37
             47.4 -48.7
             40.4 -58
             41   -82.7
             47   -91.8 ];

VB = vects(deg2rad(bounding), 1);

[X,IA,IC] = unique(vects(rads, 1), 'rows');
figure(1)
subplot(1,2,1)
plot(X(:,1),X(:,2), '.')
hold on
plot(VB(:,1),VB(:,2), 'r')

nump = size(VB,1);
plabels = arrayfun(@(n) {sprintf('B%d', n)}, (1:nump)');
Hpl = text(VB(:,1), VB(:,2), plabels, 'FontWeight', ...
        'bold', 'HorizontalAlignment','center', ...
        'BackgroundColor', 'none');
title('Initial Bounding Box')
hold off
% Perform edits
VB([1,6:8, 15],:) = [];
VB(end + 1, :) = VB(1, :);
% replot
subplot(1,2,2)
plot(X(:,1),X(:,2), '.')
hold on
plot(VB(:,1),VB(:,2), 'r')

nump = size(VB,1);
plabels = arrayfun(@(n) {sprintf('B%d', n)}, (1:nump)');
Hpl = text(VB(:,1), VB(:,2), plabels, 'FontWeight', ...
        'bold', 'HorizontalAlignment','center', ...
        'BackgroundColor', 'none');
title('Edited Bounding Box')
hold off


%Get convex Hull
%dt = DelaunayTri(X(:,1:2));
%k = convexHull(dt);
%cvx = [dt.X(k,1), dt.X(k,2)];
%cvx = cvx + cvx.*0.1;

% MPT TOOLBOX VERSION
figure(2)
options.plot = 0;
options.pbound = polytope( VB(:,1:2) );
V = mpt_voronoi(X(:,1:2), options); % compute voronoi cells
area = volume(V);
area = area./sum(area);
plot(V)
hold on
arealabel = arrayfun(@(n) {sprintf(' %2.3f', n)}, area*100);
plabel = strcat(stn(IA)', arealabel);
Hpl = text(X(:,1), X(:,2), plabel, 'FontWeight', ...
       'bold', 'HorizontalAlignment','center', ...
       'BackgroundColor', 'none');

 
 %2D for visualization
 

%   
% % % 3D for real
% % [V,C] = voronoin(X);
% % 
% % h = plot(VX, VY,'-b', X(:,1), X(:,2),'.r');
% % set(h(1:end-1),'xliminclude','off','yliminclude','off')
% 
% dt = DelaunayTri(X(:,1:2));
% k = convexHull(dt);
% plot(dt.X(k,1),dt.X(k,2), 'r'); hold off;