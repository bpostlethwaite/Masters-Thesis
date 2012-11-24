function bounding = chooseBounding(region)
% Outputs desired convex bounds in lat and lon.

if strcmp(region, 'Canada')
    bounding = [
        46.8 -124
        52.8 -134
        60   -145.5
        70.3 -141.8
        73.2 -127.4
        79   -119.3
        82.3 -95.7
        83   -60.3
        74.5 -71.26
        65.8 -60.2
        59.5 -58.37
        48.4 -48.7
        40.4 -58
        41   -82.7
        47   -91.8
        ];
    
elseif strcmp(region, 'Churchill Province')
    bounding = [
        62.3  -114.1
        69.1  -106.2
        70.48 -93.25
        73.75 -81.0
        72.16 -72.21
        70.60 -67.23
        64.89 -63.23
        54.60 -61.54
        53.65 -66.8
        53.71 -84.95
        54.30 -99.2
        54.99 -107.88
        58.60 -112.16
        ];

elseif strcmp(region, 'Superior Province')
    bounding = [
        54.60 -99.54
        57.10 -97.13
        62.26 -73.52
        59.60 -68.18
        52.86 -65.95
        49.35 -74.7
        46.14 -80.29
        48.85 -96.4
        ];
    
elseif strcmp(region, 'Slave Province')
    bounding = [
        68.79 -105.69
        62.81 -107.01
        61.27 -113.15
        62.15 -115.22
        64.82 -116.93
        ];

elseif strcmp(region, 'Grenville Province')
    bounding = [
        46.15 -82.14
        51.88 -72.24
        55.66 -59.17
        51.88 -54.53
        49.02 -57.57
        50.04 -62.92
        41.8 -74.72
        ];
    
elseif strcmp(region, 'Shield')
    bounding = [
        68.81 -122.87
        71.71 -93.46
        74.16 -79.47
        70.95 -66.95
        66.92 -60.78
        60.99 -64.20
        52.56 -54.15
        42.65 -73.29
        41.39 -82.88
        49.00 -96.96
        53.14 -98.68
        55.31 -107.75
        62.40 -117.13
        ];
    
elseif strcmp(region, 'Cordilleran Orogen')
    bounding = [
        59.56 -141.38
        68.45 -141.04
        65.18 -126.04
        48.75 -113.46
        47.98 -123.87
        52.50 -132.24
        ];
    
else
    fprintf('Unrecognized region in choooseBounding func')
    return
    
end