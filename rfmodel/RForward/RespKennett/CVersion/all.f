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
      subroutine rcvrfn(p,f,nlyrs,dvp,dvs,drp,drs,dts)
      integer nlyrs
      complex p,f
      complex dvp,dvs,drp,drs,dts
c
c        compute receiver function - free surface displacement from a
c        plane wave incident from below, on a stack of plane, parallel,
c        homogeneous layers
c        for a p, sv or sh wave incident
c        interface 0 is top of layer 1, a free surface,
c        layer n is half space
c        given frequency and phase slowness.
c
c          arguments...
c        psvsh = 1,2,3 for an incident p, sv or sh wave.
c
c        f,p - prescribed freq (hz) & horizontal phase slowness (c is
c            not restricted to be greater than alfa or beta)
c            both may be complex
c
c        passed in common /model/
c        alfa,beta,qp,qs,rho and thik contain the medium properties for
c
c        nlyrs - total number of layers, layer nlyrs is
c            the half space
c
c
c
c        commons and declarations
c
c
      include 'kennet.inc'
c
c        complex declarations
c
      complex i,zero,one,w
      complex t11,t12,t21,t22,l11,l12,l21,l22,tsh,lsh
      complex*16 det
      complex x11,x12,x21,x22,y11,y12,y21,y22,xsh,ysh
      complex tnupp,tnups,tnusp,tnuss,tnush
      complex rndpp,rndps,rndsp,rndss,rndsh
      complex phtp,phts,phtpp,phtps,phtss
      real twopi
      integer lyr,nif,cnvnif
      external cphs
      complex cphs
      data twopi/6.2831853/,i,zero/(0.,1.),(0.,0.)/,one/(1.,0.)/
c
c
      w = twopi*f
c
c     handle the special case of a half space
c
      if ( nlyrs .eq. 1 ) then
         dvp = dvpfs
         dvs = dvsfs
         drp = drpfs
         drs = drsfs
         dts = dtshfs
         return
       endif
c
c        initialize tup and rdown matricies for the stack with
c        bottom interface matricies
c
      nif = nlyrs-1
      cnvnif = cnvrsn(nif)
      if ( cnvnif .eq. allphs ) then
         tnupp = tupp(nif)
         tnuss = tuss(nif)
         tnups = tups(nif)
         tnusp = tusp(nif)
         tnush = tush(nif)
         rndpp = rdpp(nif)
         rndss = rdss(nif)
         rndps = rdps(nif)
         rndsp = rdsp(nif)
         rndsh = rdsh(nif)
       else if ( cnvnif .eq. prmphs ) then
         tnupp = tupp(nif)
         tnuss = tuss(nif)
         tnups = zero
         tnusp = zero
         tnush = tush(nif)
         rndpp = rdpp(nif)
         rndss = rdss(nif)
         rndps = zero
         rndsp = zero
         rndsh = rdsh(nif)
       else if ( cnvnif .eq. cnvphs ) then
         tnups = tups(nif)
         tnusp = tusp(nif)
         tnupp = zero
         tnuss = zero
         tnush = tush(nif)
         rndps = rdps(nif)
         rndsp = rdsp(nif)
         rndpp = zero
         rndss = zero
         rndsh = rdsh(nif)
       endif
c
c        now do the  bottom up recursion for tup and rdown
c
      do 10 lyr = nlyrs-1, 2, -1
         nif = lyr - 1
c
c        use the two way phase delay through the layer
c        to/from the next interface
c
         phtp = cphs( -i*w*xi(lyr)*thik(lyr) )
         phts = cphs( -i*w*eta(lyr)*thik(lyr) )
         phtpp = phtp * phtp
         phtps = phtp * phts
         phtss = phts * phts
         rndpp = rndpp * phtpp
         rndss = rndss * phtss
         rndps = rndps * phtps
         rndsp = rndsp * phtps
         rndsh = rndsh * phtss
         tnupp = tnupp * phtp
         tnuss = tnuss * phts
         tnups = tnups * phtp
         tnusp = tnusp * phts
         tnush = tnush * phts
	 stnupp(lyr) = tnupp
	 stnups(lyr) = tnups
	 stnusp(lyr) = tnusp
	 stnuss(lyr) = tnuss
	 stnush(lyr) = tnush
	 srndpp(lyr) = rndpp
	 srndps(lyr) = rndps
	 srndsp(lyr) = rndsp
	 srndss(lyr) = rndss
	 srndsh(lyr) = rndsh
c
c        form the reverberation operator for the layer
c
         cnvnif = cnvrsn(nif)
         if ( cnvnif .eq. allphs ) then
            t11 = rupp(nif)
            t22 = russ(nif)
            t12 = rups(nif)
            t21 = rusp(nif)
            tsh = rush(nif)
          else if ( cnvnif .eq. prmphs ) then
            t11 = rupp(nif)
            t22 = russ(nif)
            t12 = zero
            t21 = zero
            tsh = rush(nif)
          else if ( cnvnif .eq. cnvphs ) then
            t12 = rups(nif)
            t21 = rusp(nif)
            t11 = zero
            t22 = zero
            tsh = rush(nif)
          endif
         if ( reverb(lyr) .eq. allrvb ) then
            l11 = one - (rndpp*t11 + rndps*t21)
            l22 = one - (rndsp*t12 + rndss*t22)
            l12 = - (rndpp*t12 + rndps*t22)
            l21 = - (rndsp*t11 + rndss*t21)
            det = ( l11*l22 - l12*l21 )
            l12 = -l12/det
            l21 = -l21/det
            t11 = l11/det
            l11 = l22/det
            l22 = t11
            lsh = one / ( one - rndsh*tsh )
         else if ( reverb(lyr) .eq. onervb ) then
            l11 = one + (rndpp*t11 + rndps*t21)
            l22 = one + (rndsp*t12 + rndss*t22)
            l12 =  (rndpp*t12 + rndps*t22)
            l21 =  (rndsp*t11 + rndss*t21)
            lsh = one + rndsh*tsh
         else if ( reverb(lyr) .eq. norvb ) then
            l11 = one
            l22 = one
            l12 = zero
            l21 = zero
            lsh = one
          endif
c
c        now finish the recursion, adding the next interface
c
         if ( cnvnif .eq. allphs ) then
            x11 = tupp(nif)
            x22 = tuss(nif)
            x12 = tups(nif)
            x21 = tusp(nif)
            xsh = tush(nif)
            y11 = rdpp(nif)
            y22 = rdss(nif)
            y12 = rdps(nif)
            y21 = rdsp(nif)
            ysh = rdsh(nif)
          else if ( cnvnif .eq. prmphs ) then
            x11 = tupp(nif)
            x22 = tuss(nif)
            x12 = zero
            x21 = zero
            xsh = tush(nif)
            y11 = rdpp(nif)
            y22 = rdss(nif)
            y12 = zero
            y21 = zero
            ysh = rdsh(nif)
          else if ( cnvnif .eq. cnvphs ) then
            x12 = tups(nif)
            x21 = tusp(nif)
            x11 = zero
            x22 = zero
            xsh = tush(nif)
            y12 = rdps(nif)
            y21 = rdsp(nif)
            y11 = zero
            y22 = zero
            ysh = rdsh(nif)
          endif
c
         t11 = l11*tnupp + l12*tnusp
         t22 = l21*tnups + l22*tnuss
         t21 = l21*tnupp + l22*tnusp
         t12 = l11*tnups + l12*tnuss
         tsh = lsh * tnush
c
c        tnupp = tupp(nif)*t11 + tups(nif)*t21
c        tnuss = tusp(nif)*t12 + tuss(nif)*t22
c        tnups = tupp(nif)*t12 + tups(nif)*t22
c        tnusp = tusp(nif)*t11 + tuss(nif)*t21
         tnupp = x11*t11 + x12*t21
         tnuss = x21*t12 + x22*t22
         tnups = x11*t12 + x12*t22
         tnusp = x21*t11 + x22*t21
         tnush = xsh * tsh
c
c        t11 = l11*tdpp(nif) + l21*tdsp(nif)
c        t12 = l11*tdps(nif) + l21*tdss(nif)
c        t21 = l12*tdpp(nif) + l22*tdsp(nif)
c        t22 = l12*tdps(nif) + l22*tdss(nif)
         t11 = l11*x11 + l21*x12
         t12 = l11*x21 + l21*x22
         t21 = l12*x11 + l22*x12
         t22 = l12*x21 + l22*x22
         tsh = lsh * xsh
         l11 = rndpp*t11 + rndps*t21
         l12 = rndpp*t12 + rndps*t22
         l21 = rndsp*t11 + rndss*t21
         l22 = rndsp*t12 + rndss*t22
         lsh = rndsh * tsh
c        rndpp = rdpp(nif) + tupp(nif)*l11 + tups(nif)*l21
c        rndss = rdss(nif) + tusp(nif)*l12 + tuss(nif)*l22
c        rndps = rdps(nif) + tupp(nif)*l12 + tups(nif)*l22
c        rndsp = rdsp(nif) + tusp(nif)*l11 + tuss(nif)*l21
         rndpp = y11 + x11*l11 + x12*l21
         rndss = y22 + x21*l12 + x22*l22
         rndps = y12 + x11*l12 + x12*l22
         rndsp = y21 + x21*l11 + x22*l21
         rndsh = ysh + xsh*lsh
c
10    continue
c
c        use the two way phase delay through the top layer
c
         phtp = cphs( -i*w*xi(lyr)*thik(lyr) )
         phts = cphs( -i*w*eta(lyr)*thik(lyr) )
         phtpp = phtp * phtp
         phtps = phtp * phts
         phtss = phts * phts
         tnupp = tnupp * phtp
         tnuss = tnuss * phts
         tnups = tnups * phtp
         tnusp = tnusp * phts
         tnush = tnush * phts
         rndpp = rndpp * phtpp
         rndss = rndss * phtss
         rndps = rndps * phtps
         rndsp = rndsp * phtps
         rndsh = rndsh * phtss
c
c        form the reverberation operator for the top layer
c
         cnvnif = cnvrsn(0)
         if ( cnvnif .eq. allphs ) then
            t11 = ruppfs
            t22 = russfs
            t12 = rupsfs
            t21 = ruspfs
            tsh = rushfs
          else if ( cnvnif .eq. prmphs ) then
            t11 = ruppfs
            t22 = russfs
            t12 = zero
            t21 = zero
            tsh = rushfs
          else if ( cnvnif .eq. cnvphs ) then
            t12 = rupsfs
            t21 = ruspfs
            t11 = zero
            t22 = zero
            tsh = rushfs
          endif
         if ( reverb(lyr) .eq. allrvb ) then
            l11 = one - (rndpp*t11 + rndps*t21)
            l22 = one - (rndsp*t12 + rndss*t22)
            l12 = - (rndpp*t12 + rndps*t22)
            l21 = - (rndsp*t11 + rndss*t21)
            det = ( l11*l22 - l12*l21 )
            l12 = -l12/det
            l21 = -l21/det
            t11 = l11/det
            l11 = l22/det
            l22 = t11
            lsh = one / ( one - rndsh*tsh )
         else if ( reverb(lyr) .eq. onervb ) then
            l11 = one + (rndpp*t11 + rndps*t21)
            l22 = one + (rndsp*t12 + rndss*t22)
            l12 =  (rndpp*t12 + rndps*t22)
            l21 =  (rndsp*t11 + rndss*t21)
            lsh = one + rndsh*tsh
         else if ( reverb(lyr) .eq. norvb ) then
            l11 = one
            l22 = one
            l12 = zero
            l21 = zero
            lsh = one
          endif
c
c        now add the free surface displacement
c
         t11 = l11*tnupp + l12*tnusp
         t22 = l21*tnups + l22*tnuss
         t21 = l21*tnupp + l22*tnusp
         t12 = l11*tnups + l12*tnuss
         tsh = lsh*tnush
         dvp = dvpfs*t11 + dvsfs*t21
         dvs = dvpfs*t12 + dvsfs*t22
         drp = drpfs*t11 + drsfs*t21
         drs = drpfs*t12 + drsfs*t22
         dts = dtshfs*tsh
c
c
c
      return
      end
      complex function vslow(v,p,f)
      intrinsic csqrt,aimag,real,sqrt,abs
      complex v,p,f
      real t,eps
      parameter (eps = 0.001)
         vslow = csqrt( (1.,0.)/(v*v) - p*p )
         t = abs(real(vslow)) + abs(aimag(vslow))
         if ( t .lt. eps ) vslow = csqrt(eps*(-2.,-2.)/v)
         if ( aimag( f*vslow ) .gt. 0. ) vslow = -vslow
         return
      end
      complex function cphs( arg )
         complex arg
         intrinsic real, cexp
         real rmin
      parameter ( rmin = -20. )
         if ( real(arg) .lt. rmin ) then
            cphs = (0.,0.)
          else
            cphs = cexp(arg)
          endif
         return
      end
      subroutine ifmat(psvsh,p,f,nlyrs)
      integer psvsh,nlyrs
      complex p,f
c
c           compute kennett's interface matricies for n layer model
c        for a p, sv or sh wave incident
c        interface 0 is top of layer 1, a free surface, compute
c        reflection operator, and free surface displacement operator
c        layer n is half space
c        compute ru, rd, tu, td at interfaces
c        given frequency and phase slowness.
c
c          arguments...
c        psvsh = 1,2,3 for an incident p, sv or sh wave.
c
c        f,p - prescribed freq (hz) & horizontal phase slowness (c is
c            not restricted to be greater than alfa or beta)
c            both may be complex
c
c        passed in common /model/
c        alfa,beta,qp,qs,rho and thik contain the medium properties for
c            layers 1 thru nlyrs (the halfspace)
c
c        nlyrs - total number of layers, layer nlyrs is
c            the half space
c
c
      logical psvwav,shwave,test
c
c        commons and declarations
c
c
      include  'kennet.inc'
c
c        complex declarations
c
      complex mum11,mum12,mum21,mum22,mup11,mup12,mup21,mup22
      complex mdm11,mdm12,mdm21,mdm22,mdp11,mdp12,mdp21,mdp22
      complex num11,num12,num21,num22,nup11,nup12,nup21,nup22
      complex ndm11,ndm12,ndm21,ndm22,ndp11,ndp12,ndp21,ndp22
      complex xip,xim,etap,etam,epap,epam,epbp,epbm,mum,mup
      complex alfam,alfap,betam,betap,rhom,rhop
c
      complex i,zero,one,two,quartr,w
      complex t1,t2,zshp,zshm
      complex t11,t12,t21,t22,det,l11,l12,l21,l22
      real twopi,eps
      integer lyr
      intrinsic csqrt
      complex vslow
      external vslow
      data twopi,eps/6.2831853,.001/,i,zero/(0.,1.),(0.,0.)/,
     & one,two/(1.,0.),(2.,0.)/,quartr/(0.25,0.)/
c
c
      w = twopi*f
c     if(f .eq. (0.,0.)) w = (1.0e-6,0.)
      shwave = psvsh .eq. 3
      psvwav = psvsh .le. 2
c
c
c
      alfam = alfa(1)
      betam = beta(1)
      rhom = rho(1)
      mum = betam*betam * rhom
      xim = vslow(alfam,p,f)
      etam = vslow(betam,p,f)
      xi(1) = xim
      eta(1) =  etam
      epam = one / csqrt( two*rhom*xim )
      epbm = one / csqrt( two*rhom*etam )
      t1 = two * mum * p
      t2 = t1 * p - rhom
c
c        form layer 1 matricies for free surface and interface 1
c
      mdm11 = i * xim * epam
      mum11 = - mdm11
      mdm12 = p * epbm
      mum12 = mdm12
      mdm21 = p * epam
      mum21 = mdm21
      mdm22 = i * etam * epbm
      mum22 = - mdm22
      ndm11 = t2 * epam
      num11 = ndm11
      ndm12 = t1 * mdm22
      num12 = -ndm12
      ndm21 = t1 * mdm11
      num21 = -ndm21
      ndm22 = t2 * epbm
      num22 = ndm22
      zshm = mum * etam
c
c        calculate the free surface reflection matrix, and free surface
c        free surface displacement operator.
c
      det = ndm11*ndm22 - ndm12*ndm21
      det = one/det
      t11 = -ndm22*det
      t22 = -ndm11*det
      t12 = ndm12*det
      t21 = ndm21*det
      ruppfs = t11*num11 + t12*num21
      rupsfs = t11*num12 + t12*num22
      ruspfs = t21*num11 + t22*num21
      russfs = t21*num12 + t22*num22
      rushfs = one
      dvpfs = mum11 + mdm11*ruppfs + mdm12*ruspfs
      drpfs = mum21 + mdm21*ruppfs + mdm22*ruspfs
      dvsfs = mum12 + mdm11*rupsfs + mdm12*russfs
      drsfs = mum22 + mdm21*rupsfs + mdm22*russfs
      dtshfs = two
c
c        now do the interfaces, and save below matrices into above matricies
c        before starting next interface
c
c
      do 10 lyr = 1, nlyrs-1
c
         alfap = alfa(lyr+1)
         betap = beta(lyr+1)
         rhop = rho(lyr+1)
         mup = betap*betap * rhop
         xip = vslow(alfap,p,f)
         etap = vslow(betap,p,f)
         xi(lyr+1) = xip
         eta(lyr+1) =  etap
         epap = one / csqrt( two*rhop*xip )
         epbp = one / csqrt( two*rhop*etap )
         t1 = two * mup * p
         t2 = t1 * p - rhop
c
         mdp11 = i * xip * epap
         mup11 = - mdp11
         mdp12 = p * epbp
         mup12 = mdp12
         mdp21 = p * epap
         mup21 = mdp21
         mdp22 = i * etap * epbp
         mup22 = - mdp22
         ndp11 = t2*epap
         nup11 = ndp11
         ndp12 = t1 * mdp22
         nup12 = -ndp12
         ndp21 = t1 * mdp11
         nup21 = -ndp21
         ndp22 = t2*epbp
         nup22 = ndp22
         zshp = mup * etap
c
         t11 = mum11*ndp11 + mum21*ndp21 - num11*mdp11 - num21*mdp21
         t21 = mum12*ndp11 + mum22*ndp21 - num12*mdp11 - num22*mdp21
         t12 = mum11*ndp12 + mum21*ndp22 - num11*mdp12 - num21*mdp22
         t22 = mum12*ndp12 + mum22*ndp22 - num12*mdp12 - num22*mdp22
         det = t11*t22 - t12*t21
	 det = one/det
         l12 = -t12*det
         l21 = -t21*det
         l22 = t11*det
         l11 = t22*det
c
c
         tdpp(lyr) = i*l11
         tdps(lyr) = i*l12
         tdsp(lyr) = i*l21
         tdss(lyr) = i*l22
         tupp(lyr) = i*l11
         tups(lyr) = i*l21
         tusp(lyr) = i*l12
         tuss(lyr) = i*l22
         tush(lyr) = two*csqrt(zshp*zshm)/(zshp+zshm)
         tdsh(lyr) = tush(lyr)
c
         t11 = mdm11*ndp11 + mdm21*ndp21 - ndm11*mdp11 - ndm21*mdp21
         t21 = mdm12*ndp11 + mdm22*ndp21 - ndm12*mdp11 - ndm22*mdp21
         t12 = mdm11*ndp12 + mdm21*ndp22 - ndm11*mdp12 - ndm21*mdp22
         t22 = mdm12*ndp12 + mdm22*ndp22 - ndm12*mdp12 - ndm22*mdp22
         rdpp(lyr) = - t11*l11 - t12*l21
         rdps(lyr) = - t11*l12 - t12*l22
         rdsp(lyr) = - t21*l11 - t22*l21
         rdss(lyr) = - t21*l12 - t22*l22
         rdsh(lyr) = (zshm - zshp)/(zshm + zshp)
c
         t11 = mum11*nup11 + mum21*nup21 - num11*mup11 - num21*mup21
         t21 = mum12*nup11 + mum22*nup21 - num12*mup11 - num22*mup21
         t12 = mum11*nup12 + mum21*nup22 - num11*mup12 - num21*mup22
         t22 = mum12*nup12 + mum22*nup22 - num12*mup12 - num22*mup22
         rupp(lyr) = - l11*t11 - l12*t21
         rups(lyr) = - l11*t12 - l12*t22
         rusp(lyr) = - l21*t11 - l22*t21
         russ(lyr) = - l21*t12 - l22*t22
         rush(lyr) = - rdsh(lyr)
c
c	 copy the above values to storage for  inversion
c        copy the below values to above values for next interface
c
	 mu(lyr) = mum
	 epa(lyr) = epam
	 epb(lyr) = epbm
         nu11(lyr) = num11
         nu12(lyr) = num12
         nu21(lyr) = num21
         nu22(lyr) = num22
         nd11(lyr) = ndm11
         nd12(lyr) = ndm12
         nd21(lyr) = ndm21
         nd22(lyr) = ndm22
         mu11(lyr) = mum11
         mu12(lyr) = mum12
         mu21(lyr) = mum21
         mu22(lyr) = mum22
         md11(lyr) = mdm11
         md12(lyr) = mdm12
         md21(lyr) = mdm21
         md22(lyr) = mdm22
	 zsh(lyr) = zshm
         alfam = alfap
         betam = betap
         rhom = rhop
         mum = mup
         xim = xip
         etam = etap
         epam = epap
         epbm = epbp
         num11 = nup11
         num12 = nup12
         num21 = nup21
         num22 = nup22
         ndm11 = ndp11
         ndm12 = ndp12
         ndm21 = ndp21
         ndm22 = ndp22
         mum11 = mup11
         mum12 = mup12
         mum21 = mup21
         mum22 = mup22
         mdm11 = mdp11
         mdm12 = mdp12
         mdm21 = mdp21
         mdm22 = mdp22
	 zshm = zshp
c
c     copy the n and m matrices if this is source layer
c
         if ( lyr .eq. srclyr ) then
            nus11 = num11
            nus12 = num12
            nus21 = num21
            nus22 = num22
            nussh = -i*rhom*betam*etam*epbm
            nds11 = ndm11
            nds12 = ndm12
            nds21 = ndm21
            nds22 = ndm22
            ndssh = -nussh
            mus11 = mum11
            mus12 = mum12
            mus21 = mum21
            mus22 = mum22
            mussh = epbm/betam
            mds11 = mdm11
            mds12 = mdm12
            mds21 = mdm21
            mds22 = mdm22
            mdssh = mussh
            rhos = rhom
            alfas = alfam
            betas = betam
          endif
10    continue
c
c	copy the layer matrices for halfspace to inversion storage
c
	 mu(nlyrs) = mup
	 epa(nlyrs) = epam
	 epb(nlyrs) = epbm
         nu11(nlyrs) = nup11
         nu12(nlyrs) = nup12
         nu21(nlyrs) = nup21
         nu22(nlyrs) = nup22
         nd11(nlyrs) = ndp11
         nd12(nlyrs) = ndp12
         nd21(nlyrs) = ndp21
         nd22(nlyrs) = ndp22
         mu11(nlyrs) = mup11
         mu12(nlyrs) = mup12
         mu21(nlyrs) = mup21
         mu22(nlyrs) = mup22
         md11(nlyrs) = mdp11
         md12(nlyrs) = mdp12
         md21(nlyrs) = mdp21
         md22(nlyrs) = mdp22
	 zsh(nlyrs) = zshp
c
c
      return
      end
      function qabm(w,t1,t2,qm)
      real*8 qabm,qm,c,arg,w,t1,t2
      intrinsic datan
      arg=(w*(t1-t2))/(1.0+w*w*t1*t2)
c     c=2/(pi*qm)
      c=0.6366198/qm
      qabm=c*datan(arg)
      if(qabm.eq.0.d0) qabm=1.0d-5
      qabm=1.0/qabm
      return
      end
      function vabm(w,t1,t2,qm)
c     vabm calculates dispersion due to anelasticity
      real*8 vabm,qm,c,arg,arg1,w,w12,t1,t2,w2,t12,t22
      intrinsic dlog
c     c=2/(pi*qm)
      c=0.6366198/qm
      c=c/4.0
      w2=w*w
      t12=t1*t1
      t22=t2*t2
      arg=(1.0+w2*t12)/(1.0+w2*t22)
c     normalize to 1 hz (w12 = (2*pi*1)**2
      w12=39.478418
      arg1=(1.0+w12*t12)/(1.0+w12*t22)
      vabm=(1.0 + c*dlog(arg))/(1.0 + c*dlog(arg1))
      return
      end
