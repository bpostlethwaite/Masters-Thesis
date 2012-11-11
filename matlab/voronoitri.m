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
lat = []; lon = [];
R = []; H = [];
stn = {};
for strng = fn'
    str = char(strng);
    if isfield(s.(str), 'hk')
        if s.(str).hk.stdR < 0.041
            if any(strcmp(str, {'YKW2','YKW4','YKW5'}))
                fprintf('Skipping A YKWn station\n')
                continue
            end
            stn{end+1} = str;
            lat(end+1) = s.(str).lat;
            lon(end+1) = s.(str).lon;
            R(end+1) = s.(str).hk.R;
            H(end+1) = s.(str).hk.H;
        end
    end
end

rads = degtorad([lat', lon']);

poisson = @(R) ( (R^2 - 2) / (2*(R^2 - 1)));

radius = 1;


vects = @(V, radius) [
    radius * cos(V(:,1)) .* cos(V(:,2)),...
    radius * cos(V(:,1)) .* sin(V(:,2)),...
    radius * sin(V(:,1)) ];

[X,IA,IC] = unique(vects(rads, 1), 'rows');


%{
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

VB = vects(deg2rad(bounding), 1.01);



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
hod off
%}
%{
% Perform edits
% VB([1,6:8, 15],:) = [];
% VB(end + 1, :) = VB(1, :);
% % replot
% subplot(1,2,2)
% plot(X(:,1),X(:,2), '.')
% hold on
% plot(VB(:,1),VB(:,2), 'r')
% 
% nump = size(VB,1);
% plabels = arrayfun(@(n) {sprintf('B%d', n)}, (1:nump)');
% Hpl = text(VB(:,1), VB(:,2), plabels, 'FontWeight', ...
%         'bold', 'HorizontalAlignment','center', ...
%         'BackgroundColor', 'none');
% title('Edited Bounding Box')
% hold off

%Get convex Hull
%dt = DelaunayTri(X(:,1:2));
%k = convexHull(dt);
%cvx = [dt.X(k,1), dt.X(k,2)];
%cvx = cvx + cvx.*0.1;
%}
% MPT TOOLBOX VERSION 2D
%

% Convex Hull
dt = DelaunayTri(X(:,1:2));
k = convexHull(dt);
cvx = [dt.X(k,1), dt.X(k,2)];

figure(2)
options.plot = 0;
%options.pbound = polytope( VB(:,1:2) );
options.pbound = polytope( cvx );
V = mpt_voronoi(X(:,1:2), options); % compute voronoi cells
area = volume(V);
area = area./sum(area);
R = R(IA)' .* area;
H = H(IA)' .* area;

plot(V)
hold on
arealabel = arrayfun(@(n) {sprintf(' %2.3f', n)}, area*100);
plabel = strcat(stn(IA)', arealabel);
Hpl = text(X(:,1), X(:,2), plabel, 'FontWeight', ...
       'bold', 'HorizontalAlignment','center', ...
       'BackgroundColor', 'none');

fprintf('Average Vp/Vs = %f\n', sum(R));
fprintf('Average H = %f\n', sum(H));
   
   %}
%3D MPT
%{
dt = DelaunayTri(X);
k = convexHull(dt);
cvx = [dt.X(k,1), dt.X(k,2), dt.X(k,3) ];
  
figure(2)
options.plot = 1;
%options.pbound = polytope( VB );
options.pbound = polytope( cvx );
V = mpt_voronoi(X, options); % compute voronoi cells
%area = volume(V);
%area = area./sum(area);
%plot(V)
hold on
plot3(X(:,1),X(:,2),X(:,3), '.')
hold off
% Get Vertices
% see http://control.ee.ethz.ch/~mpt/docs/refguide/mpt/@polytope/extreme.html
E = cell(1, length(V));
for i = 1:length(V)
    E{i} = extreme(V(i)); 
end
%arealabel = arrayfun(@(n) {sprintf(' %2.3f', n)}, area*100);
%plabel = strcat(stn(IA)', arealabel);
%Hpl = text(X(:,1), X(:,2), plabel, 'FontWeight', ...
%      'bold', 'HorizontalAlignment','center', ...
%      'BackgroundColor', 'none');

 %}  
   
 %2D for visualization
 
% Online Hack
%{
% Create a Delaunay triangulation of the point set.
% This is a solid triangulation composed of tetrahedra.

dt = DelaunayTri(X(:,1),X(:,2),X(:,3));

% Extract the surface (boundary) triangulation, in this instance it is 
%actually the convex hull
% so you could use the convexHull method also.

ch = dt.freeBoundary();

% Create a Triangulation Representation from this surface triangulation
% We will use it to compute the location of the voronoi vertices 
% (circumcenter of the triangles),
% and the dual edges from the triangle neighbor information.

tr = TriRep(ch, X(:,1), X(:,2), X(:,3));
numt = size(tr,1);
T = (1:numt)';
neigh = tr.neighbors();
cc = tr.circumcenters();
xcc = cc(:,1);
ycc = cc(:,2);
zcc = cc(:,3);
idx1 = T < neigh(:,1);
idx2 = T < neigh(:,2);
idx3 = T < neigh(:,3);
neigh = [T(idx1) neigh(idx1,1); T(idx2) neigh(idx2,2); T(idx3) neigh(idx3,3)]';
figure(3)
plot3(xcc(neigh), ycc(neigh), zcc(neigh),'-r');
axis equal;
grid on;
hold on
plot3(X(:,1),X(:,2),X(:,3), '.')

%1) Compute the set of triangles attached to point i. The triangles are 
%arranged in a CCW cycle around the point i.
for i = 1:length(tr.X)
    Ti = tr.vertexAttachments(i)

%2) The positions of the vertices defining the i'th Voronoi region are the 
%circumcenters of these triangles
    ccTi = tr.circumcenters(Ti);

%3) The Voronoi region may be non-planar.
%     To compute the area break it into triangles defined by the point i and 
%each edge of the Voronoi region.
%     The location of point i is x(i), y(i), z(i)
%      the two edge points are ccTi(1,:) to ccTi(2,:)
end
%}