function [Vp, R, H, VpRmax, Hmax] = bootstrap(rec, Tps, dt, pslow, nmax)
% Bootstap error calculation for grid search confidence.
% [Vp, R, H, VpRmax, Hmax] = bootstrap(rec, Tps, dt, pslow, nmax)
% Outputs are arrays of best estimates of Vp, R and H along with the
% the maximum values in the solution space (stacked amplitudes) for the
% Vp & R grid search and the H line search. These can be used for error
% contours to go along with estimates of parameters uncertainty.


rec = rec';
n = size(rec,2);

Vp = zeros(1, nmax);
R = zeros(1, nmax);
H = zeros(1, nmax);
VpRmax = zeros(1, nmax);
Hmax = zeros(1, nmax);
parfor ii = 1:nmax
    ind = randi(n, n, 1);
    [Vp(ii), R(ii), H(ii), VpRmax(ii), Hmax(ii) ] = fastgridsearch( rec(:, ind), Tps(ind), dt, pslow(ind) );
end


%Vp = zeros(workers, iters);
%R = zeros(workers, iters);
%H = zeros(workers, iters);
%VpRmax = zeros(workers, iters);
%Hmax = zeros(workers, iters);
%parfor ii = 1:workers
%   [Vp(ii,:), R(ii,:), H(ii,:), VpRmax(ii,:), Hmax(ii,:)] = bootstrapC(rec, Tps, dt, pslow, iters,ii*100);
%end
%Vp = Vp(:);
%R = R(:);
%H = H(:);
%VpRmax = VpRmax(:);
%Hmax = Hmax(:);





