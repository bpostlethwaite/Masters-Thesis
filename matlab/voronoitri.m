clear all
close all
loadtools;
addpath functions
addpath([userdir,'/programming/matlab/jsonlab'])
addpath(genpath([userdir,'/programming/matlab/mpt/']));

provinces = {
    'Bear Province'             % 1
    'Churchill Province'        % 2
    'Grenville Province'        % 3
    'Province de Grenville'     % 4
    'Nain Province'             % 5
    'Slave Province'            % 6
    'Southern Province'         % 7
    'Superior Province'         % 8
    'Arctic Platform'           % 9
    'Interior Platform'         % 10
    'St. Lawrence Platform'     % 11
    'Arctic Continental Shelf'  % 12
    'Atlantic Continental Shelf'% 13
    'Pacific Continental Shelf' % 14
    'Appalachian Orogen'        % 15
    'Cordilleran Orogen'        % 16
    'Innuitian Orogen'          % 17
    'Hudson Bay Lowlands'       % 18
    };

region = {
    provinces([1:11,15:18]), 'canada'
    provinces(2), provinces{2}
    provinces(3), provinces{3}
    provinces(6), provinces{6}
    provinces(8), provinces{8}
    provinces(1:8), 'Shield'
    };
%% Helper Funcs
poisson = @(R) ( (R^2 - 2) / (2*(R^2 - 1)));

vect = @(V) [
    cos(V(:,1)) .* cos(V(:,2)),...
    cos(V(:,1)) .* sin(V(:,2)),...
    sin(V(:,1)) ];

despace = @(str) str(str ~= ' ');
%% Parameters
plotbounds = 0;
plotvoronoi = 0;

%% Output Data & file
json = struct();
fid = fopen([userdir,'/thesis/data/voronoi.data'], 'w');
%% Get Data
datafiles = {
    '../data/stations.json'
    '../data/moonvpGeology.json'
    };
dsource = {
    'kanamori'
    'mooney'
    };
dtype = {
    'R'
    'Vp'
    };

for jj = 1:size(region, 1)
    for qq = 1:2
        
        data = getStationData( datafiles{qq}, region{jj,1} );
        bound = chooseBounding( region{jj,2} );
        
        %% Perform conversions, computations
        
        vects = vect(degtorad([data.lat', data.lon']));
        %bound(end + 1, :) = bound(1, :);
        %VB = vect(deg2rad(bound));
        
        
        if plotbounds
            figure()
            plot(vects(:,1), vects(:,2), '.')
            hold on
            plot(VB(:,1), VB(:,2), 'r')
            
            nump = size(VB,1);
            % Label vertices
            plabels = arrayfun(@(n) {sprintf('B%d', n)}, (1:nump)');
            Hpl = text(VB(:,1), VB(:,2), plabels, 'FontWeight', ...
                'bold', 'HorizontalAlignment','center', ...
                'BackgroundColor', 'none');
            % label stations
            Hpl = text(vects(:,1), vects(:,2), char(data.stn), 'FontWeight', ...
                'bold', 'HorizontalAlignment','center', ...
                'BackgroundColor', 'none');
            
            title('Initial Bounding Box')
            hold off
        end
        % Remove Points outside boundary. Only do if it really isn't worth
        % extending the boundary.
%         out = ~inpolygon(vects(:,1), vects(:,2), VB(:,1), VB(:,2));
%         if any(out)
%             fprintf('Cutting out %i stations\n', sum(out))
%             data.R(out) = [];
%             data.H(out) = [];
%             data.stn(out) = [];
%             data.lat(out) = [];
%             data.lon(out) = [];
%             vects = vect(degtorad([data.lat', data.lon']));
%         end
        
        [X,IA,IC] = unique(vects, 'rows');
        
        
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
        % or
        % cvx = [VB(:,1), VB(:,2)];
        

        options.plot = 0;
        %options.pbound = polytope( VB(:,1:2) );
        options.pbound = polytope( cvx );
        V = mpt_voronoi(X(:,1:2), options); % compute voronoi cells
        area = volume(V);
        area = area./sum(area);
        Rv = data.R(IA)' .* area;
        Hv = data.H(IA)' .* area;
        
        if plotvoronoi
            figure()
            plot(V)
            hold on
            arealabel = arrayfun(@(n) {sprintf(' %2.3f', n)}, area*100);
            plabel = strcat(data.stn(IA)', arealabel);
            Hpl = text(X(:,1), X(:,2), plabel, 'FontWeight', ...
                'bold', 'HorizontalAlignment','center', ...
                'BackgroundColor', 'none');
            hold off
        end
        
        json.( despace(region{jj,2}) ).(dsource{qq}).(dtype{qq}) = sum(Rv);
        json.( despace(region{jj,2}) ).(dsource{qq}).H = sum(Hv);
        
    end
end

opt.FileName = [userdir,'/thesis/data/voronoi.data'];
opt.ForceRootName = 0;
savejson('', json, opt);

        

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