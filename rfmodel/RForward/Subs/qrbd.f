      subroutine qrbd(ipass,q,e,nn,v,mdv,nrv,c,mdc,ncc)
c
c    from lwason and hanson
c
      logical wntv,havers,fail
      dimension q(nn),e(nn),v(mdv,nn),c(mdc,ncc)
      zero=0.
      one=1.
      two=2.
      n=nn
      ipass=1
      if(n.le.0) return
      n10=n*10
      wntv=nrv.gt.0
      havers=ncc.gt.0
      fail=.false.
      nqrs=0
      e(1)=zero
      dnorm=zero
         do 10 j=1,n
   10    dnorm=amax1(abs(q(j))+abs(e(j)),dnorm)
         do 200 kk=1,n
         k=n+1-kk
   20    if(k.eq.1) go to 50
         if(diffr(dnorm+q(k),dnorm)) 50,25,50
   25    cs=zero
         sn=-one
            do 40 ii=2,k
            i=k+1-ii
            f=-sn*e(i+1)
            e(i+1)=cs*e(i+1)
            call g1(q(i),f,cs,sn,q(i))
            if(.not.wntv) go to 40
               do 30 j=1,nrv
   30          call g2(cs,sn,v(j,i),v(j,k))
   40       continue
   50       do 60 ll=1,k
            l=k+1-ll
            if(diffr(dnorm+e(l),dnorm)) 55,100,55
   55       if(diffr(dnorm+q(l-1),dnorm)) 60,70,60
   60       continue
         go to 100
   70    cs=zero
         sn=-one
            do 90 i=l,k
            f=-sn*e(i)
            e(i)=cs*e(i)
            if(diffr(dnorm+f,dnorm)) 75,100,75
   75       call g1(q(i),f,cs,sn,q(i))
            if(.not.havers) go to 90
               do 80 j=1,ncc
   80          call g2(cs,sn,c(i,j),c(l-1,j))
   90       continue
  100    z=q(k)
         if(l.eq.k) go to 170
         x=q(l)
         y=q(k-1)
         g=e(k-1)
         h=e(k)
         f=((y-z)*(y+z)+(g-h)*(g+h))/(two*h*y)
         g=sqrt(one+f**2)
         if(f.lt.zero) go to 110
         t=f+g
         go to 120
  110    t=f-g
  120    f=((x-z)*(x+z)+h*(y/t-h))/x
         cs=one
         sn=one
         lp1=l+1
            do 160 i=lp1,k
            g=e(i)
            y=q(i)
            h=sn*g
            g=cs*g
            call g1(f,h,cs,sn,e(i-1))
            f=x*cs+g*sn
            g=-x*sn+g*cs
            h=y*sn
            y=y*cs
            if(.not.wntv) go to 140
               do 130 j=1,nrv
  130          call g2(cs,sn,v(j,i-1),v(j,i))
  140       call g1(f,h,cs,sn,q(i-1))
            f=cs*g+sn*y
            x=-sn*g+cs*y
            if(.not.havers) go to 160
               do 150 j=1,ncc
  150          call g2(cs,sn,c(i-1,j),c(i,j))
  160       continue
         e(l)=zero
         e(k)=f
         q(k)=x
         nqrs=nqrs+1
         if(nqrs.le.n10) go to 20
         fail=.true.
  170    if(z.ge.zero) go to 190
         q(k)=-z
         if(.not.wntv) go to 190
            do 180 j=1,nrv
  180       v(j,k)=-v(j,k)
  190    continue
  200    continue
      if(n.eq.1) return
         do 210 i=2,n
         if(q(i).gt.q(i-1)) go to 220
  210    continue
      if(fail) ipass=2
      return
  220    do 270 i=2,n
         t=q(i-1)
         k=i-1
            do 230 j=i,n
            if(t.ge.q(j)) go to 230
            t=q(j)
            k=j
  230       continue
         if(k.eq.i-1) go to 270
         q(k)=q(i-1)
         q(i-1)=t
         if(.not.havers) go to 250
            do 240 j=1,ncc
            t=c(i-1,j)
            c(i-1,j)=c(k,j)
  240       c(k,j)=t
  250    if(.not.wntv) go to 270
            do 260 j=1,nrv
            t=v(j,i-1)
            v(j,i-1)=v(j,k)
  260       v(j,k)=t
  270    continue
      if(fail) ipass=2
      return
      end
