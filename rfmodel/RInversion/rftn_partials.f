      subroutine partials( a, p0,  perta, pertb, pertr, nlyrs,
     *                      nlmax, dt, ntmax,
     *                      delay, agauss, 
     *                      alfm, betm, rhom, thikm,
     *                      pon )
c
      integer f,l
      parameter(f=513, l=45 )
      complex a(ntmax/2,nlmax)
      real p0, perta(nlmax), pertb(nlmax), pertr(nlmax), delay, agauss
      integer nlyrs
      real alfm(l),betm(l),rhom(l),thikm(l)
      logical pon(l,6)
c
      real qpm(l),qsm(l),ta(l),tb(l)
c
      complex dvp,dvs,drp,drs,dts,p,fr,rn
      real*8 wq,t1,t2,qa,qb,qabm,vabm
      real*8 gnorm
      integer plyr
      include 'kennett.inc'
c
      p = cmplx( p0, 0. )
      twopi = 8.*atan(1.)
      do 1 i = 1, nlyrs
      qpm(i) = 450.
      qsm(i) = 200.
      ta(i) = .16
      tb(i) = .26
 1    continue
c
      if ( nlmax .gt. mxlr ) then
         write(6,*) 'too many layers specified'
         return
       endif
      nft = 512
      nfpts = 257
      if ( nft .gt. ntmax ) then
         write(6,*) 'a matrix ntmax is too small'
         return
       endif
c     fny = 2.5
c     dt = 1. / ( 2 * fny )
      fny = 1. / ( 2. * dt )
      t = dt * nft
      delf = 2. * fny / nft
c
c  correct delf for inverse transforms, dt cancelled in decon
c  so no delf in inverse transform, just 1/nft
c
      cdelf = 1. / float( nft )
      rvb = allrvb
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
         cnvrsn(i) = allphs
         reverb(i) = rvb
         rho(i) = rhom(i)
 5       thik(i) = thikm(i)
      cnvrsn(0) = allphs
c
      fr = cmplx(1.,0.)
      call ifmat(1,p,fr,nlyrs)
      call delifm(p,fr,nlyrs,perta,pertb,pertr)
c
      gnorm = 0.0d0
      do 10 i = 1, nfpts
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
         gauss = wq / ( 2. * agauss )
         gauss = exp( - gauss * gauss )
	 gnorm = gnorm + gauss
         call rcvrfn(p,fr,nlyrs,dvp,dvs,drp,drs,dts)
         a(i,nlmax) = gauss * drp / ( dvp * (0.,1.))
         call rcvrtd(p,fr,nlyrs,dvp,drp,dvs,drs,dts)
c
       do 1000 plyr = 1, nlyrs-1
	if ( pon(plyr,1) .or. pon(plyr,2) .or. pon(plyr,3) ) then
           call delrcv(p,fr,plyr,nlyrs,dvp,dvs,drp,drs,dts)
           a(i,plyr) = ( gauss*drp / ( dvp*(0.,1.))  - a(i,nlmax) ) /
     *                  ( betm(plyr) * ( pertb(plyr) - 1. ) )
	else
	   a(i,plyr) = (0.,0.)
        endif
 1000  continue
c
10    continue
c
c
      do 2000 plyr = 1, nlyrs-1
c     do 2000 plyr = 1, plp-1
      do 20 i = 1,nfpts
       shf = twopi * (1-i) * delf * delay
       if ( plyr .eq. 1 ) then
         a(i,nlmax) = a(i,nlmax) * cexp( cmplx(0., shf ) )
       endif
         a(i,plyr) = a(i,plyr)
     *                  * cexp( cmplx(0., shf) )
20    continue
      if ( plyr .eq. 1 ) then
      a(nfpts,nlmax) = (0.,0.)
      call dfftr(a(1,nlmax),nft,'inverse',cdelf)
      endif
      a(nfpts,plyr) = (0.,0.)
      call dfftr(a(1,plyr),nft,'inverse',cdelf)
c
2000  continue
c
      gnorm = gnorm / nfpts
      do 111 i = 1,nlmax
      do 111 j = 1,nft/2
       a(j,i) = a(j,i) / gnorm
 111  continue
c
      return
      end
      subroutine spartials( a, p0,  perta, pertb, pertr, nlyrs,
     *                      nlmax, dt, ntmax,
     *                      delay, agauss, duratn,
     *                      alfm, betm, rhom, thikm, pon )
c
      real a(ntmax,nlmax)
      real p0, perta(nlmax), pertb(nlmax), pertr(nlmax)
      real delay, agauss, dt, duratn
      integer nlyrs, ntmax, nlmax, nft, lyroff
      real alfm(*),betm(*),rhom(*),thikm(*)
      logical pon(nlmax,6)
      real vmax, vpmax(50)
c
      nft = 512
      t = nft * dt
      iduratn = duratn / dt
      call sfpartials( a, p0,  perta, pertb, pertr, nlyrs,
     *                      nlmax, dt, ntmax, delay, agauss,
     *                      alfm, betm, rhom, thikm, pon )
c
      vmax = 0.
      do 110 j = 1,iduratn
	 vmax = amax1( vmax, a(j,nlmax) )
 110  continue
c
      do 111 i = 1,nlyrs-1
       if ( pon(i,1) .or. pon(i,2) .or. pon(i,3) ) then
          vpmax(i) = 0.
          do 1111 j = 1,iduratn
	     vpmax(i) = amax1( vpmax(i), a(j,i) )
 1111     continue
       endif
 111  continue
c
      do 112, i = 1,nlyrs-1
         if ( pon(i,1) .or. pon(i,2) .or. pon(i,3) ) then
              do 1122, j = 1, iduratn
                 if ( i .eq. 1 ) a(j,nlmax) = a(j,nlmax) / vmax
                 a(j,i) = ( ( a(j,i) / vpmax(i) )
     *                -a(j,nlmax) ) / ( alfm(i)*(perta(i)-1.))
 1122         continue
         endif
 112  continue
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
      subroutine delifm(p,f,nlyrs,perta,pertb,pertr)
      integer nlyrs
      complex p,f
      real perta(nlyrs),pertb(nlyrs),pertr(nlyrs)
c
c           compute kennett's interface matricies for layer perurbation
c        for a p, sv or sh wave incident, only for affected interfaces
c        for interface 0 at top of layer 1, a free surface, compute
c        reflection operator, and free surface displacement operator
c        layer n is half space
c        compute ru, rd, tu, td at interfaces
c        given frequency and phase slowness.
c
c          arguments...
c
c        f,p - prescribed freq (hz) & horizontal phase slowness (c is
c            not restricted to be greater than alfa or beta)
c            both may be complex
c
c        nlyrs - the number of  layers that are perturbed
c
c        perta - the perturbation of the compressional velocity
c
c        pertb - the perturbation of the shear velocity
c
c        pertr - the perturbation of the density
c
c
c        passed in common /model/
c        alfa,beta,qp,qs,rho and thik contain the medium properties for
c            layers 1 thru nlyrs (the halfspace)
c
c
c
c        commons and declarations
c
c
      include  'kennett.inc'
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
      complex i,one,two
      complex t1,t2,zshp,zshm
      complex t11,t12,t21,t22,det,l11,l12,l21,l22
      integer nif
      integer ipert,above,below
      parameter( above = 1, below = 2 )
      intrinsic csqrt
      complex vslow
      external vslow
      data i/(0.,1.)/,one,two/(1.,0.),(2.,0.)/
c
c
c	perturb first layer to setup for loop
c
      alfam = alfa(1) * perta(1)
      betam = beta(1) * pertb(1)
      rhom = rho(1) * pertr(1)
      mum = betam*betam * rhom
      xim = vslow(alfam,p,f)
      etam = vslow(betam,p,f)
      dxi(1) = xim
      deta(1) =  etam
      epam = one / csqrt( two*rhom*xim )
      epbm = one / csqrt( two*rhom*etam )
      t1 = two * mum * p
      t2 = t1 * p - rhom
c
c        form layer matricies for perturbation in layer 1
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
c	now setup, so fall into loop
c
      do 10 nif = 1, nlyrs-1
       do 20 ipert = above, below
c
c	compute perturbation layer above or below the interface
c	and get all layer matrices before going into the
c	computation of interface matrices
c
	if ( ipert .eq. above ) then
         nup11 = nu11(nif+1)
         nup12 = nu12(nif+1)
         nup21 = nu21(nif+1)
         nup22 = nu22(nif+1)
         ndp11 = nd11(nif+1)
         ndp12 = nd12(nif+1)
         ndp21 = nd21(nif+1)
         ndp22 = nd22(nif+1)
         mup11 = mu11(nif+1)
         mup12 = mu12(nif+1)
         mup21 = mu21(nif+1)
         mup22 = mu22(nif+1)
         mdp11 = md11(nif+1)
         mdp12 = md12(nif+1)
         mdp21 = md21(nif+1)
         mdp22 = md22(nif+1)
         zshp = zsh(nif+1)
        else if ( ipert .eq. below ) then
         alfap = alfa(nif+1) * perta(nif+1)
         betap = beta(nif+1) * pertb(nif+1)
         rhop = rho(nif+1) * pertr(nif+1)
         mup = betap*betap * rhop
         xip = vslow(alfap,p,f)
         etap = vslow(betap,p,f)
         dxi(nif+1) = xip
         deta(nif+1) =  etap
         epap = one / csqrt( two*rhop*xip )
         epbp = one / csqrt( two*rhop*etap )
         t1 = two * mup * p
         t2 = t1 * p - rhop
c
c        form layer matricies for perurbation below
c
         mdp11 = i * xip * epap
         mup11 = - mdp11
         mdp12 = p * epbp
         mup12 = mdp12
         mdp21 = p * epap
         mup21 = mdp21
         mdp22 = i * etap * epbp
         mup22 = - mdp22
         ndp11 = t2 * epap
         nup11 = ndp11
         ndp12 = t1 * mdp22
         nup12 = -ndp12
         ndp21 = t1 * mdp11
         nup21 = -ndp21
         ndp22 = t2 * epbp
         nup22 = ndp22
         zshp = mup * etap
c
c	retrieve the saved (unperturbed) matrices for layer
c	above the interface, perturbation is below
c
         num11 = nu11(nif)
         num12 = nu12(nif)
         num21 = nu21(nif)
         num22 = nu22(nif)
         ndm11 = nd11(nif)
         ndm12 = nd12(nif)
         ndm21 = nd21(nif)
         ndm22 = nd22(nif)
         mum11 = mu11(nif)
         mum12 = mu12(nif)
         mum21 = mu21(nif)
         mum22 = mu22(nif)
         mdm11 = md11(nif)
         mdm12 = md12(nif)
         mdm21 = md21(nif)
         mdm22 = md22(nif)
         zshm = zsh(nif)
	endif
c
c	now the perturbed layer matrices above interface
c	and unperturbed layer matrices below interface
c	are ready, begin interface loop with two sets of
c	interface matrices for each interface,
c	one set perturbed above the interface and
c	one set perturbed below the interface
c
c
        if ( ( nif .eq. 1 ) .and. ( ipert .eq. above ) ) then
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
         druppfs = t11*num11 + t12*num21
         drupsfs = t11*num12 + t12*num22
         druspfs = t21*num11 + t22*num21
         drussfs = t21*num12 + t22*num22
         drushfs = one
         ddvpfs = mum11 + mdm11*druppfs + mdm12*druspfs
         ddrpfs = mum21 + mdm21*druppfs + mdm22*druspfs
         ddvsfs = mum12 + mdm11*drupsfs + mdm12*drussfs
         ddrsfs = mum22 + mdm21*drupsfs + mdm22*drussfs
         ddtshfs = two
	endif
c
c	now do the interface matrices 
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
	 if ( ipert .eq. above ) then
            datdpp(nif) = i*l11
            datdps(nif) = i*l12
            datdsp(nif) = i*l21
            datdss(nif) = i*l22
            datupp(nif) = i*l11
            datups(nif) = i*l21
            datusp(nif) = i*l12
            datuss(nif) = i*l22
            datush(nif) = two*csqrt(zshp*zshm)/(zshp+zshm)
            datdsh(nif) = datush(nif)
	   else if ( ipert .eq. below ) then
            dbtdpp(nif) = i*l11
            dbtdps(nif) = i*l12
            dbtdsp(nif) = i*l21
            dbtdss(nif) = i*l22
            dbtupp(nif) = i*l11
            dbtups(nif) = i*l21
            dbtusp(nif) = i*l12
            dbtuss(nif) = i*l22
            dbtush(nif) = two*csqrt(zshp*zshm)/(zshp+zshm)
            dbtdsh(nif) = dbtush(nif)
	  endif
c
         t11 = mdm11*ndp11 + mdm21*ndp21 - ndm11*mdp11 - ndm21*mdp21
         t21 = mdm12*ndp11 + mdm22*ndp21 - ndm12*mdp11 - ndm22*mdp21
         t12 = mdm11*ndp12 + mdm21*ndp22 - ndm11*mdp12 - ndm21*mdp22
         t22 = mdm12*ndp12 + mdm22*ndp22 - ndm12*mdp12 - ndm22*mdp22
	 if ( ipert .eq. above ) then
            dardpp(nif) = - t11*l11 - t12*l21
            dardps(nif) = - t11*l12 - t12*l22
            dardsp(nif) = - t21*l11 - t22*l21
            dardss(nif) = - t21*l12 - t22*l22
            dardsh(nif) = (zshm - zshp)/(zshm + zshp)
	   else if ( ipert .eq. below ) then
            dbrdpp(nif) = - t11*l11 - t12*l21
            dbrdps(nif) = - t11*l12 - t12*l22
            dbrdsp(nif) = - t21*l11 - t22*l21
            dbrdss(nif) = - t21*l12 - t22*l22
            dbrdsh(nif) = (zshm - zshp)/(zshm + zshp)
	  endif
c
         t11 = mum11*nup11 + mum21*nup21 - num11*mup11 - num21*mup21
         t21 = mum12*nup11 + mum22*nup21 - num12*mup11 - num22*mup21
         t12 = mum11*nup12 + mum21*nup22 - num11*mup12 - num21*mup22
         t22 = mum12*nup12 + mum22*nup22 - num12*mup12 - num22*mup22
	 if ( ipert .eq. above ) then
            darupp(nif) = - l11*t11 - l12*t21
            darups(nif) = - l11*t12 - l12*t22
            darusp(nif) = - l21*t11 - l22*t21
            daruss(nif) = - l21*t12 - l22*t22
            darush(nif) = - dardsh(nif)
	   else if ( ipert .eq. below ) then
            dbrupp(nif) = - l11*t11 - l12*t21
            dbrups(nif) = - l11*t12 - l12*t22
            dbrusp(nif) = - l21*t11 - l22*t21
            dbruss(nif) = - l21*t12 - l22*t22
            dbrush(nif) = - dbrdsh(nif)
	  endif
c
c	 copy the above values to storage for  inversion
c        copy the below values to above values for next interface
c
      if ( ipert .eq. below ) then
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
      endif
20    continue
10    continue
c
c
c
      return
      end
      subroutine delrcv(p,f,plyr,nlyrs,dvp,dvs,drp,drs,dts)
      integer plyr,nlyrs
      complex p,f
      complex dvp,dvs,drp,drs,dts
c
c        compute receiver function - free surface displacement from a
c        plane wave incident from below, on a stack of plane, parallel,
c        homogeneous layers using the perturbed interface matricies
c	 and the perturbed layer parameters
c        for a p, sv or sh wave incident
c        interface 0 is top of layer 1, a free surface,
c        layer n is half space
c        given frequency and phase slowness.
c
c          arguments...
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
c	 plyr - the perturbed layer
c
c
c        commons and declarations
c
c
      include 'kennett.inc'
c
c        complex declarations
c
      complex i,zero,one,two,w
      complex t11,t12,t21,t22,l11,l12,l21,l22,tsh,lsh
      complex*16 det
      complex x11,x12,x21,x22,y11,y12,y21,y22,xsh,ysh
      complex tnupp,tnups,tnusp,tnuss,tnush
      complex rndpp,rndps,rndsp,rndss,rndsh
      complex rnupp,rnups,rnusp,rnuss,rnush
      complex tdvp,tdvs,tdrp,tdrs,tdts
      complex phtp,phts,phtpp,phtps,phtss
      real twopi
      integer lyr,nif,cnvnif,bnif,tnif
      external cphs
      complex cphs
      data i,zero/(0.,1.),(0.,0.)/,one,two/(1.,0.),(2.,0.)/
      data twopi/6.2831853064/
c
c
c
c     handle the special case of a half space
c
      w = twopi * f
      if ( nlyrs .eq. 1 ) then
         dvp = ddvpfs
         dvs = ddvsfs
         drp = ddrpfs
         drs = ddrsfs
         dts = ddtshfs
         return
       endif
c
c	 special case for perturbed layer just above halfspace
c        initialize tup and rdown matricies for the stack with
c        bottom interface matricies
c        use difference of perturbation above interface matrices
c
      if ( plyr .eq. nlyrs-1 ) then
	nif = nlyrs-1
	cnvnif = cnvrsn(nif)
	if ( cnvnif .eq. allphs ) then
         tnupp = datupp(nif)
         tnuss = datuss(nif)
         tnups = datups(nif)
         tnusp = datusp(nif)
         tnush = datush(nif)
         rndpp = dardpp(nif)
         rndss = dardss(nif)
         rndps = dardps(nif)
         rndsp = dardsp(nif)
         rndsh = dardsh(nif)
	else if ( cnvnif .eq. prmphs ) then
         tnupp = datupp(nif)
         tnuss = datuss(nif)
         tnups = zero
         tnusp = zero
         tnush = datush(nif)
         rndpp = dardpp(nif)
         rndss = dardss(nif)
         rndps = zero
         rndsp = zero
         rndsh = dardsh(nif)
        else if ( cnvnif .eq. cnvphs ) then
         tnups = datups(nif)
         tnusp = datusp(nif)
         tnupp = zero
         tnuss = zero
         tnush = datush(nif)
         rndps = dardps(nif)
         rndsp = dardsp(nif)
         rndpp = zero
         rndss = zero
         rndsh = dardsh(nif)
        endif
	lyr = nlyrs - 1
        phtp = cphs( -i*w*dxi(lyr)*thik(lyr) )
        phts = cphs( -i*w*deta(lyr)*thik(lyr) )
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
c	now the special case of bottom layer has the right phase
c
c
c	normal case, perturbed layer, initialize Rd, Tu with
c	results stored by rcvrfn on its initial pass
c
       else
	 tnupp = stnupp(plyr+1)
	 tnups = stnups(plyr+1)
	 tnusp = stnusp(plyr+1)
	 tnuss = stnuss(plyr+1)
	 tnush = stnush(plyr+1)
	 rndpp = srndpp(plyr+1)
	 rndps = srndps(plyr+1)
	 rndsp = srndsp(plyr+1)
	 rndss = srndss(plyr+1)
	 rndsh = srndsh(plyr+1)
       endif
c
c	setup the interfaces to merge into the Rd and Tu
c	matrices
c
       if ( plyr .eq. nlyrs - 1 ) then
	 bnif = nlyrs - 2
	 tnif = bnif
	else if ( plyr .eq. 1 ) then
	 bnif = 1
	 tnif = 1
	else
	 bnif = plyr
	 tnif = plyr - 1
	endif
c
c	do the 'loop' for the calculation of Rd and Tu
c
       do 10 nif = bnif, tnif, -1
	 lyr = nif + 1
c
c        form the reverberation operator for the layer
c        first get the correct perturbed reflection coeffs
c
	 cnvnif = cnvrsn(nif)
	 if ( nif .lt. plyr ) then
c           perturbed layer is below interface
            if ( cnvnif .eq. allphs ) then
               t11 = dbrupp(nif)
               t22 = dbruss(nif)
               t12 = dbrups(nif)
               t21 = dbrusp(nif)
               tsh = dbrush(nif)
             else if ( cnvnif .eq. prmphs ) then
               t11 = dbrupp(nif)
               t22 = dbruss(nif)
               t12 = zero
               t21 = zero
               tsh = dbrush(nif)
             else if ( cnvnif .eq. cnvphs ) then
               t12 = dbrups(nif)
               t21 = dbrusp(nif)
               t11 = zero
               t22 = zero
               tsh = dbrush(nif)
             endif
	  else
c           perturbed layer is above interface
            if ( cnvnif .eq. allphs ) then
               t11 = darupp(nif)
               t22 = daruss(nif)
               t12 = darups(nif)
               t21 = darusp(nif)
               tsh = darush(nif)
             else if ( cnvnif .eq. prmphs ) then
               t11 = darupp(nif)
               t22 = daruss(nif)
               t12 = zero
               t21 = zero
               tsh = darush(nif)
             else if ( cnvnif .eq. cnvphs ) then
               t12 = darups(nif)
               t21 = darusp(nif)
               t11 = zero
               t22 = zero
               tsh = darush(nif)
             endif
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
         if ( nif .lt. plyr ) then
c           perturbed layer is below the interface
   	    if ( cnvnif .eq. allphs ) then
               x11 = dbtupp(nif)
               x22 = dbtuss(nif)
               x12 = dbtups(nif)
               x21 = dbtusp(nif)
               xsh = dbtush(nif)
               y11 = dbrdpp(nif)
               y22 = dbrdss(nif)
               y12 = dbrdps(nif)
               y21 = dbrdsp(nif)
               ysh = dbrdsh(nif)
             else if ( cnvnif .eq. prmphs ) then
               x11 = dbtupp(nif)
               x22 = dbtuss(nif)
               x12 = zero
               x21 = zero
               xsh = dbtush(nif)
               y11 = dbrdpp(nif)
               y22 = dbrdss(nif)
               y12 = zero
               y21 = zero
               ysh = dbrdsh(nif)
             else if ( cnvnif .eq. cnvphs ) then
               x12 = dbtups(nif)
               x21 = dbtusp(nif)
               x11 = zero
               x22 = zero
               xsh = dbtush(nif)
               y12 = dbrdps(nif)
               y21 = dbrdsp(nif)
               y11 = zero
               y22 = zero
               ysh = dbrdsh(nif)
             endif
	  else
c           perturbed layer is above the interface
   	    if ( cnvnif .eq. allphs ) then
               x11 = datupp(nif)
               x22 = datuss(nif)
               x12 = datups(nif)
               x21 = datusp(nif)
               xsh = datush(nif)
               y11 = dardpp(nif)
               y22 = dardss(nif)
               y12 = dardps(nif)
               y21 = dardsp(nif)
               ysh = dardsh(nif)
             else if ( cnvnif .eq. prmphs ) then
               x11 = datupp(nif)
               x22 = datuss(nif)
               x12 = zero
               x21 = zero
               xsh = datush(nif)
               y11 = dardpp(nif)
               y22 = dardss(nif)
               y12 = zero
               y21 = zero
               ysh = dardsh(nif)
             else if ( cnvnif .eq. cnvphs ) then
               x12 = datups(nif)
               x21 = datusp(nif)
               x11 = zero
               x22 = zero
               xsh = datush(nif)
               y12 = dardps(nif)
               y21 = dardsp(nif)
               y11 = zero
               y22 = zero
               ysh = dardsh(nif)
             endif
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
	 if((nif .eq. bnif).and.(plyr .ne. nlyrs-1))then
c	 if((nif .eq. bnif))then
	   lyr = bnif
	   phtp = cphs( -i*w*dxi(lyr)*thik(lyr) )
	   phts = cphs( -i*w*deta(lyr)*thik(lyr) )
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
	  endif
 10   continue
c
c	calculations now complete up top of
c	the perturbed layer
c	get the Dv/r and Ru above the perturbed layer
c
c
      if ( plyr .eq. 1 ) then
	lyr = 1 
	if ( cnvnif .eq. allphs ) then
         rnupp = druppfs
         rnuss = drussfs
         rnups = drupsfs
         rnusp = druspfs
         rnush = drushfs
	else if ( cnvnif .eq. prmphs ) then
         rnupp = druppfs
         rnuss = drussfs
         rnups = zero
         rnusp = zero
         rnush = drushfs
        else if ( cnvnif .eq. cnvphs ) then
         rnups = drupsfs
         rnusp = druspfs
         rnupp = zero
         rnuss = zero
         rnush = drushfs
        endif
c
c	initialize the displacement for reciever function
c
	 tdvp = ddvpfs
	 tdrp = ddrpfs
	 tdvs = ddvsfs
	 tdrs = ddrsfs
	 tdts = ddtshfs
c
c	handle the general case of perturbed layer in the
c
       else
	lyr = plyr - 1
	rnupp = srnupp(plyr-1)
	rnups = srnups(plyr-1)
	rnusp = srnusp(plyr-1)
	rnuss = srnuss(plyr-1)
	rnush = srnush(plyr-1)
	tdvp = sdvp(plyr-1)
	tdrp = sdrp(plyr-1)
	tdvs = sdvs(plyr-1)
	tdrs = sdrs(plyr-1)
	tdts = sdts(plyr-1)
      endif
c
c        form the reverberation operator for the top layer
c
	  t11 = rnupp
	  t22 = rnuss
	  t12 = rnups
	  t21 = rnusp
	  tsh = rnush
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
	 dvp = tdvp*t11 + tdvs*t21
         dvs = tdvp*t12 + tdvs*t22
         drp = tdrp*t11 + tdrs*t21
         drs = tdrp*t12 + tdrs*t22
         dts = tdts*tsh

c
c
c
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
      include  'kennett.inc'
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
      subroutine rcvind(p,f,plyr,nlyrs,dvp,dvs,drp,drs,dts)
      integer plyr,nlyrs
      complex p,f
      complex dvp,dvs,drp,drs,dts
c
c        compute receiver function - free surface displacement from a
c        plane wave incident from below, on a stack of plane, parallel,
c        homogeneous layers using the unperturbed interface matricies
c	 and the unperturbed layer parameters
c        using the indirect algorithm, 
c        rcvrfn and rcvrtd MUST BE CALLED FIRST!!
c        for a p, sv or sh wave incident
c        interface 0 is top of layer 1, a free surface,
c        layer n is half space
c        given frequency and phase slowness.
c
c          arguments...
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
c	 plyr - the unperturbed layer splitting the structure
c
c
c        commons and declarations
c
c
      include 'kennett.inc'
c
c        complex declarations
c
      complex i,zero,one,two,w
      complex t11,t12,t21,t22,l11,l12,l21,l22,tsh,lsh
      complex*16 det
      complex x11,x12,x21,x22,y11,y12,y21,y22,xsh,ysh
      complex tnupp,tnups,tnusp,tnuss,tnush
      complex rndpp,rndps,rndsp,rndss,rndsh
      complex rnupp,rnups,rnusp,rnuss,rnush
      complex tdvp,tdvs,tdrp,tdrs,tdts
      complex phtp,phts,phtpp,phtps,phtss
      real twopi
      integer lyr,nif,cnvnif,bnif,tnif
      external cphs
      complex cphs
      data i,zero/(0.,1.),(0.,0.)/,one,two/(1.,0.),(2.,0.)/
      data twopi/6.2831853064/
c
c
c
c     handle the special case of a half space
c
      w = twopi * f
      if ( nlyrs .eq. 1 ) then
         dvp = dvpfs
         dvs = dvsfs
         drp = drpfs
         drs = drsfs
         dts = dtshfs
         return
       endif
c
c	 special case for perturbed layer just above halfspace
c        initialize tup and rdown matricies for the stack with
c        bottom interface matricies
c
      if ( plyr .eq. nlyrs-1 ) then
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
	lyr = nlyrs - 1
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
c	now the special case of bottom layer has the right phase
c
c
c	normal case, perturbed layer, initialize Rd, Tu with
c	results stored by rcvrfn on its initial pass
c
       else
	 tnupp = stnupp(plyr+1)
	 tnups = stnups(plyr+1)
	 tnusp = stnusp(plyr+1)
	 tnuss = stnuss(plyr+1)
	 tnush = stnush(plyr+1)
	 rndpp = srndpp(plyr+1)
	 rndps = srndps(plyr+1)
	 rndsp = srndsp(plyr+1)
	 rndss = srndss(plyr+1)
	 rndsh = srndsh(plyr+1)
       endif
c
c	setup the interfaces to merge into the Rd and Tu
c	matrices
c
       if ( plyr .eq. nlyrs - 1 ) then
	 bnif = nlyrs - 2
	 tnif = bnif
	else if ( plyr .eq. 1 ) then
	 bnif = 1
	 tnif = 1
	else
	 bnif = plyr
	 tnif = plyr - 1
	endif
c
c	do the 'loop' for the calculation of Rd and Tu
c
       do 10 nif = bnif, tnif, -1
	 lyr = nif + 1
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
	 if((nif .eq. bnif).and.(plyr .ne. nlyrs-1))then
c	 if((nif .eq. bnif))then
	   lyr = bnif
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
	  endif
 10   continue
c
c	calculations now complete up top of
c	the perturbed layer
c	get the Dv/r and Ru above the perturbed layer
c
c
      if ( plyr .eq. 1 ) then
	lyr = 1 
	if ( cnvnif .eq. allphs ) then
         rnupp = ruppfs
         rnuss = russfs
         rnups = rupsfs
         rnusp = ruspfs
         rnush = rushfs
	else if ( cnvnif .eq. prmphs ) then
         rnupp = ruppfs
         rnuss = russfs
         rnups = zero
         rnusp = zero
         rnush = rushfs
        else if ( cnvnif .eq. cnvphs ) then
         rnups = rupsfs
         rnusp = ruspfs
         rnupp = zero
         rnuss = zero
         rnush = rushfs
        endif
c
c	initialize the displacement for reciever function
c
	 tdvp = dvpfs
	 tdrp = drpfs
	 tdvs = dvsfs
	 tdrs = drsfs
	 tdts = dtshfs
c
c	handle the general case of perturbed layer in the
c
       else
	lyr = plyr - 1
	rnupp = srnupp(plyr-1)
	rnups = srnups(plyr-1)
	rnusp = srnusp(plyr-1)
	rnuss = srnuss(plyr-1)
	rnush = srnush(plyr-1)
	tdvp = sdvp(plyr-1)
	tdrp = sdrp(plyr-1)
	tdvs = sdvs(plyr-1)
	tdrs = sdrs(plyr-1)
	tdts = sdts(plyr-1)
      endif
c
c        form the reverberation operator for the top layer
c
	  t11 = rnupp
	  t22 = rnuss
	  t12 = rnups
	  t21 = rnusp
	  tsh = rnush
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
	 dvp = tdvp*t11 + tdvs*t21
         dvs = tdvp*t12 + tdvs*t22
         drp = tdrp*t11 + tdrs*t21
         drs = tdrp*t12 + tdrs*t22
         dts = tdts*tsh

c
c
c
      return
      end
      subroutine rcvrdcn( a, p0, nlyrs,
     *                      nlmax,dt,ntmax,
     *                      delay, agauss, alfm, betm, rhom, thikm )
c
      integer*2 f,l
      parameter(f=513, l=45 )
      complex a(ntmax/2,nlmax)
      real p0, perta(l), pertb(l), pertr(l), delay, agauss
      integer nlyrs
      real alfm(l),betm(l),rhom(l),thikm(l)
c
      real qpm(l),qsm(l),ta(l),tb(l)
c
c
      complex dvp,dvs,drp,drs,dts,p,fr,rn
      real*8 wq,t1,t2,qa,qb,qabm,vabm
      real*8 gnorm
      integer*2 rvb
      integer plyr
      include 'kennett.inc'
c
      p = cmplx( p0, 0. )
      twopi = 8.*atan(1.)
      do 1 i = 1, nlyrs
      qpm(i) = 450.
      qsm(i) = 200.
      ta(i) = .16
      tb(i) = .26
 1    continue
c
      nft = 512
      nfpts = 257
c     fny = 2.5
c     dt = 1. / ( 2 * fny )
      fny = 1. / ( 2. * dt )
      t = dt * nft
      delf = 2. * fny / nft
c
c
c  correct delf for inverse transforms, dt cancelled in decon
c  so no delf in inverse transform, just 1/nft
c
      cdelf = 1. / float( nft )
      rvb = allrvb
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
         cnvrsn(i) = allphs
         reverb(i) = rvb
         rho(i) = rhom(i)
 5       thik(i) = thikm(i)
      cnvrsn(0) = allphs
c
      fr = cmplx(1.,0.)
      call ifmat(1,p,fr,nlyrs)
c     call delifm(p,fr,nlyrs,perta,pertb,pertr)
c
      gnorm = 0.0d0
      do 10 i = 1, nfpts
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
         gauss = wq / ( 2. * agauss )
         gauss = exp( - gauss * gauss )
	 gnorm = gnorm + gauss
         call rcvrfn(p,fr,nlyrs,dvp,dvs,drp,drs,dts)
         a(i,nlmax) = gauss * drp / ( dvp * (0.,1.))
10    continue
c
c
      do 20 i = 1,nfpts
       shf = twopi * (1-i) * delf * delay
         a(i,nlmax) = a(i,nlmax) * cexp( cmplx(0., shf) )
20    continue
      a(nfpts,nlmax) = (0.,0.)
      call dfftr(a(1,nlmax),nft,'inverse',cdelf)
c
      gnorm = gnorm / nfpts
      do 111 j = 1,nft/2
       a(j,nlmax) = a(j,nlmax) / gnorm
 111  continue
c
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
      include 'kennett.inc'
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
      subroutine rcvrtd(p,f,btlyr,dvp,drp,dvs,drs,dts)
      integer btlyr
      complex p,f
      complex dvp,drp,dvs,drs,dts
c
c	 compute reciever function using top down approach
c	 using code originally developed to 
c        compute reflectivity - reflection from a
c        plane wave incident from below, on a stack of plane, parallel,
c        homogeneous layers bounded above by free surface
c        for a p, sv or sh wave incident
c        layer btlyr is half space, with radiation condition
c        given frequency and phase slowness.
c
c	 intermediate results can be used to speed the 
c	 computation of differential seismograms used
c	 in parameter inversion studies
c
c          arguments...
c
c        f,p - prescribed freq (hz) & horizontal phase slowness (c is
c            not restricted to be greater than alfa or beta)
c            both may be complex
c
c        passed in common /model/
c        alfa,beta,qp,qs,rho and thik contain the medium properties for
c
c
c
c        commons and declarations
c
c
      include 'kennett.inc'
c
c        complex declarations
c
      complex i,zero,one,two,quartr,w
      complex t11,t12,t21,t22,l11,l12,l21,l22,tsh,lsh
      complex*16 det
      complex x11,x12,x21,x22,y11,y12,y21,y22,xsh,ysh
      complex rnupp,rnups,rnusp,rnuss,rnush
      complex tdvp,tdrp,tdvs,tdrs,tdts
      complex phtp,phts,phtpp,phtps,phtss
      real twopi,eps
      integer lyr,nif,cnvnif
      external cphs
      complex cphs
      data twopi,eps/6.2831853,.001/,i,zero/(0.,1.),(0.,0.)/,
     & one,two/(1.,0.),(2.,0.)/,quartr/(0.25,0.)/
c
c
      w = twopi*f
c     if(f .eq. (0.,0.)) w = (1.0e-6,0.)
c
c        initialize rupfs matrix for the stack with
c        free surface reflection matrix
c
      nif = 0
      cnvnif = cnvrsn(nif)
      if ( cnvnif .eq. allphs ) then
         rnupp = ruppfs
         rnuss = russfs
         rnups = rupsfs
         rnusp = ruspfs
         rnush = rushfs
       else if ( cnvnif .eq. prmphs ) then
         rnupp = ruppfs
         rnuss = russfs
         rnups = zero
         rnusp = zero
         rnush = rushfs
       else if ( cnvnif .eq. cnvphs ) then
         rnups = rupsfs
         rnusp = ruspfs
         rnupp = zero
         rnuss = zero
         rnush = rushfs
       endif
c
c	initialize the displacement for reciever function
c
       tdvp = dvpfs
       tdrp = drpfs
       tdvs = dvsfs
       tdrs = drsfs
       tdts = dtshfs
c
c        now do the top down recursion for rupfs
c
      do 10 lyr = 1, btlyr-1
         nif = lyr
c
c        use the two way phase delay through the layer
c        to/from the next interface
c
         phtp = cphs( -i*w*xi(lyr)*thik(lyr) )
         phts = cphs( -i*w*eta(lyr)*thik(lyr) )
         phtpp = phtp * phtp
         phtps = phtp * phts
         phtss = phts * phts
         rnupp = rnupp * phtpp
         rnuss = rnuss * phtss
         rnups = rnups * phtps
         rnusp = rnusp * phtps
         rnush = rnush * phtss
	 tdvp = tdvp * phtp
	 tdrp = tdrp * phtp
	 tdvs = tdvs * phts
	 tdrs = tdrs * phts
	 tdts = tdts * phts
	 sdvp(lyr) = tdvp
	 sdvs(lyr) = tdvs
	 sdrp(lyr) = tdrp
	 sdrs(lyr) = tdrs
	 sdts(lyr) = tdts
	 srnupp(lyr) = rnupp
	 srnups(lyr) = rnups
	 srnusp(lyr) = rnusp
	 srnuss(lyr) = rnuss
	 srnush(lyr) = rnush

c
c        form the reverberation operator for the layer
c
         cnvnif = cnvrsn(nif)
         if ( cnvnif .eq. allphs ) then
            t11 = rdpp(nif)
            t22 = rdss(nif)
            t12 = rdps(nif)
            t21 = rdsp(nif)
            tsh = rdsh(nif)
          else if ( cnvnif .eq. prmphs ) then
            t11 = rdpp(nif)
            t22 = rdss(nif)
            t12 = zero
            t21 = zero
            tsh = rdsh(nif)
          else if ( cnvnif .eq. cnvphs ) then
            t12 = rdps(nif)
            t21 = rdsp(nif)
            t11 = zero
            t22 = zero
            tsh = rdsh(nif)
          endif
         if ( reverb(lyr) .eq. allrvb ) then
            l11 = one - (rnupp*t11 + rnups*t21)
            l22 = one - (rnusp*t12 + rnuss*t22)
            l12 = - (rnupp*t12 + rnups*t22)
            l21 = - (rnusp*t11 + rnuss*t21)
            det = ( l11*l22 - l12*l21 )
            l12 = -l12/det
            l21 = -l21/det
            t11 = l11/det
            l11 = l22/det
            l22 = t11
            lsh = one / ( one - rnush*tsh )
         else if ( reverb(lyr) .eq. onervb ) then
            l11 = one + (rnupp*t11 + rnups*t21)
            l22 = one + (rnusp*t12 + rnuss*t22)
            l12 =  (rnupp*t12 + rnups*t22)
            l21 =  (rnusp*t11 + rnuss*t21)
            lsh = one + rnush*tsh
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
            x11 = tdpp(nif)
            x22 = tdss(nif)
            x12 = tdps(nif)
            x21 = tdsp(nif)
            xsh = tdsh(nif)
            y11 = rupp(nif)
            y22 = russ(nif)
            y12 = rups(nif)
            y21 = rusp(nif)
            ysh = rush(nif)
          else if ( cnvnif .eq. prmphs ) then
            x11 = tdpp(nif)
            x22 = tdss(nif)
            x12 = zero
            x21 = zero
            xsh = tdsh(nif)
            y11 = rupp(nif)
            y22 = russ(nif)
            y12 = zero
            y21 = zero
            ysh = rush(nif)
          else if ( cnvnif .eq. cnvphs ) then
            x12 = tdps(nif)
            x21 = tdsp(nif)
            x11 = zero
            x22 = zero
            xsh = tdsh(nif)
            y12 = rups(nif)
            y21 = rusp(nif)
            y11 = zero
            y22 = zero
            ysh = rush(nif)
          endif
c
c        t11 = l11*tupp(nif) + l21*tusp(nif)
c        t12 = l11*tups(nif) + l21*tuss(nif)
c        t21 = l12*tupp(nif) + l22*tusp(nif)
c        t22 = l12*tups(nif) + l22*tuss(nif)
         t11 = l11*x11 + l21*x12
         t12 = l11*x21 + l21*x22
         t21 = l12*x11 + l22*x12
         t22 = l12*x21 + l22*x22
         tsh = lsh * xsh
         l11 = rnupp*t11 + rnups*t21
         l12 = rnupp*t12 + rnups*t22
         l21 = rnusp*t11 + rnuss*t21
         l22 = rnusp*t12 + rnuss*t22
         lsh = rnush * tsh
c        rnupp = rupp(nif) + tdpp(nif)*l11 + tdps(nif)*l21
c        rnuss = russ(nif) + tdsp(nif)*l12 + tdss(nif)*l22
c        rnups = rups(nif) + tdpp(nif)*l12 + tdps(nif)*l22
c        rnusp = rusp(nif) + tdsp(nif)*l11 + tdss(nif)*l21
         rnupp = y11 + x11*l11 + x12*l21
         rnuss = y22 + x21*l12 + x22*l22
         rnups = y12 + x11*l12 + x12*l22
         rnusp = y21 + x21*l11 + x22*l21
         rnush = ysh + xsh*lsh
	 x11 = tdvp*t11 + tdvs*t21
	 x12 = tdvp*t12 + tdvs*t22
	 x21 = tdrp*t11 + tdrs*t21
	 x22 = tdrp*t12 + tdrs*t22
	 tdvp = x11
	 tdvs = x12
	 tdrp = x21
	 tdrs = x22
	 tdts = tdts*tsh
c
10    continue
c
	 dvp = tdvp
	 dvs = tdvs
	 drp = tdrp
	 drs = tdrs
	 dts = tdts
c
c
c
      return
      end
      subroutine sfpartials( a, p0,  perta, pertb, pertr, nlyrs,
     *                      nlmax, dt, ntmax,
     *                      delay, agauss, 
     *                      alfm, betm, rhom, thikm, pon )
c
      integer*2 f,l
      parameter(f=513, l=45 )
      complex a(ntmax/2,nlmax)
      real p0, perta(nlmax), pertb(nlmax), pertr(nlmax), delay, agauss
      integer nlyrs
      real alfm(l),betm(l),rhom(l),thikm(l)
      logical pon(l,6)
c
      real qpm(l),qsm(l),ta(l),tb(l)
c
      complex dvp,dvs,drp,drs,dts,p,fr,rn
      real*8 wq,t1,t2,qa,qb,qabm,vabm
      real*8 gnorm
      integer plyr,lyroff
      include 'kennett.inc'
c
      p = cmplx( p0, 0. )
      twopi = 8.*atan(1.)
      do 1 i = 1, nlyrs
      qpm(i) = 450.
      qsm(i) = 200.
      ta(i) = .16
      tb(i) = .26
 1    continue
c
      if ( nlmax .gt. mxlr ) then
         write(6,*) 'too many layers specified'
         return
       endif
      nft = 512
      nfpts = 257
      if ( nft .gt. ntmax ) then
         write(6,*) 'a matrix ntmax is too small'
         return
       endif
c     fny = 2.5
c     dt = 1. / ( 2 * fny )
      fny = 1. / ( 2. * dt )
      t = dt * nft
      delf = 2. * fny / nft
c
c  correct delf for inverse transforms, dt cancelled in decon
c  so no delf in inverse transform, just 1/nft
c
      cdelf = 1. / float( nft )
      rvb = allrvb
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
         cnvrsn(i) = allphs
         reverb(i) = rvb
         rho(i) = rhom(i)
 5       thik(i) = thikm(i)
      cnvrsn(0) = allphs
c
      fr = cmplx(1.,0.)
      call ifmat(1,p,fr,nlyrs)
      call delifm(p,fr,nlyrs,perta,pertb,pertr)
c
      gnorm = 0.0d0
      do 10 i = 1, nfpts
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
         gauss = wq / ( 2. * agauss )
         gauss = exp( - gauss * gauss )
	 gnorm = gnorm + gauss
         call rcvrfn(p,fr,nlyrs,dvp,dvs,drp,drs,dts)
c        a(i,nlmax-1) = gauss * dvs / ( dts )
         a(i,nlmax) = - gauss * drs * (0.,-1.) / ( dts )
         call rcvrtd(p,fr,nlyrs,dvp,drp,dvs,drs,dts)
c
       do 1000 plyr = 1, nlyrs-1
          if ( pon(plyr,1) .or. pon(plyr,2) .or. pon(plyr,3) ) then
            call delrcv(p,fr,plyr,nlyrs,dvp,dvs,drp,drs,dts)
            a(i,plyr) = - ( gauss*drs * (0.,-1.) ) / ( dts )
	  else
	    a(i,plyr) = (0.,0.)
          endif
 1000  continue
c
10    continue
c
c
      gnorm = gnorm / nfpts
c
      do 2000 plyr = 1, nlyrs-1
         if ( pon(plyr,1) .or. pon(plyr,2) .or. pon(plyr,3) ) then
              do 20 i = 1,nfpts
                 shf = twopi * (1-i) * delf * delay
                 if ( plyr .eq. 1 ) then
                   a(i,nlmax) = a(i,nlmax) 
     *                           * cexp( cmplx(0., shf ) )/gnorm
                 endif
                 a(i,plyr) = a(i,plyr) * cexp( cmplx(0., shf) )/gnorm
20            continue
              if ( plyr .eq. 1 ) then
              a(nfpts,nlmax) = (0.,0.)
              call dfftr(a(1,nlmax),nft,'inverse',cdelf)
              endif
              a(nfpts,plyr) = (0.,0.)
              call dfftr(a(1,plyr),nft,'inverse',cdelf)
         endif
c
2000  continue
c
c
      return
      end
      subroutine sfrcvrdcn( a, p0, nlyrs,
     *                      nlmax,dt,ntmax,
     *                      delay, agauss, alfm, betm, rhom, thikm )
c
      integer*2 f,l
      parameter(f=513, l=45 )
      complex a(ntmax/2,nlmax)
      real p0, perta(l), pertb(l), pertr(l), delay, agauss
      integer nlyrs
      real alfm(l),betm(l),rhom(l),thikm(l)
c
      real qpm(l),qsm(l),ta(l),tb(l)
c
c
      complex dvp,dvs,drp,drs,dts,p,fr,rn
      real*8 wq,t1,t2,qa,qb,qabm,vabm
      real*8 gnorm
      integer*2 rvb
      integer plyr,lyroff
      include 'kennett.inc'
c
      p = cmplx( p0, 0. )
      twopi = 8.*atan(1.)
      do 1 i = 1, nlyrs
      qpm(i) = 450.
      qsm(i) = 200.
      ta(i) = .16
      tb(i) = .26
 1    continue
c
      nft = 512
      nfpts = 257
c     fny = 2.5
c     dt = 1. / ( 2 * fny )
      fny = 1. / ( 2. * dt )
      t = dt * nft
      delf = 2. * fny / nft
c
c
c  correct delf for inverse transforms, dt cancelled in decon
c  so no delf in inverse transform, just 1/nft
c
      cdelf = 1. / float( nft )
      rvb = allrvb
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
         cnvrsn(i) = allphs
         reverb(i) = rvb
         rho(i) = rhom(i)
 5       thik(i) = thikm(i)
      cnvrsn(0) = allphs
c
      fr = cmplx(1.,0.)
      call ifmat(1,p,fr,nlyrs)
c
      gnorm = 0.0d0
c     lyroff = 2 * ( nlmax - 1 )
      do 10 i = 1, nfpts
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
         gauss = wq / ( 2. * agauss )
         gauss = exp( - gauss * gauss )
	 gnorm = gnorm + gauss
         call rcvrfn(p,fr,nlyrs,dvp,dvs,drp,drs,dts)
c        a(i,lyroff+1) = gauss * dvs / ( dts )
c        a(i,lyroff+2) = - gauss * drs * (0.,-1.) / ( dts )
         a(i,nlmax) = - gauss * drs * (0.,-1.) / ( dts )
10    continue
c
c
      gnorm = gnorm / nfpts
      do 20 i = 1,nfpts
       shf = twopi * (1-i) * delf * delay
c        a(i,lyroff+1) = a(i,lyroff+1) * cexp( cmplx(0., shf) )/gnorm
         a(i,nlmax) = a(i,nlmax) * cexp( cmplx(0., shf) )/gnorm
20    continue
c     a(nfpts,lyroff+1) = (0.,0.)
      a(nfpts,nlmax) = (0.,0.)
c     call dfftr(a(1,lyroff+1),nft,'inverse',cdelf)
      call dfftr(a(1,nlmax),nft,'inverse',cdelf)
c
c
c
      return
      end
      subroutine srcvrdcn( a, p0, nlyrs,
     *                      nlmax,dt,ntmax,
     *                      delay, agauss, duratn,
     *                      alfm, betm, rhom, thikm )
c
      integer nlmax,ntmax
      real a(ntmax,nlmax)
      real p0, delay, agauss, dt, duratn
      integer nlyrs,nft
      real alfm(*),betm(*),rhom(*),thikm(*)
      nft = 512
      iduratn = duratn / dt
c
      call sfrcvrdcn( a, p0, nlyrs,
     *                      nlmax,dt,ntmax,
     *                      delay, agauss, alfm, betm, rhom, thikm )
c
      vmax = 0.
      do 111 j = 1,iduratn
	 vmax = amax1( vmax,  a(j,nlmax) )
 111  continue
c
      do 112 j = 1,iduratn
	 a(j,nlmax) = a(j,nlmax) / vmax 
 112  continue
c
      return
      end
      subroutine dfftr (x,nft,dirctn,delta)
c                                              a.shakal, 1/78, 15 jul 80
c           this subroutine does a fast fourier transform on a real
c        time series.  it requires 1/2 the storage and e1/2 the time
c        required by a complex fft.
c
c     forward transform, "call dfftr(x,nft,'forward',dt)":
c           input = x(1),x(2),..,x(nft) = real time series of nft points
c          output = x(1),x(2),..,x(nft+2) = nft/2+1 complex spectral poi
c        these spectral points are identical to the first nft/2+1 return
c        by subroutine fft (i.e., pos freq terms).  thus, the coefficien
c        at fj, the j-th frequency point (where fj = (j-1)*delf, j=1,nft
c        and delf = 1/(nft*dt)), is in x(i-1),x(i), where i=2j.  x(1) is
c        dc term, x(2) = 0 (because real time series), x(nft+1) is real
c        of nyquist coef, and x(nft+2) is imaginary part (0 because real
c        series).
c
c     inverse transform, "call dfftr(x,nft,'inverse',delf)":
c        input and output are interchanged.
c
c           if this subroutine is called with 'forward', and then with '
c        and delf of 1/(nft*dt), the original time series is recovered.
c        identical results (but for scaling) can be obtained by calling
c        fft(x,nft,isign), but in fft a real time series must be stored
c        complex array with zero imaginary parts, which requires 2*nft p
c        of array x.  also, the coefs returned by the fft will differ by
c        n-scaling, since fft's leave out the dt,delf of the approximate
c        integrations.  this subroutine calls fft.
c           this subroutine is a modification of the subroutine 'fftr',
c        written by c.frasier.  the principal modifications are:
c             1) the delt,delf of the integrations are included to make
c                a discrete approximation to the fourier transform.
c             2) the storage of the spectrum (on output if forward, or i
c                if inverse) has x(2) = zero, with the nyquist component
c                x(nft+1), with x(nft+2) = 0.
c
      logical forwrd, invrse
      character dirctn*7
      complex  csign, c1, c2, c3, speci, specj
      real x(nft+2)
      pi = 3.1415927
c
      call lowcas(dirctn,invrse,forwrd)
c
      nftby2 = nft/2
      if (.not.(forwrd)) go to 20001
c            forward transform..
      call fft (x,nftby2,-1)
      x1 = x(1)
      x(1) = x1 + x(2)
      x(2) = x1 - x(2)
      sign = -1.
      go to 20002
20001 if (.not.(invrse)) go to 10001
c            adjust nyquist element storage for inverse transform
      x(2) = x(nft+1)
      x(nft+1) = 0.
      sign = +1.
      go to 20002
10001 stop 'dirctn bad to dfftr'
c
c           manipulate elements as appropropriate for a 1/2 length
c        complex fft, after the forward fft, or before the inverse.
20002 piovrn = pi*sign/float(nftby2)
      csign = cmplx(0.,sign)
      do 10 i = 3,nftby2,2
      j = nft-i+2
      c1 = cmplx(x(i)+x(j), x(i+1)-x(j+1))
      c2 = cmplx(x(i)-x(j), x(i+1)+x(j+1))
      w = piovrn*float(i/2)
      c3 = cmplx(cos(w),sin(w))*c2
      speci = c1 + csign*c3
      x(i) = real(speci)/2.
      x(i+1) = aimag(speci)/2.
      specj = conjg(c1) + csign*conjg(c3)
      x(j) = real(specj)/2.
      x(j+1) = aimag(specj)/2.
   10 continue
      x(nftby2+2) = -x(nftby2+2)
      if (.not.(forwrd)) go to 20004
c            include dt of integration, for forward transform...
      dt = delta
      do 9000  i = 1,nft
 9000 x(i) = x(i)*dt
c            adjust storage of the nyquist component...
      x(nft+1) = x(2)
      x(nft+2) = 0.
      x(2) = 0.
      go to 20005
20004 if (.not.(invrse)) go to 10002
      x1 = x(1)
      x(1) = (x1+x(2))/2.
      x(2) = (x1-x(2))/2.
c            do the inverse transform...
      call fft (x,nftby2,+1)
c            in the inverse transform, include the df of the integration
c            and a factor of 2 because only doing half the integration
c            (i.e., just over the positive freqs).
      twodf = 2.*delta
      do 9002  i = 1,nft
 9002 x(i) = x(i)*twodf
10002 continue
20005 return
      end
      subroutine fft(data,nn,isign)
c                                              a.shakal, 1/78, 10 jul 80
c        cooley-tukey 'fast fourier trnasform' in ansi fortran 77.
c
c           transform(j) = sum {data(i)*w**u(i-1)*(j-1)e}, where i and
c        j run from 1 to nn, and w = exp(sign*twopi*sqrtu-1e/nn).
c        data is a one-dimensional complex array (i.e., the real and
c        imaginary parts of the data are located immediately adjacent
c        in storage, such as fortran places them) whose length nn is
c        a power of two.  isign is +1 or -1, giving the sign of the
c        transform.  transform values are returned in array data,
c        replacing the input data.  the time is proportional to
c        n*log2(n), rather than the non-fft n**2.  modified from the
c        fortran ii coding from n.brenner's mit-ll tech rept.
c
      real data(2*nn)
      pi = 3.1415926
c
      n = 2*nn
      j = 1
      do 5 i = 1,n,2
      if (.not.(i .lt. j)) go to 20001
      tempr = data(j)
      tempi = data(j+1)
      data(j) = data(i)
      data(j+1) = data(i+1)
      data(i) = tempr
      data(i+1) = tempi
20001 m = n/2
    3 if (.not.(j .gt. m)) go to 20004
      j = j-m
      m = m/2
      if (m .ge. 2) go to 3
20004 j = j+m
   5  continue
c
c
      mmax = 2
    6 if (.not.(mmax .ge. n)) go to 20007
      return
20007 if (.not.(mmax .lt. n)) go to 10001
      istep = 2*mmax
      pibymx = pi*float(isign)/float(mmax)
c
      do 8 m = 1,mmax,2
      theta = pibymx*float(m-1)
      wr = cos(theta)
      wi = sin(theta)
      do 8 i = m,n,istep
      j = i + mmax
      tempr = wr*data(j) - wi*data(j+1)
      tempi = wr*data(j+1) + wi*data(j)
      data(j) = data(i) - tempr
      data(j+1) = data(i+1) - tempi
      data(i) = data(i) + tempr
      data(i+1) = data(i+1) + tempi
   8  continue
      mmax = istep
      go to 6
10001 continue
20008 return
      end
      subroutine lowcas(dirctn,invrse,forwrd)
      character dirctn*7
      logical forwrd,invrse
      if(dirctn.eq.'forward') go to 1
      if(dirctn.eq.'inverse') go to 2
      write(1,100)dirctn
  100 format(1x,a7,2x,'is meaningless to dfftr, use forward or inverse
     *only')
      invrse=.false.
      forwrd=.false.
      return
    1 invrse=.false.
      forwrd=.true.
      return
    2 invrse=.true.
      forwrd=.false.
      return
      end
