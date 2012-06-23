#
# Apply a high-pass butterworth filter on a signal
# The original signal is overwritten
#
# mData is the array containing the signal
# n is the number of points in mData
# dt is the sample rate
# fmin is the frequency in hertz
# npasses is the number of passes (1 or 2)
#
#
subroutine hpbufilter(mData, n, dt, fmin, npasses)
#
#
real mData(n), fmin, dt
integer npasses, n
#
real wh, tsqt, dt, c0, c1, c2, d, d1, d2, pi
real x0,x1,x2,gain
integer i, stdout
#
#
pi = acos(-1.0);
tsqt = 2*sqrt(2.0);
stdout = 6
#
#
# make sure fmin is less than the nyquist frequency
#
if(fmin > (1/(2*dt)) || fmin < 0)
{
	write(stdout,*)'Warning from hpbufilter: fmin > nyquist.'
	return;
}
# compute the cutoff frequency
#
wh = fmin * 2 * pi;
#
# Compute the denominator
#
d = (4+wh*wh*dt*dt + tsqt*wh*dt)*wh*wh;
#
# compute the coefficients
c0 =  4 / d;
c1 = -8 / d;
c2 =  4 / d;
#
d1 = -( (2*wh*wh*dt*dt-8) * wh*wh) / d;
#
d2 = -( (-tsqt*wh*dt + 4 + wh*wh*dt*dt) * wh*wh ) / d;
#
gain = wh*wh;
#
# Handle the first two points separately
#
x0 = mData(1) * gain;
mData(1) = c0 * x0;
x1 = x0;
x0 = mData(2) * gain;
mData(2) = c0*x0 + c1*x1 + d1*mData(1);
#
for(i=3;i<=n;i=i+1)
{
    x2 = x1;
    x1 = x0;
    x0 = mData(i) * gain;
    mData(i) = c0*x0 + c1*x1 + c2*x2 + d1*mData(i-1) + d2*mData(i-2);
}
#
# Run it again, backwards if two passes
#
# Handle the last two points separately
#
if(npasses == 2)
{
  x0 = mData(n) * gain;
  mData(n) = c0 * x0;
  x1 = x0;
  x0 = mData(n-1) * gain;
  mData(n-1) = c0 * x0 + c1 * x1 + d1 * mData(n);	
#
  for(i = n-2; i >= 1; i=i-1)
  {
    x2 = x1;
    x1 = x0;
    x0 = mData(i) * gain;
    mData(i) = c0*x0 + c1*x1 + c2*x2 + d1*mData(i+1) + d2*mData(i+2);
  }	
}
#
return
end
#**************************************************************************			
#
# Apply a low-pass butterworth filter on a signal
# The original signal is overwritten
#
# mData is the array containing the signal
# n is the number of points in mData
# dt is the sample rate
# fmax is the frequency in hertz
# npasses is the number of passes (1 or 2)
#
#
subroutine lpbufilter(mData, n, dt, fmax, npasses)
#
#
real mData(n), fmax, dt
integer npasses, n
#
real wl, tsqt, dt, c0, c1, c2, a, d1, d2, pi
real x0,x1,x2,gain
integer i, stdout
#
#
pi = acos(-1.0);
tsqt = 2*sqrt(2.0);
stdout = 6
#
#
# make sure fmin is less than the nyquist frequency
#
if(fmax > (1/(2*dt)) || fmax < 0)
{
	write(stdout,*)'Warning from hpbufilter: fmin > nyquist.'
	return;
}
# compute the cutoff frequency
#
wl = fmax * 2 * pi;
#
# Compute the denominator
#
a = 4 + wl * dt * (  wl*dt + 2.0*sqrt(2.0)  );
#
# compute the coefficients
c0 = (dt*dt) / a;
c1 = 2.0 * c0;
c2 = c0;
d1 = (8 - 2*wl*wl*dt*dt) / a;
d2 = (2.0*sqrt(2.0)*wl*dt - 4 - wl*wl*dt*dt) / a;
gain = wl*wl;
#
#
# Handle the first two points separately
#
x0 = mData(1) * gain;
mData(1) = c0 * x0;
x1 = x0;
x0 = mData(2) * gain;
mData(2) = c0*x0 + c1*x1 + d1*mData(1);
#
for(i=3;i<=n;i=i+1)
{
    x2 = x1;
    x1 = x0;
    x0 = mData(i) * gain;
    mData(i) = c0*x0 + c1*x1 + c2*x2 + d1*mData(i-1) + d2*mData(i-2);
}
#
# Run it again, backwards if two passes
#
# Handle the last two points separately
#
if(npasses == 2)
{
  x0 = mData(n) * gain;
  mData(n) = c0 * x0;
  x1 = x0;
  x0 = mData(n-1) * gain;
  mData(n-1) = c0 * x0 + c1 * x1 + d1 * mData(n);	
#
  for(i = n-2; i >= 1; i=i-1)
  {
    x2 = x1;
    x1 = x0;
    x0 = mData(i) * gain;
    mData(i) = c0*x0 + c1*x1 + c2*x2 + d1*mData(i+1) + d2*mData(i+2);
  }	
}
#
return
end
			
