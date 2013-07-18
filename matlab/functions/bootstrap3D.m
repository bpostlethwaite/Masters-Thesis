function [Vp, R, H] = bootstrap3D(rec, dt, pslow, lim3D, nmax)
% Bootstap error calculation for grid search confidence.
% [Vp, R, H, VpRmax, Hmax] = bootstrap(rec, Tps, dt, pslow, nmax)
% Outputs are arrays of best estimates of Vp, R and H along with the
% the maximum values in the solution space (stacked amplitudes) for the
% Vp & R grid search and the H line search. These can be used for error
% contours to go along with estimates of parameters uncertainty.

rec = rec';
n = size(rec,2);

R = zeros(1, nmax);
H = zeros(1, nmax);
Vp = zeros(1, nmax);
Smax = zeros(1, nmax);

parfor ii = 1:nmax
    ind = randi(n, n, 1);
    [Vp(ii), R(ii), H(ii), Smax(ii)] = ...
        gridsearch3DC( rec(:, ind), dt, pslow(ind), lim3D);
end

