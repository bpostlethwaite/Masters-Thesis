% tern hacks

clear all
close all
loadtools;
addpath([userdir,'/programming/matlab/jsonlab'])
addpath([userdir,'/programming/matlab/ternplot'])

n = 10;

a = 6.62;
b = 7.84;
c = 7.04;
d = 7.2;

a2 = 0.3;
b2 = 0.21;
c2 = 0.29;
d2 = 0.26;

[ Avp, Bvp, Cvp] = tern(a, b, c, d, n);
[ Ap, Bp, Cp] = tern(a2, b2, c2, d2, n);
%A = linspace(0.6, 0.82, n);
%B = linspace(0, 0.18, n);
%C = linspace(0, 0.4, n);


%% Intersections

% Function for barycentric to cartesian coord transformation
% See http://en.wikipedia.org/wiki/Ternary_plot#Using_Cartesian_coordinates
b2c = @(a,b,c) ([ (2*b+c) ./ (2 * (a+b+c)); sqrt(3) * c ./ (2 * (a+b+c))]);
% Function for calculating line slope (y2 - y1) /  (x2 - x1)
slope = @(line) (line(2,2) - line(2,1))/(line(1,2) - line(1,1));
% Function for calculating intercept
intercept = @(line,m) line(2,1) - m*line(1,1);
% Function for checking results are in ternary domain 0 -> 1
inside = @(b) (b(1) >= 0 && b(1) <= 1 && ...
               b(2) >= 0 && b(2) <= 1 && ...
               b(3) >= 0 && b(3) <= 1);
           
line1 = b2c(Avp, Bvp, Cvp);
line2 = b2c(Ap, Bp, Cp);

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
%% Barycentric Transformations. 
% see http://en.wikipedia.org/wiki/Barycentric_coordinates_(mathematics)
% Cart -> Bary transform matrix
T = [-0.5     , 0.5;
    -sqrt(3)/2, -sqrt(3)/2];
% Invert for Barycentric coords
b = T\([x; y] - [0.5; sqrt(3) / 2]);     
b(3) = 1 - b(1) - b(2);

if ~inside(b)
     ME = MException('OutsideDomain', ...
             'Intercept lies outside domain');
     throw(ME);
end
    

%% Plots
figure(2)
h = plot(line1(1,:),line1(2,:));
hold on
h(2) = plot(line2(1,:),line2(2,:), 'r');
set(h,'linewidth',2)
axis([0 1 0 1])
plot(x,y,'m*','markersize',8)
hold off

figure(3)
ternplot(Avp,Bvp,Cvp)
hold on
ternplot(Ap,Bp,Cp,'r')
ternplot(b(1), b(2), b(3), 'k*')
ternplot(b(1), b(2), b(3), 'go')


