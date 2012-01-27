function [ Tps,h,a,b ] = newtonFit(h,a,b,p,t,itermax,tol)
%NEWTONFIT Newton solver to solve for a non-linear regression
%   Uses starting guesses and IRLS solver to find solution.

iter = 1;
s = 0.2;
while (iter < round(itermax));
    
    % Partials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sqrtA = sqrt(1/a^2 - p.^2);
    sqrtB = sqrt(1/b^2 - p.^2);
    % Jacobian %%%%%%%%%%%%%
    dfda = (-2*h* (h*(sqrtA - sqrtB) + t)' * (1./( a^3 * sqrtA )));
    dfdb =  (2*h* (h*(sqrtA - sqrtB) + t)' * (1./( b^3 * sqrtB )));
    dfdh =  (2* (sqrtA - sqrtB)' * (h*(sqrtA - sqrtB) + t));
    % Hessian %%%%%%%%%%%%%%
    dfhh = 2*( sqrtA - sqrtB)' * (sqrtA - sqrtB);
    dfah = -2* ( 2*h* (sqrtA - sqrtB) + t)' * (1./(a^3 * sqrtA)) ;
    dfbh =  2* ( 2*h* (sqrtA - sqrtB) + t)' * (1./(b^3 * sqrtB)) ;
    dfaa = 2*h *( h*(-3*a^2*p.^2.*sqrtB + 3*a^2*p.^2.*sqrtA - 3*sqrtA + 2*sqrtB) + ...
        t .* (3*a^2 *p.^2 - 2) )' * (1./(a^4 * sqrtA .* (a^2* p.^2 - 1))); 
    dfbb = 2*h *( h*(-2*b^2 *(sqrtA.*sqrtB + 3*p.^2) + ...
        3*b^4*(p.^2 .* sqrtA.*sqrtB + p.^4) + 3) + ...
        b^2.*t.*sqrtB.*(3*b^2 .*p.^2 - 2))' * (1./(b^4 * (b^2*p.^2 - 1).^2));   
    dfab = sum( -2*h^2 ./ ( a^2 * b^2 * sqrt(1-a^2*p.^2).*sqrt(1-b^2*p.^2)));   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
    J = [dfda; dfdb; dfdh]; % Jacobian
    H = [dfaa, dfab, dfah
         dfab, dfbb, dfbh
         dfah, dfbh, dfhh]; % Hessian
    %} 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %{
    J = [dfda; dfdb]; % Jacobian
    H = [dfaa, dfab
         dfab, dfbb];
    %}     
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    delm = (IRLSsolver(-H,J,round(itermax),tol)); % Linear reweighted solution with 10x tolerance of Newton
    %delm = -H\J(:) %L2 Solver
    a = (a + s*delm(1));
    b = (b + s*delm(2)); % move in direction of residual
    h = (h + s*delm(3));
    % STOPPING CRITEREA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 
fprintf('Convergence of Newton: %f at iteration %i\n',norm(delm,2),iter)
iter = iter+1;

Tps = h*(sqrt(1/b^2 - p.^2) -  sqrt(1/a^2 - p.^2));
figure(369)
    plot(p,t,'*',p,Tps)
    title('residual vector and Minimum norm solution')
    xlabel('pslow')
    ylabel('tps residual')
    pause(0.1)
end

Tps = h*(sqrt(1/b^2 - p.^2) -  sqrt(1/a^2 - p.^2));
