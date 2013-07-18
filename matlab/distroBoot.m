% distibution analysis
close all
clear all
addpath functions

x = [trnd(20,1,50) trnd(4,1,100)+3 trnd(2,1,100)-2];
%hist(x,-2.25:.5:7.25);
%bar(bins,histc(x,bins)/(length(x)*.5),'histc');

n = 3;
breaks = [.25 .55 .85];
%a = nModeDist(x, n, breaks);

%%
[pn, weightFnc] = mixtureWeights(n);

%pdf_normmixture = @(x,p,mu1,mu2,sigma1,sigma2) ...
%    weightFnc(p,1)*normpdf(x,mu1,sigma1) + ...
%    weightFnc(p,2)*normpdf(x,mu2,sigma2);

% pdf_normmixture = @pdf_Mixture;
% 
% pStart = 1/n;
% muStart = quantile(x, breaks);
% sigmaStart = sqrt(var(x) - .25*diff(muStart).^2);
% start = [pStart muStart sigmaStart sigmaStart];
% 
% lb = [0 -Inf -Inf 0 0];
% ub = [1 Inf Inf Inf Inf];
% 
% 
% options = statset('MaxIter',500, 'MaxFunEvals',600);
% paramEsts = mle(x, 'pdf',pdf_normmixture, 'start',start, ...
%     'lower',lb, 'upper',ub, 'options',options);

paramEsts = {nModeDist(x, n, breaks)};


bins = -2.5:.5:7.5;
h = bar(bins,histc(x,bins)/(length(x)*.5),'histc');
set(h,'FaceColor',[.9 .9 .9]);
xgrid = linspace(1.1*min(x),1.1*max(x),200);
pdfgrid = pdf_Mixture(xgrid, paramEsts{:});
hold on; plot(xgrid,pdfgrid,'-'); hold off
xlabel('x'); ylabel('Probability Density');

acov = mlecov(paramEsts, x, 'pdf', pdf_Mixture);
se = sqrt(diag(acov));

% n probs
%%

