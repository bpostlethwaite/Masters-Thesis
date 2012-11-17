function [rft,xft,betax] = simdecf(wft,vft,betan)

% SIMDECF Simultaneous deconvolution of multiple seismograms in
% the frequency domain. Inputs are wavelet estimates WFT, data
% VFT (both in frequency domain and of dimension M X N where
% M is number of seismograms and N is number of frequencies),
% and regularization parameter BETAN. If BETAN < 0 then
% an optimum parameter BETAX is sought using Generalized Cross
% Validation and used to produce impulse response RFT, and model
% resolution kernel XFT. 

% Calculate dimensions of wft, and assume that minimum dimension is
% number of traces, maximum size is number of frequencies.
nm = min(size(wft));
nn = max(size(wft));

% Compute denominators.
if nm == 1
  wwft = wft.*conj(wft);
  vwft = vft.*conj(wft);
else
  wwft = sum(wft .* conj(wft));
  vwft = sum(vft .* conj(wft));
end

% If nonzero betan provided by user, use it for deconvolution.
% Otherwise compute best beta using Generalized Cross Validation.
if betan > 0
  betax = betan;
else
  beta = exp(-12 : 0.2 : 15);
  gcvf = zeros(1, length(beta));
  for ib = 1:length(beta);

% Define operator W W* / (W W* + B) and deconvolve to get impulse response in
% frequency domain.
    wwft2 = wwft + beta(ib);
    rft = vwft ./ wwft2;
    xft = wwft ./ wwft2;

% Compute model norm.
    %modnorm(ib)=norm(rft)^2;

% Compute data misfit. Note misfit is numerator of GCV function.
% Note also earlier mistake where norm(nft)^2 was norm(nft).
    if nm == 1
      nft = vft - wft .* rft;
      misfit = norm(nft)^2;
    else
      misfit = 0.0;
      for im = 1 : nm
        nft = vft(im,:) - wft(im,:) .* rft;
        misfit = misfit + norm(nft)^2;
      end
    end

% Compute denominator and GCV function.
    den = nn * nm - real(sum(xft));
    den = den * den;
    gcvf(ib) = misfit / den;
  end

% Compute best beta.
  [~, ibest] = min(gcvf);
  betax = beta(ibest);

% If minimum not found inform user.
  if ibest == 1
    %fprintf('WARNING: No minimum found for GCV');
    %disp('index at minimum and no of seismograms');
    %disp('change search limits')
    betax = -inf;
    return
  end
  if ibest == length(beta)
    %fprintf('WARNING: No minimum found for GCV');
    betax = inf;
    %disp('index at maximum and no of seismograms');
    %fprintf('WARNING: No minimum found for GCV');
    %disp('change search limits')
    return
  end

end

% Final estimate.
wwft2 = wwft + betax;
rft=vwft ./ wwft2;
xft=wwft ./ wwft2;
