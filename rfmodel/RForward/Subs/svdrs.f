      subroutine svdrs(a,mda,mm,nn,b,mdb,nb,s)
c
c
c    lawson and Hanson singular value decomposition routine
c
c	s occupies 3*n cells
c	a occupies m*n cells
c	b occupies m*nb cells
c
c	
      dimension a(mda,nn),b(mdb,nb),s(nn,3)
      integer ounit
      common /innout/ inunit,ounit
      zero=0.
      one=1.
      n=nn
      if(n.le.0.or.mm.le.0) return
      j=n
   10 continue
         do 20 i=1,mm
         if(a(i,j)) 50,20,50
   20    continue
      if(j.eq.n) go to 40
         do 30 i=1,mm
   30    a(i,j)=a(i,n)
   40 continue
      a(1,n)=j
      n=n-1
   50 continue
      j=j-1
      if(j.ge.1) go to 10
      ns=0
      if(n.eq.0) go to 240
      i=1
      m=mm
   60 if(i.gt.n.or.i.ge.m) go to 150
      if(a(i,i)) 90,70,90
   70    do 80 j=1,n
         if(a(i,j)) 90,80,90
   80    continue
      go to 100
   90 i=i+1
      go to 60
  100 if(nb.le.0) go to 115
         do 110 j=1,nb
         t=b(i,j)
         b(i,j)=b(m,j)
  110    b(m,j)=t
  115    do 120 j=1,n
  120    a(i,j)=a(m,j)
      if(m.gt.n) go to 140
         do 130 j=1,n
  130    a(m,j)=zero
  140 continue
      m=m-1
      go to 60
  150 continue
c
c   end .. special for zero rows and columns
c   begin .. svd alogritm
c
      l=min0(m,n)
         do 170 j=1,l
         if(j.ge.m) go to 160
         call h12(1,j,j+1,m,a(1,j),1,t,a(1,j+1),1,mda,n-j)
         call h12(2,j,j+1,m,a(1,j),1,t,b,1,mdb,nb)
  160    if(j.ge.n-1) go to 170
         call h12(1,j+1,j+2,n,a(j,1),mda,s(j,3),a(j+1,1),mda,1,m-j)
  170    continue
      if(n.eq.1) go to 190
         do 180 j=2,n
         s(j,1)=a(j,j)
  180    s(j,2)=a(j-1,j)
  190 s(1,1)=a(1,1)
      ns=n
      if(m.ge.n) go to 200
      ns=m+1
      s(ns,1)=zero
      s(ns,2)=a(m,m+1)
  200 continue
         do 230 k=1,n
         i=n+1-k
         if(i.ge.n-1) go to 210
         call h12(2,i+1,i+2,n,a(i,1),mda,s(i,3),a(1,i+1),1,mda,n-i)
  210       do 220 j=1,n
  220       a(i,j)=zero
  230    a(i,i)=one
      call qrbd(ipass,s(1,1),s(1,2),ns,a,mda,n,b,mdb,nb)
      go to (240,310), ipass
  240 continue
      if(ns.ge.n) go to 260
      nsp1=ns+1
         do 250 j=nsp1,n
  250     s(j,1)=zero
  260 continue
      if(n.eq.nn) return
      np1=n+1
         do 280 j=np1,nn
         s(j,1)=a(1,j)
            do 270 i=1,n
  270       a(i,j)=zero
  280    continue
         do 300 k=np1,nn
         i=s(k,1)
         s(k,1)=zero
            do 290 j=1,nn
            a(k,j)=a(i,j)
  290       a(i,j)=zero
         a(i,k)=one
  300    continue
      return
  310 write(ounit,320)
      stop
  320 format(49h convergence failure in qr bidiagonal svd routine)
      end
