function [ boot ] = bootstrap_linear(rec, dt, pslow, nmax, method, Tps, vp) 
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

if strcmp(method, 'kanamori')
    
    RHx = zeros(1, nmax);
    
    parfor ii = 1:nmax
        ind = randi(n, n, 1);
        [R(ii), H(ii), RHx(ii) ] = ...
            gridsearchKanC_linear( rec(:, ind), dt, pslow(ind), vp); %#ok<*PFOUS,*PFBNS>
    end
    
    % Assign to method specific structures
    boot.RHx = RHx;
    
    
else
    ME = MException('ProcessMethodNotFound', ...
             'Method must "kanamori."');
    throw(ME);
end


% Assign to remaining shared structures
boot.R = R;
boot.H = H;



