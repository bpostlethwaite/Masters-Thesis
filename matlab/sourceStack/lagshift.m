function shifted = lagshift(seis, lags, dt)

% LAGSHIFT shift all traces by lag times given in array lags.
% It is assumed that length(lags) == size(seis, 1)

lag = round(lags/dt);
shifted = zeros(size(seis));

for ii = 1 : size(seis, 1)
    shifted(ii, :) = circshift( seis(ii, :), [0, lag(ii)] );
end

end