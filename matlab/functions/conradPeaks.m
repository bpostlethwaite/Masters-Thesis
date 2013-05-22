function [ih] = conradPeaks( varargin )
% KONRADPEAKS (STACKH, DEL, IHK) get the index for a given signals peaks.
% DEL is the delta to adjust peak detection. Optional 'ihk' is used to
% remove an entry located around index 'ihk'

stackh = varargin{1};
peakDel = varargin{2};

if nargin == 4
    ihk = varargin{3};
    indexDel = varargin{4};
end

ih = [];
% Get the "peaks" of stackh
[maxtab, ~] = peakdet(stackh./max(stackh), peakDel);
if isempty(maxtab)
    return
end

% Sort peaks by amplitude
[~, ix] = sort(maxtab(:, 2), 1, 'descend');
maxtab = maxtab(ix, :);
ih = maxtab(:, 1);

% Eliminate peak around ihk
if nargin == 4
    
    % Find close entry
    rmMOHO = find( abs(ih - ihk) < indexDel, 1);
    % If close entry found remove it
    if ~(isempty(rmMOHO))
        ih(rmMOHO) = [];
    end
    
end

end