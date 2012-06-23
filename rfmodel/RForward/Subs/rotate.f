      subroutine rotate(x,m,n,baz,az,npts)
c
c   rotates horz. components of x into radial & tangential components
c      given the back azimuth and their orientations
c
c   baz   = back azimuth from station to source in degrees
c   az(i) = + direction of each horz. comp.
c
c      conventions --
c
c          radial is positive away form source
c          tangential is positive clockwise from + radial direction
c
      dimension x(m,n),az(3)
      rad(deg)=deg/57.295779
      azck=az(2) + 90.
      diff=abs(azck - az(3))
      if(diff.lt..01) go to 1
      if(diff.lt.179.) write(0,100) az(2),az(3),azck,diff
         do 2 i=1,npts
    2     x(i,3)=-x(i,3)
    1 a=sin(rad(baz) - rad(az(2)))
      b=cos(rad(baz) - rad(az(2)))
      do 4 i=1,npts
         radial = -x(i,2)*b - x(i,3)*a
         trans  =  x(i,2)*a - x(i,3)*b
         x(i,2) = radial
         x(i,3) = trans
    4 continue
      return
  100 format(' p r o b l e m   i n   r o t a t e ',/,
     *       1x,'+ horz direction: 1= ',f8.4,' 2= ',f8.4,/,
     *       1x,'for proper rotation 2= ',f8.4,' difference = ',f8.4)
      end
