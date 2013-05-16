function [ results ] = gridsearchKan(rec, dt, pslow, v)
%GSEARCHKANAMORI Grid Search as implemented in Kanamori, Zhu 2000
%
% Grid search over Tps TPpPs and TPpSs with parameters R (Vp/Vs) and H
% Input Mooneys v


%% Grip parameters
% Vp/Vs Ratio
nr = 200;
r1 = 1.65; %1.65
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
%v = 6.38; % bulk vp pwave velocity.
p2 = pslow.^2;
np = length(pslow);
nt = length(rec);
w1 = 0.5;
w2 = 0.3;
w3 =-0.2;

% Reshape for fast access
gvr = rec'; % rotate
gvr = gvr(:); % vectorize

%% Grid serarch for r and H
stackhr = zeros(nr,nh);
f2 = sqrt((1 / v)^2 - p2);
parfor ir = 1:nr
    for ih = 1:nh
        f1 = sqrt((r(ir) / v)^2 - p2);
        t1 = h(ih) * (f1 - f2);
        t2 = h(ih) * (f1 + f2);
        t3 = h(ih) * 2*(f1);
        r1 = mean(gvr(round(t1/dt)+1+[0:np-1]*nt));
        r2 = mean(gvr(round(t2/dt)+1+[0:np-1]*nt));
        r3 = mean(gvr(round(t3/dt)+1+[0:np-1]*nt));
        
        S1 = sum(gvr(round(t1/dt)+1+[0:np-1]*nt))^2 / sum(gvr(round(t1/dt)+1+[0:np-1]*nt).^2);
        S2 = sum(gvr(round(t2/dt)+1+[0:np-1]*nt))^2 / sum(gvr(round(t2/dt)+1+[0:np-1]*nt).^2);
        S3 = sum(gvr(round(t3/dt)+1+[0:np-1]*nt))^2 / sum(gvr(round(t3/dt)+1+[0:np-1]*nt).^2);
        
        stackhr(ir,ih) = S1*w1*r1 + S2*w2*r2 + S3*w3*r3;
    end
end

% Select best/highest values and recalculate
smax = max(max(stackhr));
[ir,ih] = find(stackhr == smax);
hbest = h(ih);
rbest = r(ir);
f1 = sqrt((rbest / v)^2 - p2);

%% Pack results into struct
results.method = 'kanamori';
results.rbest = rbest;
results.v = v;
results.hbest = hbest;
results.stackhr = stackhr;
results.rRange = r;
results.hRange = h;
results.smax = smax;
results.tps = hbest * (f1 - f2);
results.tpps = hbest * (f1 + f2);
results.tpss = hbest * 2 * f1;


end
