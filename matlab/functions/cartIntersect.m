function [ x, y ] = cartIntersect(line1, line2  )
%LINEINTERSECT Find the x,y coords of the intersection between two lines.
%   INPUT two vectors  of 'y' values. Intersection found in the cartesian
%   plane. 
%   OUTPUT are the xy coords.

% Function for calculating line slope (y2 - y1) /  (x2 - x1)
slope = @(line) (line(2,2) - line(2,1))/(line(1,2) - line(1,1));
% Function for calculating intercept
intercept = @(line,m) line(2,1) - m*line(1,1);

% Get slopes
m1 = slope(line1);
m2 = slope(line2);

b1 = intercept(line1,m1);
b2 = intercept(line2,m2);
x = (b2-b1)/(m1-m2);
y = m1*x + b1;
    
% Makes sure they are not parallel (different intercept and same slop)
sameSlope = abs(m1-m2) < eps(m1);
differentIntercept = abs(b1-b2) > eps(b1);
isParallel = sameSlope && differentIntercept;
if isParallel
     ME = MException('ParallelLines', ...
             'No intercept can be calculated as lines are parallel');
     throw(ME);
end

end

