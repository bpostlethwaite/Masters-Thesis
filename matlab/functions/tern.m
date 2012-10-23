function [ b ] = tern(data, varagin)
%TERN Utility for finding intersect in barycentric space and plotting.
%   INPUTS are data, a 1x4 or 2x4 array depending on chosen options which
%   holds the ternary endmember values a,b,c as well as the data value
%   which is represented as a line in barycentric space. The format is [a,
%   b, c, d] or [ a1, b1, c1, d1
%                 a2, b2, c2, d2
%                 a3, b3, c3, d3]
%   Where an intersect will be calculated for each unique row pairs.
%   Where the endmembers are calculated as:
%       b
%      / \
%     /   \
%    c --- a 
%
%   The options arguement is optional and for various functionality have 
%   following fields set.
%
%   op.plot = true                      Plotting enabled [Default is off]
%   op.endmlabel = {'L1','L2','L3'}     Set Labels for end members
%   op.datalabel = {'L1', <'L2'>}       Set Labels for 1 or 2 data 
%   op.npoints = n                      Set number of Points in ternplots
%                                           and intersection calc.
%   op.title = "string"                 Give a title for the plot
%   op.savefig = "fig_name.png"         Save figure to mapping directory
%
%   Relies on the plotting functionality from the ternplot package 
%   by Carl Sandrock. 
%
%   Author Ben Postlethwaite 2012
%   https://github.com/bpostlethwaite

% Setup defaults if options not supplied
if nargin == 1
    op.npoints = 100;
elseif nargin == 2
    op = varagin;
    if ~isfield(op,'npoints')
        op.npoints = 100;
    end
else
    ME = MException('FUNCTION:TooManyArgs', ...
                    'Too many arguments supplied to tern');
    throw(ME);
    
end;

% Set default return param
b = false;

% Check data array is correct size
if size(data, 2) ~= 4 
    ME = MException('INPUT:DimensionError', ...
                    'data needs to be mx4');
    throw(ME);
end

% Transform data into percentages and cast as 1 barycentric line per row.
[A, B, C] = terntransform(data(:,1), data(:,2),...
                          data(:,3), data(:,4), op.npoints);
disp(size(A))
[ b ] = baryIntersect(A, B, C);

color = ['b','g','m','r','y','c','k'];
if op.plot  && any(any(A))
    hf = figure();
    
    % Plot the barycentric lines
    for ii = 1:size(A,1)
        ternplot(A(ii,:), B(ii,:), C(ii,:), color(ii), 'lineWidth', 2)
        hold on
    end

    % If there are intersections, add them.
    if b
        for ii = 1 : size(b, 1)
            ternplot(b(ii,1), b(ii,2), b(ii,3), 'r*', 'markerSize', 10)
            ternplot(b(ii,1), b(ii,2), b(ii,3), 'ko',...
                'markerSize', 10, 'lineWidth', 2)  
        end
    end
    hold off
    
    % Add legend if option labels included and data has been plotted.
    % If row of A & B are zero, skip.
    if isfield(op,'datalabel')
        legend( op.datalabel( ~all(A == 0, 2) ) ,'Location', 'BestOutside')
    end

    % Add endmember names if there
    if isfield(op, 'endmlabel')
        ternlabel(op.endmlabel(1), op.endmlabel(2), op.endmlabel(3))
    end
    
    % Set title if option is set
    if isfield(op, 'title')
        h = title(op.title);
        P = get(h,'Position');
        set(h,'Position',[P(1) P(2) + 0.1 P(3)])
    end

    % Shrink size
    set(hf, 'Position', [1000 500 550 350])
    
    % Save figure if option set
    if isfield(op, 'savefig')
        set(hf,'PaperPositionMode','auto')
        print('-dpng','-zbuffer','-r72', op.savefig)
    end
end

end

