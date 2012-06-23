C     Deconvolution of Z component from horizontal components, equalized.
C
C     Rewrite of pwaveqn program by Owens/Randall/Ammon to do water-level
C     frequency-domain deconvolution of Z component from horizontal components.
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
C
C     Takes two lines of input:
C        begin time, end time, phase ID
C        water level fraction (0<=c<=1.0), gauss avg. (sec.), phase shift (sec.)
C        
C
C     G. Helffrich/U. Bristol 31 Oct. 2001

      program pwaveqn
      parameter (npow=16,ndim=2**npow, aztol=0.001)
      logical ex
      dimension se(ndim),sn(ndim),s(ndim,3),d2(ndim),dw(ndim)
      complex clag,data(ndim/2,3),wdata(ndim/2)
      equivalence (data,s),(se,d2),(wdata,dw)
      real caz(3),cin(3),cgain(3)
c     integer	iyr, iday, ihr, imin, isec
      integer	npts
      character dnet*4, stn*4, chan*4, line*255
      character scomp(3)*4, sphase*7, sacpfx*128

      pi = 4.0*atan(1.0)
      rad = 180.0/pi

c     Check presence of SAC files.  Read Z component header and fill info
c       from this.
      do i=1,3
        call getarg(i,line)
        inquire (file=line,exist=ex)
        if (.not. ex) then
	  write(0,*) '**',line(1:index(line,' ')),'doesn''t exist,',
     +         'quitting.'
	  stop
        endif
      enddo

c     Prefix to generated SAC file names is SAC file name stripped of its
c       .xxx suffix.  This prefix becomes the header "file" name.
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
	call getarg(icomp,line)
	call rsac1(line,s(1,icomp),npts,beg,dt,ndim,nerr)
	if (nerr .ne. 0) stop '**Trouble reading SAC input file.'
	call getkhv('KCMPNM',scomp(icomp),nerr)
	call getfhv('CMPAZ',caz(icomp),nerr)
	call getfhv('CMPINC',cin(icomp),nerr)
	call getfhv('SCALE',cgain(icomp),nerr)
        if (nerr .ne. 0) cgain(icomp) = 0.0
        if (cgain(icomp) .lt. 0.0) write(*,123) icomp
      enddo
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
      if (loc1 .gt. npts .or. loc2 .gt. npts .or.
     +    loc1 .lt. 1 .or. loc2 .lt. 1) 
     +  stop '**Data file too large, cut smaller.'
      nloc = loc2-loc1+1

c     Rotate to change n-e to r-t time series.  s(i,1)->r, s(i,2)->t
      call tscopy(s(1,1),se,npts)
      call tscopy(s(1,2),sn,npts)
      call rotsub(sn,se,s(1,1),s(1,2),npts,ebaz/rad)

c     Extract deconvolution wavelet.  Subtract line fit through first and
c        last point to remove trend.  Note dw and wdata are
c        same storage, real array overlaying complex one.
      ds = wigint(beg,s(1,3),npts,dt,1e-4,tloc1)
      de = wigint(beg,s(1,3),npts,dt,1e-4,tloc2)
      fac = (ds-de)/(tloc1-tloc2)
      t = tloc1
      do i=1,nloc
	 f = de + (t-tloc2)*fac
	 if (t .le. tloc2) then
	    dw(i) = wigint(beg,s(1,3),npts,dt,1e-4,t) - f
	 else
	    dw(i) = 0.0
	 endif
	 t = t + dt
      enddo

c     Compute stuff for fft
      nft = npow2(npts)
      nfpts = nft/2 + 1
      fny = 0.5/dt
      delf = 2*fny/nft
      cdelf = 1./nft

c     Truncate and pad data if windowed shorter than full data.
      nout = 1 + npts-loc1
      if (loc1 .ne. 0) then
	 do i=1,3
	    call tscopy(s(1+loc1,i),s(1,i),nout)
	 enddo
      endif

c     FFT
      do i=1,3
	 call tszero(s(nout+1,i),nft-nout)
	 call dfftr(s(1,i),nft,'forward',dt)
      enddo
      call tszero(dw(nloc+1),nft-nloc)
      call dfftr(dw,nft,'forward',dt)
      d2max = 0.0
      do j=1,nfpts
	 d2(j) = real(wdata(j)*conjg(wdata(j)))
	 if (d2(j).gt.d2max) d2max=d2(j)
      enddo

c     Set water level and deconvolve horizontals with vertical component.
c     Note that spectral division x/z is done by multiplying numerator and
c        denominator by z*.  Thus x/z = (x z*)/(z z*) and the denominator
c        is real, leading to a simple definition of water level (fraction of
c        max power rather than spectral amplitude).
c     Also deconvolve vertical from itself and compute area under Gaussian
c        filter
      read(*,*,iostat=ios) c,agauss,tdelay
      if (ios .ne. 0)
     &     stop '**Invalid trough fill, scale or phase shift.'
      phi1 = c*d2max
      gnorm = 0.d0
      do i=1,3
	 do j=1,nfpts
	    freq = (j-1)*delf
	    w = 2*pi*freq
	    phi = max(phi1,d2(j))
	    gauss = -(w/agauss)**2/4.0
	    data(j,i) = data(j,i)*conjg(wdata(j)) * exp(gauss)/phi
     &           * exp(cmplx(0.,-w*tdelay))
	    if (i .eq. 3) gnorm = gnorm + exp(gauss)
	 enddo
	 call dfftr(data(1,i),nft,'inverse',cdelf)
      enddo

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
