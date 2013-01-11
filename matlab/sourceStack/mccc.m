function [tdel,rmean,sigr] = mccc(seis, dt, twin)

% FUNCTION [TDEL] = MCCC(SEIS,DT,TWIN);
% Function MCCC determines optimum relative delay times for a
% set of seismograms based on the VanDecar & Crosson multi-channel
% cross-correlation algorithm. SEIS is the set of seismograms. It
% is assumed that this set includes the window of interest and
% nothing more since we calculate the correlation functions in the
% Fourier domain. DT is the sample interval, which may be a vector of
% length size(seis, 1) and TWIN is the window
% about zero in which the maximum search is performed (if TWIN is
% not specified, the search is performed over the entire correlation
% interval).

% Set nt to twice length of seismogram section to avoid
% spectral contamination/overlap. Note we assume that
% columns enumerate time samples, and rows enumerate stations.
nt = size(seis, 2) * 2;
ns = size(seis, 1);
tcc = zeros(ns);
% if length(dt) == 1
%     dt = ones(1, ns) * dt;
% else
%     dt = dt(:)'; 
% end
%Set width of window around 0 time to search for maximum.
mask=ones(1,nt);
if nargin == 3
  itw = fix(twin/(2*dt));
  mask = zeros(1,nt);
  mask(1:itw) = 1.0;
  mask(nt - itw-1:nt) = 1.0;
end

% Determine relative delay times between all pairs of
% traces.
for is = 1 : ns
  ffis = fft(seis(is,:), nt);
  acf = real(ifft([ffis .* conj(ffis)], nt));
  sigt(is) = sqrt( max(acf) );
end
r = zeros(ns,ns);
for is = 1 : ns-1
  ffis = conj( fft(seis(is, :), nt) );
  sigi = sqrt( norm(seis(is, :), 2) );
  for js = is + 1 : ns
    ffjs = fft( seis(js ,:), nt );
    ccf = real( ifft([ffis .* ffjs], nt) ) .* mask;
    [cmax, tcc(is, js)] = max(ccf);

% Compute estimate of cross correlation coefficient.
    r(is,js) = cmax / ( sigt(is) * sigt(js) );
  end
end

% Fisher's transform of cross-correlation coefficients to produce
% normally distributed quantity on which Gaussian statistics
% may be computed and then inverse transformed.
z = 0.5 * log( (1 + r) ./ (1 - r) );
for is=1:ns
  zmean(is) = ( sum(z(is,:)) + sum(z(:,is)) ) / (ns-1);
end
rmean = ( exp(2 * zmean) - 1) ./ ( exp(2 * zmean) + 1 );


% Correct negative delays.
ix = find(tcc > nt / 2);
tcc(ix) = tcc(ix) - (nt + 1);

% Multiply by sample rate.
tcc = tcc * dt;

% Use sum rule to assemble optimal delay times with zero mean.
for is = 1 : ns
  tdel(is)=(-sum(tcc(1 : is - 1, is)) + sum( tcc(is, is + 1 : ns) )) / ns;
end

% Compute associated residuals.
res=zeros(ns,ns);
for is=1:ns-1
  for js=is+1:ns
    res(is,js)=tcc(is,js)-(tdel(is)-tdel(js));
  end
end
for is=1:ns
   sigr(is)=sqrt(sum(res(is,:).^2)+sum(res(:,is).^2)/(ns-2));
end

return
