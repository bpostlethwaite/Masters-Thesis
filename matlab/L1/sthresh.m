function y = sthresh(x,mode)


%{
opFunction   Wrapper for functions.
 
    opFunction(M,N,FUN,CFLAG,LINFLAG) creates a wrapper for function
    FUN, which corresponds to an M-by-N operator. The FUN parameter
    can be one of two types:
 
    1) A handle to a function of the form FUN(X,MODE), where the
       operator is applied to X when MODE = 1, and the transpose is
       applied when MODE = 2;
    2) A cell array of two function handles: {FUN,FUN_TRANSPOSE},
       each of which requires only one parameter, X.
 
    Optional arguments CFLAG and LINFLAG indicate whether the
    function implements a complex or real operator and whether it
    is linear or not. The default values are CFLAG=0, LINFLAG=1.

%}
T = 1;
v = -linspace(-3,3,2000);
% soft thresholding of the t values
v_soft = max(1-T./abs(v), 0).*v;

end
