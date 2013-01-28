% StationDistance
function stations = distantStations(station, mindist, maxdist)
% DISTANTSTATIONS returns all stns within mindist and maxdist from station

load stndist
n = length(stns);
radius = 6371;
e = ones(n, 1);

%% Get input stations lat and lon
ix = strcmp(station, stns);
stnlat = lats(ix);
stnlon = lons(ix);

if isempty(stnlat)
    error('Station %s not found in "stndist.mat"', station)
end

if length(stnlat) > 1
    error('Multiple entries found for station %s in "stndist.mat"', station)
end

%% Compute distance matrix
arclen = distance([stnlat * e, stnlon * e], [lats', lons'], radius);
%% Sort ascending
[arclen, I] = sort(arclen);
stns = stns(I);
%% pinch
stations = stns( arclen >= mindist & arclen <= maxdist );

end