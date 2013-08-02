% ZK derivative calcs

H = 36
V = 6.26
R = 1.75
p = 0.06;
t = H * ( sqrt( (R^2/V^2) - p^2) - sqrt( 1/V^2 - p^2 ) );

dHdV = -t * ( sqrt( (R^2/V^2) - p^2) - sqrt( 1/V^2 - p^2 ) )^(-2) * ...
    ( ( R^2/V^2 - p^2)^(-1/2) * (-R^2/V^3) - ...
      (1/V^2 - p^2)^(-1/2) * (-1/V^3) )


dv = 0.25;
dh = dHdV * dv;


fprintf('for a dv of %1.2f get a %2.2f change in dh\n', dv, dh);