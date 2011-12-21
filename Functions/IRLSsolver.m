function  x  = IRLSsolver(A,y,itermax,tol)
%IRLSSOLVER Uses an iterative rewieghted least squares solver for system
%

x = (A'*A)\(A'*y);
eps = max(abs(y))/100; % Decent Recommendation for eps.
deltax = 100; % some starting value above while condition
xprev = 0; % initial xprevious = 0
iter = 1;

while (norm(deltax,'inf')  > tol) && (iter <= itermax)
    r = abs(A*x - y); % Residual
    r(r<eps) = eps; % Set all values below eps to eps for stability
    w = eps./r; % Elements of W are between eps/rmax and 1;
    W = diag(w); % Diagonalize
    x = (A'*W*A)'\(A'*W*y); % Weighted L2 solution
    deltax = x - xprev;
    % Update variables
    xprev = x;
    iter = iter + 1;
  
end

if iter == itermax
    fprintf(['IRLS solution reached Max Iteration of %i!\n',...
        'IRLS Convergence norm at: %f \n'],iter,norm(deltax,'inf'))
end