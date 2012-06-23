c
c Apply a high-pass butterworth filter on a signal
c The original signal is overwritten
c
c mData is the array containing the signal
c n is the number of points in mData
c dt is the sample rate
c fmin is the frequency in hertz
c npasses is the number of passes (1 or 2)
c
c
      subroutine hpbufilter(mdata, n, dt, fmin, npasses)
c
c
      real mdata(n), fmin, dt
      integer npasses, n
c
      real wh, tsqt, c0, c1, c2, d, d1, d2, pi
      real x0,x1,x2,gain
      integer i, stdout
c
c
      pi = acos(-1.0)
      tsqt = 2*sqrt(2.0)
      stdout = 6
c
c
c make sure fmin is less than the nyquist frequency
c
      if(.not.(fmin .gt. (1/(2*dt)) .or. fmin .lt. 0))goto 23000
         write(stdout,*)'Warning from hpbufilter: fmin > nyquist.'
         return
c compute the cutoff frequency
c
23000 continue
      wh = fmin * 2 * pi
c
c Compute the denominator
c
      d = (4+wh*wh*dt*dt + tsqt*wh*dt)*wh*wh
c
c compute the coefficients
      c0 = 4 / d
      c1 = -8 / d
      c2 = 4 / d
c
      d1 = -( (2*wh*wh*dt*dt-8) * wh*wh) / d
c
      d2 = -( (-tsqt*wh*dt + 4 + wh*wh*dt*dt) * wh*wh ) / d
c
      gain = wh*wh
c
c Handle the first two points separately
c
      x0 = mdata(1) * gain
      mdata(1) = c0 * x0
      x1 = x0
      x0 = mdata(2) * gain
      mdata(2) = c0*x0 + c1*x1 + d1*mdata(1)
c
c     for
      i=3
23002 if(.not.(i.le.n))goto 23004
         x2 = x1
         x1 = x0
         x0 = mdata(i) * gain
         mdata(i) = c0*x0 + c1*x1 + c2*x2 + d1*mdata(i-1) + d2*mdata(i-
&         2)
         i=i+1
         goto 23002
c     endfor
23004 continue
c
c Run it again, backwards if two passes
c
c Handle the last two points separately
c
      if(.not.(npasses .eq. 2))goto 23005
         x0 = mdata(n) * gain
         mdata(n) = c0 * x0
         x1 = x0
         x0 = mdata(n-1) * gain
         mdata(n-1) = c0 * x0 + c1 * x1 + d1 * mdata(n)
c
c        for
         i = n-2
23007    if(.not.(i.ge.1))goto 23009
            x2 = x1
            x1 = x0
            x0 = mdata(i) * gain
            mdata(i) = c0*x0 + c1*x1 + c2*x2 + d1*mdata(i+1) + d2*mdata(
&            i+2)
             i=i-1
            goto 23007
c        endfor
23009    continue
c
23005 continue
      return
      end
c**************************************************************************			
c
c Apply a low-pass butterworth filter on a signal
c The original signal is overwritten
c
c mData is the array containing the signal
c n is the number of points in mData
c dt is the sample rate
c fmax is the frequency in hertz
c npasses is the number of passes (1 or 2)
c
c
      subroutine lpbufilter(mdata, n, dt, fmax, npasses)
c
c
      real mdata(n), fmax, dt
      integer npasses, n
c
      real wl, tsqt, c0, c1, c2, a, d1, d2, pi
      real x0,x1,x2,gain
      integer i, stdout
c
c
      pi = acos(-1.0)
      tsqt = 2*sqrt(2.0)
      stdout = 6
c
c
c make sure fmin is less than the nyquist frequency
c
      if(.not.(fmax .gt. (1/(2*dt)) .or. fmax .lt. 0))goto 23010
         write(stdout,*)'Warning from hpbufilter: fmin > nyquist.'
         return
c compute the cutoff frequency
c
23010 continue
      wl = fmax * 2 * pi
c
c Compute the denominator
c
      a = 4 + wl * dt * ( wl*dt + 2.0*sqrt(2.0) )
c
c compute the coefficients
      c0 = (dt*dt) / a
      c1 = 2.0 * c0
      c2 = c0
      d1 = (8 - 2*wl*wl*dt*dt) / a
      d2 = (2.0*sqrt(2.0)*wl*dt - 4 - wl*wl*dt*dt) / a
      gain = wl*wl
c
c
c Handle the first two points separately
c
      x0 = mdata(1) * gain
      mdata(1) = c0 * x0
      x1 = x0
      x0 = mdata(2) * gain
      mdata(2) = c0*x0 + c1*x1 + d1*mdata(1)
c
c     for
      i=3
23012 if(.not.(i.le.n))goto 23014
         x2 = x1
         x1 = x0
         x0 = mdata(i) * gain
         mdata(i) = c0*x0 + c1*x1 + c2*x2 + d1*mdata(i-1) + d2*mdata(i-
&         2)
         i=i+1
         goto 23012
c     endfor
23014 continue
c
c Run it again, backwards if two passes
c
c Handle the last two points separately
c
      if(.not.(npasses .eq. 2))goto 23015
         x0 = mdata(n) * gain
         mdata(n) = c0 * x0
         x1 = x0
         x0 = mdata(n-1) * gain
         mdata(n-1) = c0 * x0 + c1 * x1 + d1 * mdata(n)
c
c        for
         i = n-2
23017    if(.not.(i.ge.1))goto 23019
            x2 = x1
            x1 = x0
            x0 = mdata(i) * gain
            mdata(i) = c0*x0 + c1*x1 + c2*x2 + d1*mdata(i+1) + d2*mdata(
&            i+2)
             i=i-1
            goto 23017
c        endfor
23019    continue
c
23015 continue
      return
      end
