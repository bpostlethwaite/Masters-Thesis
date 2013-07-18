function paramEsts = nModeDist(x, n, breaks)


pStart = 1/n;
muStart = quantile(x, breaks);
d = diff(muStart);
sigmaStart = sqrt(var(x) - 0.5*pStart*[d, min(d)].^2);
start = [pStart muStart sigmaStart];

assert(length(start) == 2*n + 1)

lb = [0 -inf(1,n) zeros(1,n)];
ub = [1 inf(1,2*n)];

paramEsts = 0;
options = statset('MaxIter',500, 'MaxFunEvals',600);



paramEsts = mle(x, 'pdf',@pdf_Mixture, 'start',start, ...
    'lower',lb, 'upper',ub, 'options',options);

