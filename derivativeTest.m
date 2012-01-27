% Derivative Test
clear all
close all

mm = 2.^[4:14];
iter = 1;
h = 32; % Starting guesses for physical paramaters
a = 6;
b = 3.5;
tol = 0.001;  % Tolerance on interior linear solve is 10x of Newton solution
itermax = 40; % Stop if we go beyond this iteration number
x = randn(3,1).*0.1;
n = 100;
X = [a;b;h];
%while (iter < round(itermax));
for ii = 1:length(mm)
    
    x = 1/mm(ii)*ones(3,1); %.*X;
    
    p  = linspace(0.03,0.08,n)';
    tps = h*(sqrt(1/b^2 - p.^2) -  sqrt(1/a^2 - p.^2));
    t = tps + 0.1*randn(n,1).*tps;
    
    
    sqrtA = sqrt(1/a^2 - p.^2);
    sqrtB = sqrt(1/b^2 - p.^2);
    
    fp  = (t - h*(sqrtB - sqrtA))' * (t - h*(sqrtB - sqrtA));
    fpx = (t - (h+x(3))*(sqrt(1/(b+x(2))^2 - p.^2) - sqrt(1/(a+x(1))^2 - p.^2)))' *...
        (t - (h+x(3))*(sqrt(1/(b+x(2))^2 - p.^2) - sqrt(1/(a+x(1))^2 - p.^2)));
    
    
    
    % Jacobian %%%%%%
    dfda = (-2*h* (h*(sqrtA - sqrtB) + t)' * (1./( a^3 * sqrtA )));
    dfdb =  (2*h* (h*(sqrtA - sqrtB) + t)' * (1./( b^3 * sqrtB )));
    dfdh =  (2* (sqrtA - sqrtB)' * (h*(sqrtA - sqrtB) + t));
    % Hessian %%%%%%%
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
    
    r1(ii) = abs(fp - fpx);
    r2(ii)  = abs(fp - fpx + J'*x);
    r3(ii) = abs(fp - fpx + J'*x + 1/2 * x'*H*x);
    nx(ii) = norm(x);
end

figure(3333)
semilogy(log2(mm),r1,'b',log2(mm),10*nx,'b--', ...
    log2(mm),r2,'r',log2(mm),100*nx.^2,'r--',...
    log2(mm),r3,'g',log2(mm),200*nx.^3,'g--');
legend('residual','O(h)','Jacobian','O(h^2)','Hessian','O(h^3)')


