function out = pdf_Mixture(x, p, varargin)

    v = varargin;
    
    n = (nargin - 2)/2;
    
    [~, weightFnc] = mixtureWeights(n);
    
    out = weightFnc(p,1)*normpdf(x,v{1},v{n+1});
    
    
    for ii = 2:n
        out = out + weightFnc(p,ii)*normpdf(x,v{ii}, v{n+ii});
    end
end