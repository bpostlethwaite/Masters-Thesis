C     Deconvolution of Z component from horizontal components, equalized.
C
C     Based on pwaveqn program by Owens/Randall/Ammon to do water-level
C     frequency-domain deconvolution of Z component from horizontal components.
C     Modified to eliminate water level and deconvolve based on noise estimate
C     (determined at each frequency) from time window preceding P-wave arrival.
C
C     Horizontals equalized based on gain before being rotated to R and T
C     directions.  Then deconvolved.  Output are files with
C        .eqr, .eqt, and .eqz suffixes.
C     Output files normalized to unit amplitude on vertical component.  Original
C     amplitude is saved in SCALE variable in each output file.  To get original
C     amplitude, multiply by SCALE value.
C
C     Takes SAC file names from command line (any order for Z, N and E) -
C        figures out component identity from orientations.
C     Command-line arguments begin with dash:
C        -debug - write mod-squared spectra for wavelet and noise, and
C            mod-squared spectra for all traces.  Files named
C            xxx.wspec, xxx.nspec - window and noise spectra
C            xxx.1.spec, xxx.2.spec, xxx.3.spec - trace spectra (r, t, z)
C
C     Takes two lines of input:
C        begin time, end time, phase ID
C        any number (ignored), gauss filter param., phase shift (sec.)
C
C     Begin and end time define wavelet.  Deconvolved trace starts at begin
C     time and runs to end of seismogram (or ndim points, whichever less).
C     Phase id put in KUSER0 to identify phase.  Gauss filter param. is
C     low-pass filter applied to output to prevent excessive ringing in
C     deconvolution.  Phase shift sets origin for deconvolution output to be
C     something other than zero to see pre-spike signal level.
C
C     G. Helffrich/U. Bristol 31 Oct. 2001-11 Jan. 2003
C
C     Notes:
C     - Wavelet (usually P-wave) window is *not* the whole vertical component
C       trace.  It is a window picked around the P-wave arrival.  This gives
C       you more scope to isolate the P-wave from extraneous signal (depth
C       phase, PcP, etc.)  If you don't like this, then make your window the
C       whole trace.
C     - Noise estimate comes from data immediately preceding the wavelet
C       window - same duration as the wavelet window.
C     - Noise and wavelet spectra are tapered to reduce spectrum leakage.
C       Trace data is *not* tapered to treat data equally anywhere in the trace
C       rather than downweighting data at trace extremes.  This is motivated
C       by use for work with transition zone structure, where you want to
C       preserve arrival amplitudes late in the trace (P410s is about 40 s
C       and P660s is about 60 s after P).
C     - Method for spectral weighting is motivated by optimal filtering
C       approach.  Deconvolution by spectral division is done by
C       multiplying numerator and denominator by z* (z conjugate).  Thus
C       x/z = (x z*)/(z z*) and the denominator is real.  Now treat this as
C       an optimal filtering exercise.  Given x = u*z (here * means time-domain
C       convolution), an optimal (frequency domain) estimate of u is 
C       u = (x F)/z where F is the optimal filter, given by
C          F(f) = S(f)**2/(S(f)**2 + N(f)**2)
C       where S and N are signal and noise estimates, respectively.  If
C       S == z (the wavelet), and N is the noise preceding z (call it n), then
C          F(f) = z(f)**2/(z(f)**2 + n(f)**2) = (z z*)/(z z* + n n*),
C       leading to the estimate for u of
C          u = (x z*)(z z*)/[(z z*)(z z* + n n*)] = (x z*)/(z z* + n n*)
C       So there is no water level value, only the scalar (z z* + n n*) that
C       weights the contribution at each frequency.

      program pwaveqn
      parameter (npmax=30000,npow=12,ndim=2**npow, aztol=0.001)
      logical ex,debug
      real se(npmax),sn(npmax),s(npmax,3)
      real d2(ndim),dw(ndim),dn(ndim,3),tap(ndim/2+1),sig(ndim/2+1)
      complex cval,data(ndim/2,3),wdata(ndim/2),nois(ndim/2,3)
      equivalence (se,d2),(sn,dw)
      real caz(3),cin(3),cgain(3)
      integer	npts,fix(3)
      character line*255, rtz(3)
      character scomp(3)*4, sphase*7, sacpfx*128
      data rtz/'R','T','Z'/

      pi = 4.0*atan(1.0)
      rad = 180.0/pi
      debug = .false.

c     Check presence of SAC files.  Read Z component header and fill info
c       from this.
      ix = 0
      iskip = 0
      do 5 i=1,iargc()
         if (i .le. iskip) go to 5
         call getarg(i,line)
	 if (line(1:1) .eq. '-') then
	    if (line .eq. '-debug') then
	       debug = .true.
	    else
	       write(0,*) '**Don''t understand ',line(1:lenstr(line)),
     +            ', skipping.'
            endif
	 else
	    if (ix .ge. 3) stop '**Too many input file names.'
	    ix = ix + 1
	    fix(ix) = i
	    inquire (file=line,exist=ex)
            if (.not. ex) then
	       write(0,*) '**',line(1:lenstr(line)),' doesn''t exist,',
     +            'quitting.'
	       stop
            endif
	 endif
5     continue
      if (ix .ne. 3) stop '**Not enough input files.'
c     Prefix to generated SAC file names is SAC file name stripped of its
c       .xxx suffix.  This prefix becomes the header "file" name.
      call getarg(fix(1),line)
      isfx = 0
      ipfx = 0
      do i=lenstr(line),1,-1
        if (line(i:i) .eq. '.' .and. isfx .eq. 0) isfx = i
        if (line(i:i) .eq. '/' .and. ipfx .eq. 0) ipfx = i
      enddo
      if (isfx .eq. 0) isfx = lenstr(line)+1
      sacpfx = line(1:isfx-1)
      lsacpf = isfx-1

c     Read in data - no component inversion necessary for SAC azimuth 
c     convention.  Rotate to radial, tangential for processing.
c     There is no constraint on the orientation of the components except
c     that they differ in orientation by 90 degrees.
      do icomp=1,3
	call getarg(fix(icomp),line)
	call rsac1(line,s(1,icomp),npts,beg,dt,ndim,nerr)
	if (nerr .ne. 0) stop '**Trouble reading SAC input file.'
	call getkhv('KCMPNM',scomp(icomp),nerr)
	call getfhv('CMPAZ',caz(icomp),nerr)
	call getfhv('CMPINC',cin(icomp),nerr)
	call getfhv('SCALE',cgain(icomp),nerr)
        if (nerr .ne. 0) cgain(icomp) = 0.0
        if (cgain(icomp) .lt. 0.0) write(*,123) icomp
      enddo

c     Read header info from one of the files to get event info.
      call getfhv('O',origin,nerr)
      call getfhv('EVLA',elat,nerr1)
      call getfhv('EVLO',elon,nerr2)
      call getfhv('EVDP',edep,nerr3)
      if (nerr1 .ne. 0 .or. nerr2 .ne. 0 .or. nerr3 .ne. 0)
     +  stop '**Event information isn''t in file header.'
      call getfhv('GCARC',edist,nerr1)
      call getfhv('AZ',eaz,nerr2)
      call getfhv('BAZ',ebaz,nerr3)
      if (nerr1 .ne. 0 .or. nerr2 .ne. 0 .or. nerr3 .ne. 0) then
        call getfhv('STLA',stla,nerr1)
        call getfhv('STLO',stlo,nerr2)
        if (nerr1 .ne. 0 .or. nerr2 .ne. 0)
     +    stop '**Station information isn''t in file header.'
        call gcd(elat,elon,stla,stlo,edist,delkm,eaz,ebaz)
      endif

c     Normalize gains of all components
      if (cgain(1) .ne. 0.0 .and.
     &    cgain(2) .ne. 0.0 .and.
     &    cgain(3) .ne. 0.0) then
	 do icomp=1,3
	    call scalar(s(1,icomp),npts,1./cgain(icomp))
	 enddo
      else
	 write(*,122)
      endif

c     Sort out whether any rotation to N and E is necessary.  By the end
c     of this operation, sn has N time series, se has E time series, and
c     s(n,3) has vertical.  
      if (cin(3) .eq. 0.0) then
	 i1 = 1
	 i2 = 2
	 ih = 3
      else if (cin(2) .eq. 0.0) then
	 i1 = 1
	 i2 = 3
	 ih = 2
      else if (cin(1) .eq. 0.0) then
	 i1 = 2
	 i2 = 3
	 ih = 1
      else
	 stop '**No vertical component given.'
      endif
      if (abs(cin(i1)-90.0) .gt. aztol .or. 
     +    abs(cin(i2)-90.0) .gt. aztol) 
     +   stop '**"Horizontal" components aren''t horizontal.'
      if (abs(dtheta(caz(i1)/rad,caz(i2)/rad)*rad - 90.0)
     +    .lt. aztol) then
c         1 leads 2 by 90.0 - rotate 1 to E
          if (caz(i2) .ne. 0.0) then
             write(*,130) caz(i2),caz(i1)
	  endif
          call rotcomp(s(1,i1),s(1,i2),se,sn,npts,caz(i2)/rad)
      else if (abs(dtheta(caz(i2)/rad,caz(i1)/rad)*rad - 90.0)
     +    .lt. aztol) then
c        2 leads 1 by 90.0 - rotate 2 to E
	 if (caz(i1) .ne. 0.0) then
	    write(*,130) caz(i1),caz(i2)
	 endif
	 call rotcomp(s(1,i2),s(1,i1),se,sn,npts,caz(i1)/rad)
      else
	 stop '**Horizontal components not 90 degrees apart.'
      endif
      if (ih .ne. 3) call tscopy(s(1,ih),s(1,3),npts)
      call tscopy(se,s(1,1),npts)
      call tscopy(sn,s(1,2),npts)
      do i=1,3
	 call demean(s(1,i),npts)
      enddo
	
c     Read in start time relative to file zero and name of phase.

      read(*,*,iostat=ios) tloc1,tloc2,sphase
      if (ios .ne. 0) stop '**Invalid begin or end time.'
      loc1 = nint((tloc1-beg)/dt)
      loc2 = nint((tloc2-beg)/dt)
      nloc = loc2-loc1+1
      nout = 1 + npts-loc1
      nout = npts
      if (loc1 .gt. npts .or. loc2 .gt. npts .or.
     +    loc1 .lt. 1 .or. loc2 .lt. 1) stop '**Bad wavelet window.'
      if (nloc .gt. ndim) stop '**Wavelet window too large.'
      if (nloc .gt. loc1)
     +   stop '**Insufficient data for noise est. preceding wavelet.'
      if (nout .gt. ndim) then
         write(0,*) '**Deconvolution output shortened to ',
     +      nint(ndim*dt),' secs., input file too long.'
         nout = ndim
      endif

c     Rotate to change n-e to r-t time series.  s(i,1)->r, s(i,2)->t
      call tscopy(s(1,1),se,npts)
      call tscopy(s(1,2),sn,npts)
      call rotsub(sn,se,s(1,1),s(1,2),npts,ebaz/rad)

c     Extract deconvolution wavelet and taper.  Note dw and wdata are
c        same storage, real array overlaying complex one.
      if (.false.) then
	 do i=1,nloc
	    tap(i) = 1.0
	 enddo
      else
         call kbtaper(3.5,nloc,tap)
c        call costap(max(10,nint(1./dt)),nloc,tap)
      endif
c     if (debug) then
c        call setnhv('NPTS',nloc,nerr)
c        call setfhv('B',tloc1,nerr)
c        call wsac0(sacpfx(1:lsacpf)//'.taper',tap,tap,nerr)
c     endif
      call tscopy(s(1+loc1,3),dw,nloc)
      ds = dw(1)
      de = dw(nloc)
      fac = (ds-de)/(1-nloc)
      do i=1,nloc
	 f = de + (i-nloc)*fac
	 dw(i) = (dw(i)-f)*tap(i)
      enddo

c     Shift data for easy FFT and taper noise estimation windows.
      do i=1,3
	 call tscopy(s(1+loc1-nloc,i),dn(1,i),nloc)
	 ds = dn(1,i)
	 de = dn(nloc,i)
	 fac = (ds-de)/(1-nloc)
	 do j=1,nloc
	    f = de + (j-nloc)*fac
	    dn(j,i) = (dn(j,i)-f)*tap(j)
	 enddo
	 call tscopy(s(1+loc1,i),s(1,i),nout)
      enddo

c     Zero-pad and FFT
      nft = npow2(nout)
      nfpts = nft/2 + 1
      fny = 0.5/dt
      delf = 2*fny/nft
      do i=1,3
	 call tszero(s(nout+1,i),nft-nout)
	 call realft(s(1,i),nft,+1)
	 call tscopy(s(1,i),data(1,i),nft)
	 call scalar(data(1,i),nft,dt)
	 call tszero(dn(nloc+1,i),nft-nloc)
	 call realft(dn(1,i),nft,+1)
	 call scalar(dn(1,i),nft,dt)
	 call tscopy(dn(1,i),nois(1,i),nft)
      enddo
      call tszero(dw(nloc+1),nft-nloc)
      call realft(dw,nft,+1)
      call scalar(dw,nft,dt)
      call tscopy(dw,wdata,nft)

c     Compute mod-squared spectra for wavelet d2(.)
      d2(1) = real(wdata(1))**2
      d2(nfpts) = imag(wdata(1))**2
      d2max = max(d2(1),d2(nfpts))
      do j=2,nfpts-1
	 d2(j) = real(wdata(j)*conjg(wdata(j)))
         d2max = max(d2(j),d2max)
      enddo

c     Common debug output file setup
      if (debug) then
         call setnhv('NPTS',nfpts,nerr)
         call setfhv('B',0.0,nerr)
         call setfhv('DELTA',delf,nerr)
      endif

c     Compute squared noise at each frequency dn(.,:)
      do i=1,3
         dn(1,i)=real(nois(1,i))**2
         dn(nfpts,i)=imag(nois(1,i))**2
	 do j=2,nfpts-1
	    dn(j,i) = nois(j,i)*conjg(nois(j,i))
	 enddo
	 if (debug) then
	    tap(1) = real(data(1,i))**2
	    tap(nfpts) = imag(data(1,i))**2
	    do j=2,nfpts-1
	       tap(j) = data(j,i)*conjg(data(j,i))
	    enddo
	    write(line,'(a,1h.,i1.1,a)') sacpfx(1:lsacpf),i,'.spec'
            call setkhv('KCMPNM',rtz(i),nerr)
	    call wsac0(line,tap,tap,nerr)
	 endif
      enddo

c     Estimate "signal" in excess of noise.  Step 1 is to find log mod-squared
c     spectrum for wavelet and noise, then use t-test for significantly
c     different means over a symmetric frequency band of +/- 0.5 Hz.  Prob.
c     of significantly different means is used as indicator of "signal" and
c     "noise", sig(.)
      do i=1,nfpts
	 s(i,1) = log(d2(i))
	 s(i,2) = log(dn(i,3))
      enddo
      np=nint(0.5/delf)
c     nth root of prob is used to stretch range, nth power to boost back
      do i=np+1,nfpts-np
         sig(i) = (
     &      1.-ttest(s(i-np,1),2*np+1,s(i-np,2),2*np+1)**0.05
     &   )**20
      enddo
      do i=0,np-1
         sig(1+i) = sig(np+1)
         sig(nfpts-i) = sig(nfpts-np)
      enddo
c     Find background level where no signal present, and average difference
c     between signal and noise.
      bkg = 0.0
      dif = 0.0
      fac = 0.0
      dis = 0.0
      do i=1,nfpts
         dif = dif + (s(i,1)-s(i,2))*sig(i)
	 dis = dis + sig(i)
         bkg = bkg + s(i,2)*(1-sig(i))
	 fac = fac + (1-sig(i))
      enddo
c     Define water level as background plus average difference between signal
c     and noise.
      bkg = exp(bkg/fac + dif/dis)
      if (debug) then
         write(*,*) 'Background/max. signal is ',bkg/d2max
         call setkhv('KCMPNM','Z',nerr)
         call wsac0(sacpfx(1:lsacpf)//'.wspec',d2,d2,nerr)
         call wsac0(sacpfx(1:lsacpf)//'.nspec',dn(1,3),dn(1,3),nerr)
         call wsac0(sacpfx(1:lsacpf)//'.ratio',sig,sig,nerr)
      endif

c     Deconvolve all components with wavelet.
      read(*,*,iostat=ios) c,agauss,tdelay
      if (ios .ne. 0)
     &     stop '**Invalid trough fill, scale or phase shift.'
      gnorm = 0.d0
      do i=1,3
         k = 3
	 do j=2,nfpts-1
	    freq = (j-1)*delf
	    w = 2*pi*freq
	    phi = max(d2(j),bkg)
	    gauss = -(w/agauss)**2/4.0
	    cval = data(j,i)*conjg(wdata(j)) * exp(gauss) / phi
     &           * exp(cmplx(0.,w*tdelay))
	    if (i .eq. 3) gnorm = gnorm + exp(gauss)
	    s(k,i) = real(cval)
	    s(k+1,i) = imag(cval)
	    k = k + 2
	    tap(j) = phi
	 enddo
	 phi = max(d2(1),bkg)
	 s(1,i) = real(data(1,i))*real(wdata(1)) / phi
	 tap(1) = phi
	 phi = max(d2(nfpts),bkg)
	 w = 2*pi*fny
	 gauss = -(w/agauss)**2/4.0
	 cval = imag(data(1,i))*imag(wdata(1)) * exp(gauss) / phi
     &           * exp(cmplx(0.,w*tdelay))
         s(2,i) = abs(cval)
	 tap(nfpts) = phi
	 if (i .eq. 3) gnorm = gnorm + 1 + exp(gauss)
         call realft(s(1,i),nft,-1)
	 call scalar(s(1,i),nft,2./nft)
      enddo
      if (debug) then
	 call setkhv('KCMPNM','WT',nerr)
         call wsac0(sacpfx(1:lsacpf)//'.spwt',tap,tap,nerr)
      endif

      gnorm = 2*gnorm*delf*dt
      if (gnorm .le. 0.0) gnorm=1.0

      call mxmn(s(1,3),nout,dmin,dmax)
      if (dmax .eq. 0.0) dmax=1.0

c     -1 factor for 1 and 2 components flips them from pointing along baz to
c        pointing along radial direction
c     call scalar(s(1,3),nout,1./gnorm)
      call scalar(s(1,3),nout,1./dmax)
      call scalar(s(1,1),nout,-1./dmax)
      call scalar(s(1,2),nout,-1./dmax)
      call setfhv('SCALE',dmax,nerr)

c     Write output files.
      call setfhv('B',-tdelay,nerr)
      call setnhv('NPTS',nout,nerr)
      call setfhv('delta',dt,nerr)

      call setfhv('O',origin-(tloc1-b),nerr)

      eaz = 180.0 + ebaz
      if (eaz .lt. 0.0) eaz = eaz+360.0
      if (eaz .gt. 360.0) eaz = eaz-360.0
      call setfhv('CMPAZ',eaz,nerr)
      call setfhv('CMPINC',90.0,nerr)
      call setkhv('KCMPNM','eq R',nerr)
      call wsac0(sacpfx(1:lsacpf)//'.eqr',s(1,1),s(1,1),nerr)

      etan = eaz+90.0
      if (etan .gt. 360.0) etan = etan-360.0
      call setfhv('CMPAZ',etan,nerr)
      call setfhv('CMPINC',90.0,nerr)
      call setkhv('KCMPNM','eq T',nerr)
      call wsac0(sacpfx(1:lsacpf)//'.eqt',s(1,2),s(1,2),nerr)

      call setfhv('CMPAZ',0.0,nerr)
      call setfhv('CMPINC',0.0,nerr)
      call setkhv('KCMPNM','eq Z',nerr)
      call wsac0(sacpfx(1:lsacpf)//'.eqz',s(1,3),s(1,3),nerr)

122   format(1x,'***Zero gain found, skipping normalization.')
123   format(1x,'***NEGATIVE GAIN FOUND FOR COMPONENT ',i2,'***')
130   format(1x,'Note:  Components not originally N and E (',
     +     f6.1,',',f6.2,')')

      end

      function npow2(n)
C     npow2 -- Return power of two >= given value
      n2 = 1
      do i=0,n
         if (n2 .ge. n) go to 10
	 n2 = n2*2
      enddo
      pause '**NPOW2:  Integer number to big?!'
10    continue
      npow2 = n2
      end

      subroutine mxmn(a,n,vmin,vmax)
C     mxmn -- Return extremal values of an array
      real a(n)
      vmin = a(1)
      vmax = a(1)
      do i=2,n
	 vmin=min(a(i),vmin)
	 vmax=max(a(i),vmax)
      enddo
      end

      function dtheta(theta1,theta2)
C     dtheta -- Find difference between angles expressed in radians
      dsin = sin(theta1)*cos(theta2) - cos(theta1)*sin(theta2)
      dcos = cos(theta1)*cos(theta2) + sin(theta1)*sin(theta2)
      dtheta = atan2(dsin,dcos)
      end

      function lenstr(str)
C     lenstr -- Return non-blank length of string str.
      character str*(*)
      do i=len(str),1,-1
         if (str(i:i) .ne. ' ') then
	    lenstr = i
	    return
	 endif
      enddo
      lenstr = 1
      end

      subroutine rotcomp(x,y,xrot,yrot,npts,angle)
c     rotate seismograms into coord system xrot,yrot from x, y. Angle
c     assumed to be in radians.  Angle is counter-clockwise angle from
c     the positive x axis in radians
c     the rotation is done so that the same arrays can be used in
c     x,xrot and y,yrot. ei x,y overwritten with xrot,yrot
      dimension x(npts),y(npts),xrot(npts),yrot(npts)
      si=sin(angle)
      co=cos(angle)
      do i=1,npts
         xrot_temp= x(i)*co+y(i)*si
         yrot_temp=-x(i)*si+y(i)*co 
         xrot(i)=xrot_temp
         yrot(i)=yrot_temp
      enddo
      end

      SUBROUTINE ROTSUB(AN,AE,AR,AT,NPTS,BAZ)
c+
c     SUBROUTINE ROTSUB(AN,AE,AR,AT,NPTS,BAZ)
c
c     AN and AE are northsouth and eastwest time series respectively;
c     NPTS = number of points; AR and AT are radial and transverse
c     time series returned from this routine; BAZ is backazimuth
c
c     Subroutine to rotate into radial and transverse components.
c     BAZ is the back-azimuth, that is, the clockwise angle 
c     measured from north to the earthquake with the station as the
c     vertex. The positive radial direction points in the direction of
c     the earthquake from the station. The positive transverse direction
c     is to the left of the radial direction.  This assures a right-handed
c     coordinate system with the z component pointing up. 
c     Note that this convention is not the same as AKI and RICHARDS
c     page 114-115.  They use a coordinate system where Z is down.
c-
      DIMENSION AN(NPTS),AE(NPTS),AR(NPTS),AT(NPTS)
      SI=SIN(BAZ)
      CO=COS(BAZ)
      DO I=1,NPTS
         AR_temp = AE(I)*SI+AN(I)*CO 
	 AT_temp = -(AE(I)*CO-AN(I)*SI)
	 AR(I) = AR_temp 
         AT(I) = AT_temp 
      ENDDO
      END

      subroutine demean(x,n)
      dimension x(n)
      sum = 0.0
      do i=1,n
         sum = sum + x(i)
      enddo
      xbar = sum/max(n,1)
      do i=1,n
         x(i) = x(i) - xbar
      enddo
      end

      subroutine costap(ntap,npts,tap)
c     costap -- symmetric cosine taper of ntap points
      real tap(npts),fac,pih
      pih=2.0*atan(1.0)
      do i=1,ntap
        fac=sin((i-1)*pih/float(ntap-1))
        tap(i)=fac
        tap(npts-i+1)=fac
      enddo
      do i=ntap+1,npts-ntap
         tap(i)=1.0
      enddo
      end
