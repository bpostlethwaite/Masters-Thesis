c#  delaz - calculate geocentric postitions, distances, and azimuths
      subroutine delaz2(lat, lon, delta, az0, az1,iflag)
      implicit none
C      implicit undefined (a-z)
c
c   ken creager 6/11/87
c
      real lat, lon
      real delta, az0, az1
      integer iflag
      real st0, ct0, phi0
      real st1, ct1, dlon
      real sdlon, cdlon
      real cz0
      real sdelt, cdelt
      save st0, ct0, phi0

      if (iflag .eq. 0) then
c . . . store the geocentric coordinates of the reference point
        st0 = cos(lat)
        ct0 = sin(lat)
        phi0 = lon

      else if (iflag .eq. 1) then
c . . . calculate the geocentric distance, azimuths
        ct1 = sin(lat)
        st1 = cos(lat)
        sdlon = sin(lon - phi0)
        cdlon = cos(lon - phi0)
        cdelt = st0*st1*cdlon + ct0*ct1
        call cvrtop (st0*ct1-st1*ct0*cdlon, st1*sdlon, sdelt, az0)
        delta = atan2(sdelt, cdelt)
        call cvrtop (st1*ct0-st0*ct1*cdlon, -sdlon*st0, sdelt, az1)
        if (az0 .lt. 0.0) az0 = az0 + (2.0*3.14159265)
        if (az1 .lt. 0.0) az1 = az1 + (2.0*3.14159265)

      else if (iflag .eq. 2) then
c . . . back - calculate geocentric coordinates of secondary point from delta, az
        sdelt = sin(delta)
        cdelt = cos(delta)
        cz0 = cos(az0)
        ct1 = st0*sdelt*cz0 + ct0*cdelt
        call cvrtop (st0*cdelt-ct0*sdelt*cz0, sdelt*sin(az0),st1,dlon)
        lat = atan2(ct1, st1)
        lon = phi0 + dlon
        if(abs(lon) .gt. 3.14159265)
     &     lon = lon - sign((2.0*3.14159265), lon)
      endif
      return
      end

c cvrtop - convert from rectangular to polar coordinates
      subroutine cvrtop(x, y, r, theta)
c . . input
      real x, y
c . . output - may overlay x, y
      real r, theta
      real rad
      real hypot
      rad = hypot(x, y)
      theta = atan2(y, x)
      r = rad
      return
      end

c hypot - euclidian distance, accurately and avoiding overflow
      real function hypot(a, b)
      real a, b
c
      real abs, l, s, t
c
c . . set s, l to be absolutely smallest, largest values
      l = abs(a)
      s = abs(b)
      if (s .le. l) goto 1
         t = s
         s = l
         l = t
   1  continue
c
c compute and return distance
      if (l .ne. 0.0) goto 2
         hypot = 0.0
         return
   2  continue
      s = s/l
      hypot = l*sqrt(s*s+1.0)
      return
      end
