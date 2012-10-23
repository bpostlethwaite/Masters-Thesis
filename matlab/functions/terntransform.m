function [ A, B, C ] = terntransform(av, bv, cv, dv, n)
%TERN [ A, B, C ] = tern(a, b, c, d)
% Turns ternary plot end member values and a given data value
% into percentage locations for plotting with ternplot.

A = zeros(length(dv), n);
B = A;
C = A;

for ii = 1:length(dv)
    a = av(ii);
    b = bv(ii);
    c = cv(ii);
    d = dv(ii);
    count = 1;
    if d <= max([a,c]) && d >= min([a,c])
        ptA(count) = abs( (d - c) / (a - c) ); %#ok<*AGROW>
        ptB(count) = 0;
        count = count + 1;
    end
    if d <= max([a,b]) && d >= min([a,b])
        ptA(count) = 1 - abs( (d - a) / (a - b) );
        ptB(count) = abs( (d - a) / (a - b) );
        count = count + 1;
    end
    if d <= max([b,c]) && d >= min([b,c])
        ptA(count) = 0;
        ptB(count) = abs( ( d - c) / (b - c) );
        count = count + 1;
    end
    if count ~= 3
        %fprintf([sprintf('Data %f outside ternary <%f, %f, %f>',d,a,b,c),...
        %    'endmember limits, skipping\n'])
        continue
    end
    
    A(ii,:) = linspace(ptA(1), ptA(2), n);
    B(ii,:) = linspace(ptB(1), ptB(2), n);
    C(ii,:) = 1 - A(ii,:) - B(ii,:);
    
end
end

