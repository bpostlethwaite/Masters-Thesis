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
    provinces([1:11,15:18]), 'Canada'
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


% Albers equal area with lat standard parallels of 50 and 80 deg
phi1 = degtorad(50);
phi2 = degtorad(80);
n = 0.5 * (sin(phi1) + sin(phi2));
C = cos(phi1)^2 + 2 * n * sin(phi1);
theta = @(lon) n * lon;
p = @(lat) sqrt( (C - 2 * n * sin(lat)) / n);

x = @(lat, lon) p(lat) .* sin(theta(lon));
y = @(lat, lon) -p(lat) .* cos(theta(lon));

despace = @(str) str(str ~= ' ');
%% Parameters
plotbounds = 0;
plotvoronoi = 0;

json = struct();

%% Get Data
datafiles = {
    '../data/stations.json'
    '../data/moonvpGeology.json'
    '../data/crust2.json'
    };
dsource = {
    'kanamori'
    'mooney'
    'crust2'
    };
dtype = {
    'R'
    'Vp'
    'R'
    };

for jj = 1:size(region, 1)
    
    bound = chooseBounding( region{jj,2} );
    bound(end + 1, :) = bound(1, :);
    VB = [y(degtorad(bound(:,1)), degtorad(bound(:,2))), ...
        x(degtorad(bound(:,1)), degtorad(bound(:,2)))];
    
    for qq = 1:3
        
        data = getStationData( datafiles{qq}, region{jj,1} );
        
        %% Perform conversions, computations
        vects = [y(degtorad(data.lat'), degtorad(data.lon')), ...
            x(degtorad(data.lat'), degtorad(data.lon'))];
        %vects = vect(degtorad([data.lat', data.lon']));
        %VB = vect(deg2rad(bound));
                
        if plotbounds
            figure()
            plot(vects(:,1), vects(:,2), '.')
            hold on
            % Plot Convex Hull of Bounding, to make sure it IS convex
            K = convhull(VB(:,1), VB(:,2));
            plot(VB(K, 1), VB(K, 2),'k')
            % Overplot Bounding
            plot(VB(:,1), VB(:,2), 'r--')

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
        out = ~inpolygon(vects(:,1), vects(:,2), VB(:,1), VB(:,2));
        if any(out)
            fprintf('Cutting out %i stations\n', sum(out))
            data.R(out) = [];
            data.H(out) = [];
            data.stn(out) = [];
            data.lat(out) = [];
            data.lon(out) = [];
            vects = [y(degtorad(data.lat'), degtorad(data.lon')), ...
                x(degtorad(data.lat'), degtorad(data.lon'))];
            %             %vects = vect(degtorad([data.lat', data.lon']));
        end
        
        [X,IA,IC] = unique(vects, 'rows');
            
        % Convex Hull Bounding
        if (jj == 6) && (qq == 1)% For some reason chosen Shield 
            % bounding doesn't work even though I am quite sure it's convex
            % So we will just use the convex hull operation for Shield region
            dt = DelaunayTri(X(:,1:2));
            k = convexHull(dt);
            cvx = [dt.X(k,1), dt.X(k,2)];
            options.pbound = polytope( cvx );
        else
            % User supplied bounding
            options.pbound = polytope( VB(:,1:2) );
        end
        options.plot = 0;
        V = mpt_voronoi(X(:,1:2), options); % compute voronoi cells
        area = volume(V);
        area = area./sum(area);
        Rv = data.R(IA) * area;
        Hv = data.H(IA) * area;
        
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
        
        json.( despace(region{jj,2}) ).(dsource{qq}).(dtype{qq}) = Rv;
        json.( despace(region{jj,2}) ).(dsource{qq}).H = Hv;
        
    end
end

opt.FileName = [userdir,'/thesis/data/voronoi.data'];
opt.ForceRootName = 0;
savejson('', json, opt);
