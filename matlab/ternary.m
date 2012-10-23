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
js = loadjson('../ternplots.json');
stns = fieldnames(js);

% Set options for plotting in tern
op.plot = true;
op.endmlabel = {'Mafic Granulite','Biotite Gneiss','Granite Gneiss'};

t = 1:100;
for i = 1 : numel(stns)
%%
    % Get data
    stn = stns{i};
    msVp = js.(stn).ms.Vp;
    wmVp = js.(stn).wm.Vp;
    mbVp = js.(stn).mb.Vp;
    R = js.(stn).hk.R;
    P = poisson(R);
    % Build up data matrix
    data = [maficG(1)  biotiteG(1)  graniteG(1)  msVp;
            maficG(1)  biotiteG(1)  graniteG(1)  wmVp;
            maficG(1)  biotiteG(1)  graniteG(1)  mbVp;
            maficG(4)  biotiteG(4)  graniteG(4)  P];
    % Set title and data legends
    %op.title = ['station: ', stn];
    op.datalabel = {['shot Vp: ', num2str(msVp)],...
                    ['Crust2 Vp: ', num2str(wmVp)],...
                    ['MB Vp: ', num2str(mbVp)],...  
                    ['\alpha: ', num2str(P)]};
    % Set save figure name and flag
    op.savefig = ['../mapping/web/public/images/tern_',stn,'.png'];
    % Display terns and info
    fprintf('%s\n',stn)
    b = tern(data, op);
    if b
        fprintf('Intersects = %f\n', b)
    end

end

%data = [a1, b1, c1, d1;
%        a2, b2, c2, d2;
%        a3, b3, c3, d3];





