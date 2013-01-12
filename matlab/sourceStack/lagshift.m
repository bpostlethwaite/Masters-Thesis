function shifted = lagshift(seis, lags, dt)

% LAGSHIFT shift all traces by lag times given in array lags.
% It is assumed that length(lags) == size(seis, 1) and dt is either a
% scalar or a size(seis, 1) vector.

ns = size(seis, 1);
if length(dt) == 1
    dt = ones(1, ns) * dt;
else
    dt = dt(:)'; 
end

lag = round(lags ./ dt);
shifted = zeros(size(seis));

for ii = 1 : ns
    shifted(ii, :) = circshift( seis(ii, :), [0, lag(ii)] );
end

end


