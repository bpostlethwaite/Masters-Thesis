      real alfm(50),betm(50),qpm(50),qsm(50),rhom(50),thikm(50),
     *     ta(50),tb(50)
      complex u0(4096),w0(4096),u1(4096),w1(4096),tn(4096)
      common /cmparr/u0,w0,u1,w1,tn
      common /innout/ inunit,ounit
      complex dvp,dvs,drp,drs,dts,p,fr
      real*8 wq,t1,t2,qa,qb,qabm,vabm
      character*32 ofil,ofilz,ofilr,ofilt
      character*32 modela,title
      character*6  comp(3)
      character*1 complt,modcnv
      integer*2 rvb, cnv
      integer inunit,ounit,ipors
      integer blank
      real dum1(100), dum2(100)
      include 'kennet.inc'
      data comp/'_sp.z ','_sp.r ','_sp.t '/
c
      call inihdr
      call newhdr
c
      inunit=5
      ounit=6
      twopi = 8.*atan(1.)

      ofil = '                                '
      ofilr = '                                '
      ofilz = '                                '
      ofilt = '                                '

c
      write(ounit,*) 'Velocity Model Name'
      read(inunit,'(a)') modela
      
      iblank=blank(modela)
      ofil(1:iblank) = modela(1:iblank)

      call rdlyrs(modela,nlyrs,title,alfm,betm,rhom,thikm,
     *            dum1,dum2,dum1,dum2,-1,ier)
      do 1 i=1,nlyrs
*      qpm(i) = 500.
*      qsm(i) = 225.
       qpm(i) = 125
       qsm(i) = 62.5
       ta(i) = .16
       tb(i) = .26
 1    continue

c
c     terminal input
c
      write(ounit,*) 'incident P(1) or S(2) wave'
      read(inunit,*) ipors
      write(6,*) 'sampling interval'
      read(5,*) dt
      write(6,*) 'signal duration'
      read(5,*) t
c     write(6,*) 'incident delay'
c     read(5,*) tdelay
c     write(6,*) 'output file base name'
c     read(5,'(a)') ofil
      write(6,*) ' enter slowness: '
      read(5,*) pr
      write(6,*) ' partial(p) or full(f) : '
      read(5,'(a1)') complt
      write(6,*) ' mode conversions? (y or n) '
      read(5,'(a1)') modcnv
c
c     build output filenames
c
      ofilz(1:iblank+6)=ofil(1:iblank)//comp(1)
      ofilr(1:iblank+6)=ofil(1:iblank)//comp(2)
      ofilt(1:iblank+6)=ofil(1:iblank)//comp(3)
c
c     set up the spectral parameters
c
      numpts=ifix(t/dt+1.5)
      nft=npowr2(numpts)
      nfpts=nft/2+1
      fny=1./(2.*dt)
      delf=2.*fny/float(nft)
      t=dt*nft
c
c     set up some computational parameters
c          specifying the type of response
c          requested.
c
      p = cmplx(pr,0.)
      if ( complt(1:1) .eq. 'f' )  then
         rvb = allrvb
       else
         rvb = norvb
       endif
      if ( modcnv(1:1) .eq. 'n' ) then
       cnv = prmphs
       else
       cnv = allphs
      endif
c
c
c
c     compute q, alfa, and beta at 1 hz for absorbtion band
c
      t1 = 1.0d04
      wq = twopi
      do 5 i = 1, nlyrs
         qa = qpm(i)
         qb = qsm(i)
         t2 = ta(i)
         alfa(i) = alfm(i) * vabm(wq,t1,t2,qa)
         t2 = tb(i)
         beta(i) = betm(i) * vabm(wq,t1,t2,qb)
         qa = qabm(wq,t1,t2,qa)
         qb = qabm(wq,t1,t2,qb)
         alfa(i) = alfa(i)*( 1. + (0.,0.5)/qa)
         beta(i) = beta(i)*( 1. + (0.,0.5)/qb)
         cnvrsn(i) = cnv
         reverb(i) = rvb
         rho(i) = rhom(i)
 5       thik(i) = thikm(i)
      cnvrsn(0) = cnv
      if ( complt(1:1) .ne. 'f' )  then
         reverb(1) = onervb
       endif
c
      fr = cmplx(1.,0.)
      call ifmat(1,p,fr,nlyrs)
c
      do 10 i = 1, nfpts-1
         fr = cmplx(delf * ( i - 1 ), 0. )
         wq = twopi * fr
         do 6 j = 1, nlyrs
            qa = qpm(j)
            qb = qsm(j)
            t2 = ta(j)
            alfa(j) = alfm(j) * vabm(wq,t1,t2,qa)
            t2 = tb(j)
            beta(j) = betm(j) * vabm(wq,t1,t2,qb)
            qa = qabm(wq,t1,t2,qa)
            qb = qabm(wq,t1,t2,qb)
            alfa(j) = alfa(j)*( 1. + (0.,0.5)/qa)
            beta(j) = beta(j)*( 1. + (0.,0.5)/qb)
 6       continue
         call rcvrfn(p,fr,nlyrs,dvp,dvs,drp,drs,dts)
         u0(i) = dvp * (0.,-1.)*(-1.,0.)
         w0(i) = drp
         u1(i) = dvs
         w1(i) = drs * (0.,1.)
         tn(i) = dts
10    continue
      u0(nfpts) = (0.,0.)
      w0(nfpts) = (0.,0.)
      u1(nfpts) = (0.,0.)
      w0(nfpts) = (0.,0.)
      tn(nfpts) = (0.,0.)
c
c     output the responses
c
      if(ipors.eq.1)then
         call dfftr(u0,nft,'inverse',delf)
         call dfftr(w0,nft,'inverse',delf)
         call wsac1(ofilz,u0,numpts,0.,dt,nerr)
 	 call wsac1(ofilr,w0,numpts,0.,dt,nerr)
      else
         call dfftr(u1,nft,'inverse',delf)
         call dfftr(w1,nft,'inverse',delf)
         call dfftr(tn,nft,'inverse',delf)
         call wsac1(ofilz,u1,numpts,0.,dt,nerr)
         call wsac1(ofilr,w1,numpts,0.,dt,nerr)
         call wsac1(ofilt,tn,numpts,0.,dt,nerr)
      endif
c    
      stop
      end
      integer function blank(file)
      character file*32
      do 1 i=1,32
      if(file(i:i).ne.' ') goto 1
      blank=i-1
      return
1     continue
      write(1,100) file
100   format(' no blanks found in ',a32)
      blank = 0
      return
      end
