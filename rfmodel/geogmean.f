      subroutine gmean(n,slat,slon,radius,mlat,mlon)
C     GMEAN -- Calculate a mean location of a collection of geographic
C              data points.
C
C     The data points are inversely weighted based on their spatial
C     density based on an "averaging radius."  If the radius is large,
C     the points are evenly weighted and an unweighted average is
C     returned.  If the radius is so small such that each point is
C     no closer than this to another, then the points are also evenly
C     weighted, and an unweighted average results.  Between these extremes
C     you can achieve different types of weighting by adjusting radius.
C
C     Assumes:
C        n - number of lat, lon pairs
C        slat - latitude (real array, degrees)
C        slon - longitude (real array, degrees)
C        radius - averaging radius.
C
C     Returns:
C        mlat - mean latitude
C        mlon - mean longitude 
      real slat(n),slon(n),mlat,mlon
      parameter (e2geo=0.993305615, e2equ=0.99776354)
      data e2/e2geo/

      pi = 4.0*atan(1.0)
      sumx = 0.0
      sumy = 0.0
      sumz = 0.0
      do 2000 i=1,n
	 k = 0
	 if (radius .gt. 0.0) then
	    do 2100 j=1,n
	       if (j .eq. i) go to 2100
	       call gcd(slat(i),slon(i),slat(j),slon(j),del,
     +            delkm,az,baz)
	       if (del .le. radius) k = k + 1
2100        continue
         endif
	 wt = 1./(k+1)
	 call dircos(slat(i),slon(i),sla,slo,cla,clo,dsla,dcla,
     +      x,y,z)
	 sumx = sumx + wt*x
	 sumy = sumy + wt*y
	 sumz = sumz + wt*z
2000  continue

C     Now find weighted vector mean.
      d = sqrt(sumx**2 + sumy**2 + sumz**2)
      xm = sumx/d
      ym = sumy/d
      zm = sumz/d
      glat = asin(zm)
      glon = atan2(ym,xm)
      mlat = atan2(zm,e2*sqrt(1.-zm**2))*180.0/pi
      mlon = glon*180.0/pi
      end
