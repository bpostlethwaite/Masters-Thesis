C     Program with noninteractive input to generate receiver function
C     synthetics for grid-search.
C
C     Input parameters:
C        -type [ p | s ]: RF type P (default) or S
C        -sps x:  x samples per second
C        -dt x:  x sample interval (1/dt == sps)
C        -p x [ s/km | s/deg ]:  input slowness x and unit
C        -confirm - Write file name(s) produced on standard output
C        -gen zrt - Generate synthetic of z, r or t component (add
C           letters as needed).
C        -resp [f|p|n] - full (full reverberations), partial (one reverb.)
C           or no reverberations (default full)
C        -sph - Spherical earth calculation, apply earth flattening transform
C
C     Modified from respknt by G. Helffrich/U. Bristol, Summer 2006.
C        Last mod. 29 Jul. 2008
      parameter (toff=-20.0, Re=6371., nlmx=150, eps=1e-4)
      parameter (ncpts=4096, nrpts=2*ncpts)
      real alfm(nlmx), betm(nlmx), rhom(nlmx), thikm(nlmx)
      real alfb(nlmx), betb(nlmx), rhob(nlmx)
      real qpm(nlmx), qsm(nlmx), ta(nlmx), tb(nlmx)
      complex u0(2*ncpts),w0(2*ncpts),u1(2*ncpts),w1(2*ncpts)
      complex tn(2*ncpts)
      real u0r(2*nrpts), w0r(2*nrpts), tnr(2*nrpts), u1r(2*nrpts)
      real w1r(2*nrpts)
      equivalence (u0,u0r),(w0,w0r),(tn,tnr),(u1,u1r),(w1,w1r)
      complex dvp,dvs,drp,drs,dts,p,fr,vslow,vlo,vhi,vdv
      real*8 wq,t1,t2,qa,qb,qabm,vabm
      common /tauval/ p, zlo, vlo, vdv
      external pslow
      character*256 ofil,ofilz,ofilr,ofilt
      character modela*256,title*32
      character*6  comp(3)
      character*1 complt,modcnv
      integer*2 rvb, cnv
      integer blank
      logical rdlyr, wh, conf, genz, genr, gent, sunit, oefa
      include 'kennett.inc'
      data comp/'_sp.z ','_sp.r ','_sp.t '/, ipors/1/, conf/.false./
      data genz, genr, gent/3*.true./, complt/'f'/, oefa/.false./
      data modcnv /'y'/
c
      efp(z) = Re/(Re-z)
      efz(z) = Re*log(efp(z))
c
      if (nlmx.gt.mxlr) stop '**COMMON dimensioning problem'
      twopi = 8.*atan(1.)
      pr = -1.0
      dt = 0.0
      iskip = 0
      do 5 i=1,iargc()
         if (i.le.iskip) go to 5
         call getarg(i,ofil)
         if (ofil .eq. '-sps' .or. ofil .eq. '-dt') then
	    wh = ofil .eq. '-sps'
	    iskip = i+1
	    call getarg(i+1,ofil)
	    if (ofil.ne.' ') read(ofil,*,iostat=ios) dt
	    if (ios.ne.0.or.dt.le.0) stop '**Bad -dt value'
	    if (wh) dt = 1./dt
	 else if (ofil .eq. '-p') then
	    iskip = i+2
	    call getarg(i+2,ofil)
	    if (ofil .ne. 's/km' .and. ofil .ne. 's/deg')
     &         stop '**Bad slowness unit (s/deg or s/km needed)'
	    sunit = ofil .eq. 's/deg'
	    call getarg(i+1,ofil)
	    if (ofil.ne.' ') read(ofil,*,iostat=ios) pr
	    if (ios.ne.0 .or. pr.lt.0) stop '**Bad -p value'
	    if (sunit) pr = pr*360/(twopi*Re)
	 else if (ofil .eq. '-type') then
	    call getarg(i+1,ofil)
	    if (ofil .eq. 'p' .or. ofil .eq. 'P') then
	       ipors = 1
	    else if (ofil .eq. 's' .or. ofil .eq. 'S') then
	       ipors = 2
	    else
	       stop '**Bad RF -type (should be either S or P)'
	    endif
	    iskip = i+1
	 else if (ofil(1:5) .eq. '-resp') then
	    call getarg(i+1,ofil)
	    complt = ofil(1:1)
	    iskip = i+1
	 else if (ofil(1:5) .eq. '-mcnv') then
	    call getarg(i+1,ofil)
	    modcnv = ofil(1:1)
	    iskip = i+1
	 else if (ofil(1:4) .eq. '-con') then
	    conf = .true.
	 else if (ofil(1:4) .eq. '-sph') then
	    oefa = .true.
	 else if (ofil(1:4) .eq. '-gen') then
	    call getarg(i+1,ofil)
	    genz = index(ofil,'z') .ne. 0
	    genr = index(ofil,'r') .ne. 0
	    gent = index(ofil,'t') .ne. 0
	    iskip = i+1
	 else
            iblank=blank(ofil)
	    write(0,*) '**Unrecognized parameter: ',ofil(1:iblank)
	    stop
	 endif
 5    continue
      if (dt .le. 0) stop '**No sample rate given (-sps or -dt)'
      if (pr .lt. 0) stop '**No slowness given (-p x s/km or s/deg)'
c
1000  continue
      call newhdr
c

      ofil = '                                '
      ofilr = '                                '
      ofilz = '                                '
      ofilt = '                                '

c
c     write(ounit,*) 'Velocity Model Name'
      read(*,'(a)',iostat=ios) modela
      if (ios.ne.0) stop
      
      iblank=blank(modela)
      ofil(1:iblank) = modela(1:iblank)

      wh = rdlyr(7,modela,nlmx,nlyrs,title,
     &   alfm,betm,rhom,thikm,alfb,betb,rhob,qpm,qsm)
      if (.not.wh) stop

c     Apply earth flattening transformation if requested
      if (oefa) then
         zz = 0.0
	 zf = 0.0
         do i=1,nlyrs
	    zhw = zz + 0.5*thikm(i)
	    zaw = zz +     thikm(i)
	    zfb = efz(zaw)
	    thikm(i) = zfb - zf
	    if (alfb(i) .eq. 0.0) then
	       fac = efp(zhw)
	       alfm(i) = alfm(i)*fac
	       betm(i) = betm(i)*fac
	       rhom(i) = rhom(i)/fac
	    else
	       fact= efp(zz )
	       facb= efp(zaw)
	       alfm(i) = alfm(i)*fact
	       betm(i) = betm(i)*fact
	       rhom(i) = rhom(i)/fact
	       alfb(i) = alfb(i)*facb
	       betb(i) = betb(i)*facb
	       rhob(i) = rhob(i)/facb
	    endif
	    zz = zaw
	    zf = zfb
	 enddo
      endif

      do i=1,nlyrs
*        qpm(i) = 500.
*        qsm(i) = 225.
         if (qpm(i) .eq. 0) then
	    qpm(i) = 125
	    qsm(i) = 62.5
         endif
         ta(i) = .16
         tb(i) = .26
      enddo

c
c     terminal input
c
c      write(ounit,*) 'incident P(1) or S(2) wave'
c      read(inunit,*) ipors                       Ali:I fixed the inpt to P
c      write(6,*) 'sampling interval'             Ali: I fixed dt to 0.02
c      read(5,*) dt
c      dt = 0.02
c      write(6,*) 'signal duration'               Ali: I fixed the dur. to 65
c      read(5,*) t
      if (ipors.eq.1) then
         t = 200
      else
         t = 200
      endif
c     write(6,*) 'incident delay'
c     read(5,*) tdelay
c     write(6,*) 'output file base name'
c     read(5,'(a)') ofil
c     write(6,*) ' enter slowness: '
c     read(5,*) pr
c      write(6,*) ' partial(p) or full(f) : '     Ali: modified to always full
c      read(5,'(a1)') complt
c     complt = 'f'
c      write(6,*) ' mode conversions? (y or n) '  Ali: modified to always yes
c      read(5,'(a1)') modcnv
      modcnv = 'y'
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
      if (nfpts.gt.ncpts) stop '**Time window too long.'
c
c     set up some computational parameters
c          specifying the type of response
c          requested.
c
      p = cmplx(pr,0.)
      if ( 0 .ne. index('Ff',complt(1:1)) )  then
         rvb = allrvb
      else if ( 0 .ne. index('Pp',complt(1:1)) )  then
         rvb = onervb
      else
         rvb = norvb
      endif
      if ( 0 .ne. index('Nn',modcnv(1:1)) ) then
         cnv = prmphs
      else
         cnv = allphs
      endif
c
c
c
c     compute q, alfa, and beta at 1 hz for absorbtion band
c
      z = 0.0
      tlag = 0.0
      tlas = 0.0
      t1 = 1.0d04
      wq = twopi
      do i = 1, nlyrs
         qa = qpm(i)
         qb = qsm(i)
         t2 = ta(i)
         alfa(1,i) = alfm(i) * vabm(wq,t1,t2,qa)
         t2 = tb(i)
         beta(1,i) = betm(i) * vabm(wq,t1,t2,qb)
         qa = qabm(wq,t1,t2,qa)
         qb = qabm(wq,t1,t2,qb)
         alfa(1,i) = alfa(1,i)*( 1. + (0.,0.5)/qa)
         beta(1,i) = beta(1,i)*( 1. + (0.,0.5)/qb)
         cnvrsn(i) = cnv
         reverb(i) = rvb
         rho(1,i) = rhom(i)
C        thik(i) = thikm(i)
	 zlo = z
	 zhi = z + thikm(i)
	 if (alfb(i) .eq. 0) then
            tlag = tlag + thikm(i)*sqrt(1.0 - (alfm(i)*pr)**2)/alfm(i)
	    pla(i) = thikm(i)*vslow(alfa(1,i),p,(1.,0.))
            alfa(2,i) = alfa(1,i)
	    alfb(i) = alfm(i)
	    wh = .true.
	 else
	    vlo = alfa(1,i)
            vhi = alfb(i) * vabm(wq,t1,dble(ta(i)),dble(qpm(i)))
	    vdv = (vhi-vlo)/(zhi-zlo)
	    tau = tauint(pslow,zlo,zhi,eps)
	    pla(i) = tau
            alfa(2,i) = vhi
	    tlag = tlag + tau
	    wh = .false.
	 endif
	 if (betb(i) .eq. 0) then
            tlas = tlas + thikm(i)*sqrt(1.0 - (betm(i)*pr)**2)/betm(i)
	    plb(i) = thikm(i)*vslow(beta(1,i),p,(1.,0.))
            beta(2,i) = beta(1,i)
	    betb(i) = betm(i)
	 else
	    vlo = beta(1,i)
            vhi = betb(i) * vabm(wq,t1,dble(tb(i)),dble(qsm(i)))
	    vdv = (vhi-vlo)/(zhi-zlo)
	    tau = tauint(pslow,zlo,zhi,eps)
	    plb(i) = tau
            beta(2,i) = vhi
	    tlas = tlas + tau
	    wh = .false.
	 endif
	 if (rhob(i) .eq. 0) then
	    rho(2,i) = rhom(i)
	 else
	    rho(2,i) = rhob(i)
	    wh = .false.
	 endif
	 cvlyr(i) = wh
	 z = zhi
      enddo
      cnvrsn(0) = cnv
      if ( complt(1:1) .ne. 'f' )  then
         reverb(1) = onervb
      endif
c
      fr = cmplx(1.,0.)
      call ifmat(1,p,fr,nlyrs)
c
      do i = 1, nfpts-1
         fr = cmplx(delf * ( i - 1 ), 0. )
         wq = twopi * fr
         do j = 1, nlyrs
            qa = qpm(j)
            qb = qsm(j)
            t2 = ta(j)
            alfa(1,j) = alfm(j) * vabm(wq,t1,t2,qa)
            alfa(2,j) = alfb(j) * vabm(wq,t1,t2,qa)
            t2 = tb(j)
            beta(1,j) = betm(j) * vabm(wq,t1,t2,qb)
            beta(2,j) = betb(j) * vabm(wq,t1,t2,qb)
            qa = qabm(wq,t1,t2,qa)
            qb = qabm(wq,t1,t2,qb)
            alfa(1,j) = alfa(1,j)*( 1. + (0.,0.5)/qa)
            alfa(2,j) = alfa(2,j)*( 1. + (0.,0.5)/qa)
            beta(1,j) = beta(1,j)*( 1. + (0.,0.5)/qb)
            beta(2,j) = beta(2,j)*( 1. + (0.,0.5)/qb)
         enddo
         call rcvrfn(p,fr,nlyrs,dvp,dvs,drp,drs,dts)
         u0(i) = dvp * (0.,-1.)*(-1.,0.)
         w0(i) = drp
         u1(i) = dvs
         w1(i) = drs * (0.,1.)
         tn(i) = dts
      enddo
      u0(nfpts) = (0.,0.)
      w0(nfpts) = (0.,0.)
      u1(nfpts) = (0.,0.)
      w1(nfpts) = (0.,0.)
      tn(nfpts) = (0.,0.)

c     Fake up station and event information

      call setfhv('evla',0.001,nerr)
      call setfhv('evlo',0.001,nerr)
      call setfhv('evdp',  0.0,nerr)
      call setfhv('stla',0.001,nerr)
      call setfhv('stlo',90.00,nerr)
      call setfhv('baz',270.0,nerr)
      call setfhv('az',90.0,nerr)
      call setfhv('gcarc',90.0,nerr)
      call setnhv('nzyear',1999,nerr)
      call setnhv('nzjday',365,nerr)
      call setnhv('nzhour',23,nerr)
      call setnhv('nzmin',59,nerr)
      call setnhv('nzsec',59,nerr)
      call setnhv('nzmsec',999,nerr)

c
c     output the responses
c
      if(ipors.eq.1)then
	 tbeg = toff
         fsarg = twopi*tlag/t
         do i=1,nfpts
	    fr = exp(cmplx(0.,fsarg*(i-1)))
	    u0(i) = u0(i)*fr
	    w0(i) = w0(i)*fr
            tn(i) = 0.0
         enddo
	 do i=nfpts+1,nft+2
	    u0(i) = 0.0
	    w0(i) = 0.0
	 enddo
         if (genz) call dfftr(u0,nft,'inverse',delf)
         if (genr) call dfftr(w0,nft,'inverse',delf)
      else
	 tbeg = toff-70
         fsarg = twopi*(tlas-70)/t
	 do i=1,nfpts
	    fr = exp(cmplx(0.,fsarg*(i-1)))
	    u1(i) = u1(i)*fr
	    w1(i) = w1(i)*fr
	    tn(i) = tn(i)*fr
	 enddo
         if (genz) call dfftr(u1,nft,'inverse',delf)
         if (genr) call dfftr(w1,nft,'inverse',delf)
         if (gent) call dfftr(tn,nft,'inverse',delf)
	 tlag = tlas
	 do i=1,numpts
	    u0r(i) = u1r(i)
	    w0r(i) = w1r(i)
	 enddo
      endif

c     Shift data to proper place in output traces.
      nshft = nint(-toff/dt)
      do i=numpts,1,-1
         u0r(i+nshft) = u0r(i)
         w0r(i+nshft) = w0r(i)
         tnr(i+nshft) = tnr(i)
      enddo
      do i=1,nshft
         u0r(i) = 0.0
         w0r(i) = 0.0
         tnr(i) = 0.0
      enddo
      numpts = numpts + nshft
      call setfhv('b',tbeg,nerr)
      call setfhv('e',tbeg+(numpts-1)/dt,nerr)
      call setfhv('delta',dt,nerr)
      call setnhv('npts',numpts,nerr)
      if (sunit) then
         call setfhv('user0',pr*twopi*Re/360,nerr)
	 call setkhv('kuser0','s/deg',nerr)
      else
         call setfhv('user0',pr,nerr)
	 call setkhv('kuser0','s/km',nerr)
      endif
      if (ipors.eq.1) then
         call setfhv('a',-10.0,nerr)
         call setfhv('f', 80.0,nerr)
	 call setkhv('ka','P',nerr)
      else
         call setfhv('a', -75.0,nerr)
         call setfhv('f',   3.0,nerr)
         call setfhv('t0',-85.0,nerr)
         call setfhv('t1',-75.0,nerr)
	 call setkhv('ka','S',nerr)
      endif
      call setkhv('kt0','noise',nerr)
      call setkhv('kt1','_',nerr)
      ofil = '$'

c     Write out vertical component
      if (genz) then
	 call setfhv('cmpaz',0.0,nerr)
	 call setfhv('cmpinc',0.0,nerr)
	 call wsac0(ofilz,u0r,u0r,nerr)
	 i = blank(ofilz)
	 ofil(index(ofil,'$'):) = ofilz(1:i) // ' $'
      endif

c     Write out radial component
      if (genr) then
	 call setfhv('cmpaz',90.0,nerr)
	 call setfhv('cmpinc',90.0,nerr)
	 call wsac0(ofilr,w0r,w0r,nerr)
	 i = blank(ofilr)
	 ofil(index(ofil,'$'):) = ofilr(1:i) // ' $'
      endif

c     Write out tangential component
      if (gent) then
	 call setfhv('cmpaz',0.0,nerr)
	 call setfhv('cmpinc',90.0,nerr)
	 call wsac0(ofilt,tnr,tnr,nerr)
	 i = blank(ofilt)
	 ofil(index(ofil,'$'):) = ofilt(1:i) // ' $'
      endif

      if (conf) write(*,'(a)') ofil(1:index(ofil,'$')-1)
      call flush
c    
      go to 1000
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

      function pslow(z)
      complex vel, vslow, p, vlo, vdv
      common /tauval/ p, zlo, vlo, vdv

      vel = vlo + (z - zlo)*vdv
      pslow = abs(vslow(vel, p, (1.0,0.0)))
      end
