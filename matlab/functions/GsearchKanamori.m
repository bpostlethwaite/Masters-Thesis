function [ rbest, hbest ] = GsearchKanamori(rec,dt,pslow)
%GSEARCHKANAMORI Grid Search as implemented in Kanamori, Zhu 2000
%
% Grid search over Tps TPpPs and TPpSs with parameters R (Vp/Vs) and H
%


%% Grip parameters
% Vp/Vs Ratio
nr = 200;
r1 = 1.65;
r2 = 1.95;
dr = (r2 - r1)/(nr - 1);
r = r1:dr:r2;

% Thickness H
nh = 200;
h1 = 25;
h2 = 50;
dh = (h2 - h1)/(nh - 1);
h = h1:dh:h2;

% Misc
v = 6.38; % bulk vp pwave velocity.
p2 = pslow.^2;
np = length(pslow);
nt = length(rec);
w1 = .5;
w2 = .3;
w3 = .2;

% Reshape for fast access
gvr = rec'; % rotate
gvr = gvr(:); % vectorize

%% Grid serarch for r and H

f2 = sqrt((1 / v)^2 - p2);
for ir = 1:nr
    for ih = 1:nh
        f1 = sqrt((r(ir) / v)^2 - p2);
        t1 = h(ih) * (f1 - f2);
        t2 = h(ih) * (f1 + f2);
        t3 = h(ih) * 2*(f1);
        r1 = mean(gvr(round(t1/dt)+1+[0:np-1]*nt));
        r2 = mean(gvr(round(t2/dt)+1+[0:np-1]*nt));
        r3 = mean(gvr(round(t3/dt)+1+[0:np-1]*nt));
        grid(ir,ih) = w1*r1 + w2*r2 - w3*r3;
    end
end

% Select best/highest values and recalculate
smax = max(max(grid));
[ir,ih] = find(grid == smax);
hbest = h(ih);
rbest = r(ir);

end
