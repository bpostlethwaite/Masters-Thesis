function [Crec] = performCurveletDenoise(brec,dt,thresh)

% Process only first 30 seconds of reciever plot
len = round(30/dt);
f = brec(:, 1 : len);
M = f';
[mm,nn] = size(M);
options.null = 0;
options.finest = 1;
options.nbscales = 4;
options.nbangles_coarse = 16;
options.is_real = 1;
options.n = nn;
options.m = mm;

%% For testing proper thresholds
%
MW = perform_curvelet_transform(M, options);

TT = 0.01:0.1:4;
for ii = 1:length(TT)
    T = TT(ii);
    MWT = perform_thresholding(MW, T, 'hard');  
    M1 = perform_curvelet_transform(MWT, options);

    figure(332211)
    subplot(1,2,1)
    csection(M',0,dt)
    subplot(1,2,2)
    csection(M1',0,dt)
    pause(0.5)  
end
%}
%% Curvelet Denoising - Shift Invariance
T = thresh; % Set Threshold T
m = 4; % Set dimensions of circle shifting (m^2 shifts)
% Generate Shifts
[dY,dX] = meshgrid(0:m-1,0:m-1);
delta = [dX(:) dY(:)]';
MTI = zeros(mm,nn);

for ii = 1:m^2;
    %Apply the shift, using circular boundary conditions.
    MS = circshift(M,delta(:,ii));
    
    %Apply here the denoising to fS.
    MW = perform_curvelet_transform(MS,options);
    MWT = perform_thresholding(MW,T,'soft');
    MS = perform_curvelet_transform(MWT,options);
    
    %After denoising, do the inverse shift.
    MS = circshift(MS,-delta(:,ii));
    
    %Accumulate the result to obtain at the end the denoised image that
    % average the translated results.
    MTI = (ii-1)/ii*MTI + 1/ii*MS;
    
end
%{
figure(3322)
subplot(1,2,1)
csection(M',0,dt)
subplot(1,2,2)
csection(MTI',0,dt)
%}

Crec = [MTI',brec(:, len + 1 : end)];
