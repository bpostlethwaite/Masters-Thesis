C     HILBTF -- Return hilbert transform of a real-valued time series.
C
C     Called via hilbtf(tsin,tsout,n,nmax)
C
C     Assumes:
C        tsin - time series input value (real array)
C        n - number of actual data points in tsin (and tsout)
C        nmax - size of tsin (and tsout) arrays (should be power of two)
C
C     Returns:
C        tsout - hilbert transformed time series (real array)
C
C     Uses:  realft and four1 from Numerical Recipes.
C
C     G. Helffrich/U. Bristol/4 Feb. 2002

      subroutine hilbtf(tsin, tsout, n, nmax)
      real tsin(nmax), tsout(nmax)

      npow2 = 1
      do i=1,30
         if (npow2 .ge. n) go to 10
         npow2 = 2*npow2
      enddo
      pause '**HILBTF:  Too much data.'

10    continue
      if (npow2 .gt. nmax) pause '**HILBTF:  Array not big enough.'
C     Pad data to next power of two
      do i=1,npow2
         if (i .le. n) then
	    tsout(i) = tsin(i)
	 else
	    tsout(i) = 0.0
	 endif
      enddo
C     Fourier transform
      call realft(tsout,npow2,+1)
C     F[H(t)] is i*F[t], or Re(f)->Im(f) and -Im(f)->Re(f)
      do i=3,npow2,2
         swap = -tsout(i+1)
	 tsout(i+1) = tsout(i)
	 tsout(i) = swap
      enddo
C     First two values are zero frequency and max. frequency values (both real)
C        Save first as mean, zero second (since we can't represent its
C        transformed value).
C     avg = tsout(1)
      avg = 0.0
      factor = 2./n
      tsout(2) = 0.0
      tsout(1) = 0.0
      call realft(tsout,npow2,-1)
      do i=1,n
         tsout(i) = avg + tsout(i)*factor
      enddo
      end
