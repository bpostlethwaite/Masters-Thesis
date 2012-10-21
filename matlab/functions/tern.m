function [ A, B, C ] = tern(a, b, c, d, n)
%TERN [ A, B, C ] = tern(a, b, c, d)
% Turns ternary plot end member values and a given data value
% into percentage locations for plotting with ternplot.

ii = 1;
if d <= max([a,c]) && d >= min([a,c])
    ptA(ii) = abs( (d - c) / (a - c) );
    ptB(ii) = 0;
    ii = ii + 1;
end
if d <= max([a,b]) && d >= min([a,b])
    ptA(ii) = 1 - abs( (d - a) / (a - b) );
    ptB(ii) = abs( (d - a) / (a - b) );
    ii = ii + 1;
end
if d <= max([b,c]) && d >= min([b,c])
    ptA(ii) = 0;
    ptB(ii) = abs( ( d - c) / (b - c) );
end
if ii ~= 2
     ME = MException('OutOfBounds', ...
             'Input data must be within a,b,c value bounds');
     throw(ME);
end
     
A = linspace(ptA(1), ptA(2), n);
B = linspace(ptB(1), ptB(2), n);
C = 1 - A - B;
end

