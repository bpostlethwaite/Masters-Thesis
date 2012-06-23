function [ results ] = GsearchKanamori(rec,dt,pslow)
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
v = 6.3; % bulk vp pwave velocity.
p2 = pslow.^2;
np = length(pslow);
nt = length(rec);
w1 = 5/15;
w2 = 6/15;
w3 = 1 - w2 - w1;

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

%% Results & Errors
% See Paper by Eaton et al.
f1 = sqrt((rbest / v)^2 - p2);
tps = hbest * (f1 - f2);
tpps = hbest * (f1 + f2);
tpss = 2 * hbest * f1;

sterr1 = sqrt(mean(var([gvr(round(tps/dt)+1+[0:np-1]*nt),...
                 gvr(round(tpps/dt)+1+[0:np-1]*nt),...
                 -gvr(round(tpss/dt)+1+[0:np-1]*nt)])/(3*np)));
             
err = smax - sterr1;
    % Calculate +/- for R
errRpn = sum(any(grid > err,2)); 
errR = 0.5 * dr * errRpn;

%% Pack results into struct 
results.method = 'kanamori';
results.rbest = rbest;
results.vbest = v;
results.hbest = hbest;
results.stackvr = grid;
results.stackh = NaN;
results.errV = NaN;
results.errR = errR;
results.errH = NaN;
results.rRange = r;
results.vRange = v;
results.hRange = h;
results.sterr1 = sterr1;
results.sterr2 = NaN;
results.smax = smax;
results.hmax = NaN;
results.tps = tps;
results.tpps = tpps;
results.tpss = tpss;

end
