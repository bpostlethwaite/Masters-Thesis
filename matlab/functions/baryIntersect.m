function [ bb ] = baryIntersect(A, B, C)
%BARYINTERSECT Find the barycentric intersection between two lines.
%    Convert from barycentric to cartesian then get line intersection, then
% transform coords back into barycentric

bb = [];    
if size(A,1) == 1
    % Can't do intersect with one line
    return
end



% Loop through all rows combinations and build up a dictionary of 
%intersect points
combs = combnk(1:size(A,1), 2);
for comb = combs'
    
    A1 = A(comb(1), :);
    B1 = B(comb(1), :);
    C1 = C(comb(1), :);
    A2 = A(comb(2), :);
    B2 = B(comb(2), :);
    C2 = C(comb(2), :);
    
    % Function for barycentric to cartesian coord transformation
    % See http://en.wikipedia.org/wiki/Ternary_plot#Using_Cartesian_coordinates
    b2c = @(a,b,c) ([ (2*b+c) ./ (2 * (a+b+c)); sqrt(3) * c ./ (2 * (a+b+c))]);
    
    line1 = b2c(A1, B1, C1);
    line2 = b2c(A2, B2, C2);
    [x, y] = cartIntersect(line1, line2);
    % Barycentric Transformations.
    % see http://en.wikipedia.org/wiki/Barycentric_coordinates_(mathematics)
    % Cart -> Bary transform. Output two values b1 and b2. b3 is 1 - b1 - b2;
    T = [-0.5     , 0.5;
        -sqrt(3)/2, -sqrt(3)/2] ;
    
    b = T \ ([x; y] - [0.5; sqrt(3) / 2]);
    b(3) = 1 - b(1) - b(2);
    
    % Function for checking results are in ternary domain 0 -> 1
    inside = @(b) (b(1) >= 0 && b(1) <= 1 && ...
        b(2) >= 0 && b(2) <= 1 && ...
        b(3) >= 0 && b(3) <= 1);
    
    if ~inside(b)
        fprintf('Intersection found outside endmember domain, skipping\n')
        continue
    end
    
    bb = [bb; b']; %#ok<*AGROW>
    
    
end
end

