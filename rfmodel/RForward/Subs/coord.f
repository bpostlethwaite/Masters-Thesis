      subroutine coord(x,theta,delta,y,trans,same)
c
c  transforms a vector x in one coordinate system to a vector y
c    in another coordinate system defined by strike of theta
c    and a dip of delta where y' is the strike direction and
c    z' is the dip direction of the new system wrt to x and z of
c    the old system respectively
c
c    trans defines the direction of the transform --
c     if trans = 'local' then y will be in the primed system
c     if trans = 'globe' then y will be in the original system
c
c    if same = .true. then the transformation matrix is not recalculted
c                          from the previous call
c
      dimension x(3),y(3),a(3,3)
      character trans*5
      logical same
      integer ounit
      common /innout/ inunit,ounit
      common /cord/ a
      if(same) go to 4
      cost=cos(theta)
      sint=sin(theta)
      cosd=cos(delta)
      sind=sin(delta)
      a(1,1)=cost
      a(2,1)=-cosd*sint
      a(3,1)=sind*sint
      a(1,2)=sint
      a(2,2)=cosd*cost
      a(3,2)=-sind*cost
      a(1,3)=0.
      a(2,3)=sind
      a(3,3)=cosd
   4  if(trans.eq.'globe') go to 1
      if(trans.ne.'local') go to 5
      do 2 i=1,3
    2    y(i)=a(i,1)*x(1)+a(i,2)*x(2)+a(i,3)*x(3)
      return
    1 do 3 i=1,3
    3    y(i)=a(1,i)*x(1)+a(2,i)*x(2)+a(3,i)*x(3)
      return
    5 write(ounit,101) trans
  101 format(' trans = ',a5,' in coord, no transformation done')
      return
      end
