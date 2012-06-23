      subroutine h12(mode,lpivot,l1,m,u,iue,up,c,ice,icv,ncv)
c
c     from lawson and hanson
c
      dimension u(iue,m),c(1)
      double precision sm,b
      one=1.
      if(0.ge.lpivot.or.lpivot.ge.l1.or.l1.gt.m) return
      cl=abs(u(1,lpivot))
      if(mode.eq.2) go to 60
         do 10 j=l1,m
   10    cl=amax1(abs(u(1,j)),cl)
      if(cl) 130,130,20
   20 clinv=one/cl
      sm=(dble(u(1,lpivot))*clinv)**2
         do 30 j=l1,m
   30    sm=sm+(dble(u(1,j))*clinv)**2
      sm1=sm
      cl=cl*sqrt(sm1)
      if(u(1,lpivot)) 50,50,40
   40 cl=-cl
   50 up=u(1,lpivot)-cl
      u(1,lpivot)=cl
      go to 70
   60 if(cl) 130,130,70
   70 if(ncv.le.0) return
      b=dble(up)*u(1,lpivot)
      if(b) 80,130,130
   80 b=one/b
      i2=1-icv+ice*(lpivot-1)
      incr=ice*(l1-lpivot)
         do 120 j=1,ncv
         i2=i2+icv
         i3=i2+incr
         i4=i3
         sm=c(i2)*dble(up)
            do 90 i=l1,m
            sm=sm+c(i3)*dble(u(1,i))
   90       i3=i3+ice
         if(sm) 100,120,100
  100    sm=sm*b
         c(i2)=c(i2)+sm*dble(up)
            do 110 i=l1,m
            c(i4)=c(i4)+sm*dble(u(1,i))
  110       i4=i4+ice
  120    continue
  130 return
      end
