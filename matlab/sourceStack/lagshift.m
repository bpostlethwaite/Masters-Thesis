function shifted = lagshift(seis, lags, varargin)
% LAGSHIFT shift all traces by lag times given in array lags.
% It is assumed that length(lags) == size(seis, 1) and dt is either a
% scalar or a size(seis, 1) vector. If dt is not sent in it is assumed that
% lags are in index numbers n.



ns = size(seis, 1);

if nargin() > 2
    dt = varargin{1};
    
    if length(dt) == 1
        dt = ones(1, ns) * dt;
    else
        dt = dt(:)';
    end
    lags = round(lags ./ dt);
    
end
shifted = zeros(size(seis));

for ii = 1 : ns
    shifted(ii, :) = circshift( seis(ii, :), [0, lags(ii)] );
end

end


