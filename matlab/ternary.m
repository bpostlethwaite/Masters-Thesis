% tern hacks

clear all
close all
loadtools;
addpath functions
addpath([userdir,'/programming/matlab/ternplot'])
addpath([userdir,'/programming/matlab/jsonlab'])

% Function to go from Vp/Vs -> Poisson's ratio
poisson = @(R) ( (R^2 - 2) / (2*(R^2 - 1)));

% Values taken from 
% Christensen, N. I. (1996), Poisson's ratio and crustal seismology,
% J. Geophys. Res., 101(B2), 3139–3156, doi:10.1029/95JB03446.
          % Vp    Vs    Vp/Vs Poisson
maficG   = [6.942 3.820 1.817 0.283]; % 600  Mpa
biotiteG = [6.302 3.606 1.747 0.257]; % 600  Mpa
graniteG = [6.208 3.583 1.732 0.250]; % 600  Mpa


% Load up some data from json file

data = [a1, b1, c1, d1;
        a2, b2, c2, d2;
        a3, b3, c3, d3];

options.plot = true;
options.endmlabel = {'Mafic Granulite','Biotite Gneiss','Granite Gneiss'};
options.datalabel = {'Vp','Vs','Vp2'};


b = tern(data, options);

