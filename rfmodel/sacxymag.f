C      Program to read in a SAC XYZ file and magnify regions in it.
C
C      Command line input:
C      -magx [max|value] xlo xhi - Magnify X values between xlo and xhi by
C          either file maximum or factor of value
C      -magy [max|value] ylo yhi - Magnify Y values between ylo and yhi by
C          either file maximum or factor of value
C      -q - Quiet -- no mag factor reports.
C       
C      Options may be repeated with different ranges for more focused mag.
C
C      Reads list of SAC file names from input.
C
C      magx(1,...) is mag value or zero, magx(2,...) and (3,...) is lo and hi
C
C      SAC XYZ files are stored as NXSIZE lines of Y data, each line of length
C      NYSIZE points.  Y is normally time, so is the horizontal axis in plots.
C      However, in terms of the file labelling, the time values stack in the
C      vertical direction, which are successive X values in the file
C      nomenclature.  Thus, in XYZ plots horizontal is Y and vertical is X.
C      This explains some of the odd-looking calls for XMAXIMUM etc. later on.

       parameter (MAXDAT=2**17, MAXMAG=5)
       real magx(3,MAXMAG), magy(3,MAXMAG), data(MAXDAT)
       character inline*64, xy*1, itype*8

       logical ok,verbose,okm
       data nmagx, nmagy /0,0/, verbose/.true./

       iskip = 0
       do i=1,iargc()
	  if (i .le. iskip) cycle
	  call getarg(i,inline)
	  if ('-mag' .eq. inline(1:4)) then
	     xy = inline(5:5)
	     call getarg(i+1,inline)
	     if (inline .eq. 'max') then
	        value = 0.0
	     else
	        read(inline,*,iostat=ios) value
		if (ios.ne.0) stop '**Bad -mag value'
	     endif
	     call getarg(i+2,inline)
	     iskip = index(inline,' ')
	     if (iskip.eq.0) iskip=1
	     call getarg(i+3, inline(iskip+1:))
	     read(inline,*,iostat=ios) vlo,vhi
	     if (vlo.ge.vhi) stop '**Bad -mag value'
	     iskip = i+3
	     if (xy .eq. 'x' .or. xy .eq. 't') then
		nmagx = min(nmagx + 1, maxmag)
		magx(1,nmagx) = value
		magx(2,nmagx) = vlo
		magx(3,nmagx) = vhi
	     else if (xy .eq. 'y' .or. xy .eq. 'p') then
		nmagy = min(nmagy + 1, maxmag)
		magy(1,nmagy) = value
		magy(2,nmagy) = vlo
		magy(3,nmagy) = vhi
	     else
	        stop '**Bad -mag type'
	     endif
	  else if ('-q' .eq. inline(1:2)) then
	     verbose = .false.
	  else
	     ix = index(inline,' ')-1
	     write(0,*) '**Don''t understand "',inline(1:ix),
     &          '", skipping.'
          endif
      enddo

1000  format('**"',a,'" ',a)
100   continue
         read (*,'(a)',iostat=ios) inline
	 if (ios .ne. 0) stop
	 ix = index(inline,' ')-1
	 inquire(file=inline,exist=ok)
	 if (.not.ok) then
	    write(0,*) '**File doesn''t exist, skipping: ',
     &          inline(1:ix)
	    go to 100
	 endif

C        Validate file, size and type.
         call rsach(inline,nerr)
	 if (nerr .ne. 0) then
	    write(0,1000) inline(1:ix),'isn''t a SAC file; skip.'
	    go to 100
	 endif
	 call getnhv('npts',npts,nerr)
	 if (npts.gt.MAXDAT) then
	    write(0,1000) inline(1:ix),'is too big to magnify; skip.'
	    go to 100
	 endif
	 call getihv('iftype',itype,nerr)
	 if (itype.ne.'IXYZ') then
	    write(0,1000) inline(1:ix),'isn''t XYZ file; skip.'
	    go to 100
	 endif
	 call getfhv('xmaximum',xmax,nerr)
	 call getfhv('xminimum',xmin,nerr)
	 call getfhv('ymaximum',ymax,nerr)
	 call getfhv('yminimum',ymin,nerr)
	 call getnhv('nxsize',nx,nerr)
	 call getnhv('nysize',ny,nerr)
	 if ((xmax.le.xmin .or. ymax.le.ymin)
     &       .and. nx*ny.ne.0) then
	    write(0,1000) inline(1:ix),'XYZ data inconsistent; skip.'
            go to 100
	 endif
	 if (nx*ny .le. 0 .or. npts.le.0) go to 100

         call rsac1(inline,data,npts,bt,dt,MAXDAT,nerr)
	 if (nerr.ne.0) stop '**Error reading file.'

C        Get data max/min
         zmax = data(1)
	 zmin = data(1)
	 do i=1, npts
	    value = data(i)
	    if (zmax.lt.value) zmax=value
	    if (zmin.gt.value) zmin=value
	 enddo

C        Magnify as appropriate
	 dx = nx/(xmax-xmin)
         do i=1,nmagx
	    klo = max(0,  int((magx(2,i)-xmin)*dx)) + 1
	    khi = min(nx,nint((magx(3,i)-xmin)*dx))
	    if (klo.gt.nx) cycle
	    value = magx(1,i)
	    if (value.eq.0) then
C              Need maximum?  Find it.
	       value = data(klo)
	       do j=0,ny-1
	          ix = j*nx
	          do k=ix+klo,ix+khi
		     if (value.lt.data(k)) value=data(k)
		  enddo
	       enddo
	       if (value.ne.0) value = zmax/value
	    endif
C           Now have mag. factor, do magnification.
            if (verbose)
     &         write(*,*) 'X mag. factor ',value,' between ',
     &         magx(2,i),' and ',magx(3,i)
	    do j=0,ny-1
	       ix = j*nx
	       do k=ix+klo,ix+khi
		  data(k)=data(k)*value
	       enddo
	    enddo
	 enddo

	 dy = ny/(ymax-ymin)
         do i=1,nmagy
	    klo = max(0,   int((magy(2,i)-ymin)*dy))
	    khi = min(ny-1,int((magy(3,i)-ymin)*dy))
	    if (klo.ge.ny) cycle
	    value = magy(1,i)
	    if (value.eq.0) then
C              Need maximum?  Find it.
	       value = data(1+klo*nx)
	       do j=klo,khi
	          ix = j*nx
	          do k=ix+1,ix+nx
		     if (value.lt.data(k)) value=data(k)
		  enddo
	       enddo
	       if (value.ne.0) value = zmax/value
	    endif
C           Now have mag. factor, do magnification.
            if (verbose)
     &         write(*,*) 'Y mag. factor ',value,' between ',
     &         magy(2,i),' and ',magy(3,i)
	    do j=klo,khi
	       ix = j*nx
	       do k=ix+1,ix+nx
		  data(k)=data(k)*value
	       enddo
	    enddo
	 enddo

         call wsac0(inline,data,data,nerr)
	 if (nerr.ne.0) then
	    ix = index(inline,' ')
	    write(0,1000) inline(1:ix),':  Problem rewriting file.'
         endif
      go to 100
      end
