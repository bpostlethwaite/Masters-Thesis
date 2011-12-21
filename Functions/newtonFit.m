function [ Tps,H,alpha,beta ] = newtonFit(H,alpha,beta,pslow,tps,itermax,tol)
%NEWTONFIT Newton solver to solve for a non-linear regression
%   Uses starting guesses and IRLS solver to find solution.

iter = 1;
s = 0.2; % Slow down the step sizes in Newton method, it is unstable.
TpsPrev = 0;
deltaT = 100;

while (norm(deltaT,'inf')) > tol && (iter < round(itermax));

    f = H*(sqrt(1/beta^2 - pslow.^2) - sqrt(1/alpha^2 - pslow.^2)); % tps function
    r = (f - tps'); % Residual we will be minimizing
    drdH = f/H; % dr/dh
    drda = (H/alpha^3) ./ (sqrt(1/alpha^2 - pslow.^2)); % drda
    drdb = (-H/beta^3) ./ (sqrt(1/beta^2 - pslow.^2)); % drdb
    J = [drdH(:),drda(:),drdb(:)]; % Jacobian
    delm = IRLSsolver(-J,r(:),round(0.5*itermax),10*tol); % Linear reweighted solution with 10x tolerance of Newton
    H = (H + s*delm(1));
    alpha = (alpha + s*delm(2));
    beta = (beta + s*delm(3)); % move in direction of residual
    iter = iter + 1; % Increase iteration.
    
    Tps = H*(sqrt(1/beta^2 - pslow.^2) - sqrt(1/alpha^2 - pslow.^2));
    deltaT = Tps - TpsPrev;  
    TpsPrev = Tps;

end
fprintf('Convergence of Newton: %f at iteration %i\n',norm(deltaT,'inf'),iter)
end

