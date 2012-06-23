C     KBTAPER -- Return values for Kaiser-Bessel taper
C
C     Called via
C        call kbtaper(a,n,tap)
C
C     Assumes:
C        a - taper order (2<=a<=5).  2*pi*a is the time-bandwidth product TW.
C            In this product, the time T is the span of the non-zero part of the
C            function in the time domain, and the frequency window W is the
C            span of non-zero frequencies W in the frequency domain.
C        n - number of points
C
C     Returns:
C
C        tap - values for taper (array of size n)
C
C     Method:  See Harris, F. (1978), "On the use of windows for harmonic
C        analysis with the discrete Fourier transform," Proc. IEEE 66, 51-83.
C
C     by G. Helffrich/U. Bristol 8 Jan. 2003

      subroutine kbtaper(a,n,tap)
      real tap(n)

      pi = 4.0*atan(1.0)
      pia = pi*a
      eye0pa = bessi0(pia)
      j = n/2

C     Add middle point if n odd
      if (1 .eq. mod(n,2)) tap(1+j) = 1.0
      do i=1,n/2
         val = bessi0(pia*sqrt(1.0 - 4*(float(i)/float(n))**2))/eye0pa
	 tap(1+j-i) = val
	 tap(  j+i) = val
      enddo
      end

      FUNCTION bessi0(x)
      REAL bessi0,x
      REAL ax
      DOUBLE PRECISION p1,p2,p3,p4,p5,p6,p7,q1,q2,q3,q4,q5,q6,q7,q8,q9,y
      SAVE p1,p2,p3,p4,p5,p6,p7,q1,q2,q3,q4,q5,q6,q7,q8,q9
      DATA p1,p2,p3,p4,p5,p6,p7/1.0d0,3.5156229d0,3.0899424d0,
     *1.2067492d0,0.2659732d0,0.360768d-1,0.45813d-2/
      DATA q1,q2,q3,q4,q5,q6,q7,q8,q9/0.39894228d0,0.1328592d-1,
     *0.225319d-2,-0.157565d-2,0.916281d-2,-0.2057706d-1,0.2635537d-1,
     *-0.1647633d-1,0.392377d-2/
      if (abs(x).lt.3.75) then
        y=(x/3.75)**2
        bessi0=p1+y*(p2+y*(p3+y*(p4+y*(p5+y*(p6+y*p7)))))
      else
        ax=abs(x)
        y=3.75/ax
        bessi0=(exp(ax)/sqrt(ax))*(q1+y*(q2+y*(q3+y*(q4+y*(q5+y*(q6+y*
     *(q7+y*(q8+y*q9))))))))
      endif
      return
      END
