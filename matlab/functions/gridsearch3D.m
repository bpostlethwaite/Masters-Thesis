function [ results ] = gridsearch3D(rec, dt, pslow)
%GSEARCHKANAMORI Grid Search as implemented in Kanamori, Zhu 2000
%
% Grid search over Tps TPpPs and TPpSs with parameters R (Vp/Vs) and H
% Input Mooneys v


%% Grip parameters
% Vp/Vs Ratio
nr = 100;
r1 = 1.65; %1.65
r2 = 1.95;
dr = (r2 - r1)/(nr - 1);
r = r1:dr:r2;

% Thickness H
nh = 100;
h1 = 25;
h2 = 50;
dh = (h2 - h1)/(nh - 1);
h = h1:dh:h2;


% Vp
nv = 100;
v1 = 5;
v2 = 8;
dv = (v2 - v1)/(nv - 1);
v = v1:dv:v2;


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
stackhr = zeros(nr,nh,nv);
parfor ir = 1:nr
    for ih = 1:nh
        for iv = 1:nv
            
            f1 = sqrt((r(ir) / v(iv))^2 - p2);
            f2 = sqrt((1 / v(iv))^2 - p2);
            t1 = h(ih) * (f1 - f2);
            t2 = h(ih) * (f1 + f2);
            t3 = h(ih) * 2*(f1);
            r1 = mean(gvr(round(t1/dt)+1+[0:np-1]*nt));
            r2 = mean(gvr(round(t2/dt)+1+[0:np-1]*nt));
            r3 = mean(gvr(round(t3/dt)+1+[0:np-1]*nt));
        
            stackhr(ir,ih, iv) = w1*r1 + w2*r2 + w3*r3;
        end
    end
end

% Select best/highest values and recalculate
smax = max(max(max(stackhr)));
[ir,ih,iv] = ind2sub(size(stackhr),find(stackhr == smax));

hbest = h(ih);
rbest = r(ir);
vbest = v(iv);

f1 = sqrt((rbest / vbest)^2 - p2);
f2 = sqrt((1 / vbest)^2 - p2);

%% Pack results into struct
results.method = 'fullgrid';
results.rbest = rbest;
results.vbest = vbest;
results.hbest = hbest;
results.stackhr = stackhr;
results.rRange = r;
results.hRange = h;
results.vRange = v;
results.smax = smax;
results.tps = hbest * (f1 - f2);
results.tpps = hbest * (f1 + f2);
results.tpss = hbest * 2 * f1;


end
