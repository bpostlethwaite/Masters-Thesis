function [ Tps,h,a,b ] = newtonFit(h,a,b,p,t,itermax,tol,s, fh)
%NEWTONFIT Newton solver to solve for a non-linear regression
%   Uses starting guesses and IRLS solver to find solution.
iter = 1;
TpsP = 0;
deltaTps = 100;
q = figure(fh);
p2 = p.^2;
%x = 1:length(p);
while (iter < round(itermax)) && (deltaTps > tol);

    % Partials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sqrtA = sqrt(1/a^2 - p2);
    sqrtB = sqrt(1/b^2 - p2);

    % Jacobian %%%%%%
    dfda = (-2*h* (h*(sqrtA - sqrtB) + t)' * (1./( a^3 * sqrtA )));
    dfdb =  (2*h* (h*(sqrtA - sqrtB) + t)' * (1./( b^3 * sqrtB )));
    dfdh =  (2* (sqrtA - sqrtB)' * (h*(sqrtA - sqrtB) + t));
    % Hessian %%%%%%%
    dfhh = 2*( sqrtA - sqrtB)' * (sqrtA - sqrtB);
    dfah = -2* ( 2*h* (sqrtA - sqrtB) + t)' * (1./(a^3 * sqrtA)) ;
    dfbh =  2* ( 2*h* (sqrtA - sqrtB) + t)' * (1./(b^3 * sqrtB)) ;
    dfaa = 2*h *( h*(-3*a^2*p2.*sqrtB + 3*a^2*p2.*sqrtA - 3*sqrtA + 2*sqrtB) + ...
        t .* (3*a^2 *p2 - 2) )' * (1./(a^4 * sqrtA .* (a^2* p2 - 1)));
    dfbb = 2*h *( h*(-2*b^2 *(sqrtA.*sqrtB + 3*p2) + ...
        3*b^4*(p2 .* sqrtA.*sqrtB + p.^4) + 3) + ...
        b^2.*t.*sqrtB.*(3*b^2 .*p2 - 2))' * (1./(b^4 * (b^2*p2 - 1).^2));
    dfab = sum( -2*h^2 ./ ( a^2 * b^2 * sqrt(1-a^2*p2).*sqrt(1-b^2*p2)));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    J = [dfda; dfdb; dfdh]; % Jacobian
    H = [dfaa, dfab, dfah
         dfab, dfbb, dfbh
         dfah, dfbh, dfhh]; % Hessian
    %if iter == 1
    %    fprintf('----prerun-----\n')
    %    fprintf('J Matrix\n')
    %    full(J)
    %    fprintf('Eig(H)\n')
    %    eig(H)
    %end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    delm = (IRLSsolver(-H,J,40,0.001*tol)); % Linear reweighted solution
    %delm = -H\J(:); %L2 Solver
    a = (a + s*delm(1));
    b = (b + s*delm(2)); % move in direction of residual
    h = (h + s*delm(3));
    % STOPPING CRITEREA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Tps = h*(sqrt(1/b^2 - p2) -  sqrt(1/a^2 - p2));
    deltaTps = norm(Tps - TpsP);
    TpsP = Tps;
    iter = iter+1;
    % Real Time Fit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %

    plot(p, t, '*', p, Tps, 'g')
    title('residual vector and Minimum norm solution')
    xlabel('pslow')
    ylabel('tps residual')
    pause(0.05)
    %}

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %fprintf('----postrun-----\n')
        %fprintf('J Matrix\n')
        %full(J)
        %fprintf('Eig(H)\n')
        %eig(H)

% Check if iter hit itermax, if so issue warning %%%%%%%%
if iter == itermax
    fprintf(['Newton''s Method reached Max Iteration of %i!\n',...
        'Convergence norm at: %f \n'],iter,deltaTps)
end

