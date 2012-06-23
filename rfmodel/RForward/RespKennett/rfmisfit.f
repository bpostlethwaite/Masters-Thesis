C     Calculate misfit between an observed receiver function and a synthetic
C     one.  G. Helffrich/19 July 2006, 31 July 2006, 3 Feb. 2008,
C        19 June 2008
C
C     Command line contains two file names:
C        1) the observed trace
C        2) the observed trace's standard deviation, obtained by jackknife.
C        3) (optionally) -df x -- the number of a priori degrees of freedom
C           in the trace (determined by the number of free parameters in the
C           model).
C        4) (optionally) -weight -- use exponential weights to taper chi-squared
C     These files must be the same length and sample rate.  A and F must be
C     set in the observed trace to define the part of the file over which the
C     misfit is calculated.
C
C     Standard input contains a succession of SAC file names which are
C     compared to the observed one and its standard deviation, and the
C     misfit is calculated.  Output is the file name and the misfit value
C     (which is unitless).
C
C     The number of degrees of freedom in the model is independently specified.
C     Because all traces have the same sample rate, and thus total number of
C     samples, we assume a linear relationship between the number of degrees of
C     freedom in the trace (determined by the chi-squared value of the trace
C     relative to a zero trace at the same sample rate) and the number in the
C     model.  This scaling factor is applied to the chi-squared misfit between
C     the trace under test and the target trace to normalize the DFs so that a
C     chi-squared test based on the number of parameters may be made.

      parameter (npmx=2**16, wtcut=0.05)
      character fobs*128, fstd*128, fin*128, file(2)*128
      real dobs(npmx), dstd(npmx), dmis(npmx), wt(npmx)
      double precision dsum,scl
      equivalence (file(1),fobs),(file(2),fstd)
      logical owt
      data owt/.false./

      fobs = ' '
      fstd = ' '
      iskip = 0
      nf = 0
      ndf = 0
      do 10 i=1,iargc()
         if (i.le.iskip) go to 10
	 call getarg(i,fin)
	 if (fin(1:1) .ne. '-') then
	    nf = nf + 1
	    if (nf.le.2) file(i) = fin
	 else
	    if (fin .eq. '-df') then
	       call getarg(i+1,fin)
	       if (fin .eq. ' ') stop '**Missing DF'
	       read(fin,*,iostat=ios) ndf
	       if (ios.ne.0) stop '**Bad DF value'
	       iskip = i+1
	    else if (fin(1:2) .eq. '-w') then
	       owt = .true.
	    else
	       write(0,*) '**Unrecognized parameter: ',
     &            fin(1:index(fin,' '))
            endif
	 endif
10    continue
	    
      if (nf .lt. 2) stop '**Missing observed trace or std. dev.'

      call rsac1(fstd, dstd, n, sbeg, sinc, npmx, nerr)
      if (nerr.ne.0) stop '**Bad std. dev. file'

      call rsac1(fobs, dobs, npobs, dbeg, dinc, npmx, nerr)
      if (nerr.ne.0) stop '**Bad observed trace file'

      if (n .ne. npobs) stop '**Different # points in obs & std. dev.'
      if (dbeg .ne. sbeg) stop '**Different begin in obs & std. dev.'
      if (dinc .ne. sinc)
     &   stop '**Different sample rate in obs & std. dev.'

      call getfhv('A',dpbeg,nerr)
      if (nerr.ne.0) stop '**No A set in trace to define window.'
      call getfhv('F',dpend,nerr)
      if (nerr.ne.0) stop '**No F set in trace to define window.'
      ixbeg = nint((dpbeg-dbeg)/dinc)-1
      npts = 1 + nint((dpend-dpbeg)/dinc)
      if (ixbeg.lt.0 .or. ixbeg+npts.gt.npobs)
     &   stop '**A and F in observed trace beyond file bounds'

      if (owt) then
         slo = -abs(dpbeg)/log(wtcut)
         shi = -abs(dpend)/log(wtcut)
	 wsum = 0
	 do i=1,npts
	    t = (i-1)*(dpend-dpbeg)/(npts-1) + dpbeg
	    if (t .le. 0) then
	       wt(i) = exp(-abs(t)/slo)
	    else
	       wt(i) = exp(-abs(t)/shi)
	    endif
	    wsum = wsum + wt(i)
	 enddo
      else
         wsum = 1
	 do i=1,npts
	    wt(i) = 1.0
	 enddo
      endif

      if (ndf.gt.0) then
	 dsum = 0.0
	 do i=1,npts
	    dsum = dsum + wt(i)*dble(dobs(i+ixbeg)/dstd(i+ixbeg))**2
	 enddo
	 scl = wsum*ndf/dsum
      else
         scl = 1/wsum
      endif

C     Checks worked, now start reading files.

1000  continue
C        Read file name.  If line blank, or begins with # or *, ignore it.
         read(*,'(a)',iostat=ios) fin
	 if (ios.ne.0) stop
	 if (fin .eq. ' ' .or. 0.ne.index('#*',fin(1:1))) go to 1000

C        Get file name length.
	 do i=len(fin),1,-1
	    if (fin(i:i) .ne. ' ') go to 1005
	 enddo
1005     continue
	 ix = i

C        Read file data
         call rsac1(fin, dmis, n, fbeg, finc, npmx, nerr)
	 if (nerr.ne.0) then
	    write(0,*) '**No access to ',fin(1:ix)
	    go to 1000
	 endif

C        Check for file compatibility with observed
	 if (n.lt.npobs .or. abs(fbeg-dbeg).gt.0.1*dinc .or.
     &       abs(dinc-finc)/dinc .gt. 1e-4) then
	    write(0,*) '**Sample rate, point or file begin mismatch of ',
     &         fin(1:ix)
	    go to 1000
	 endif

C        Calculate misfit
         dsum = 0.0
	 do i=1,npts
	    j = i+ixbeg
	    dsum = dsum + wt(i)*dble((dmis(j)-dobs(j))/dstd(j))**2
	 enddo
	 sum = dsum*scl
	 write(*,*) fin(1:ix), sum
	 call flush
      go to 1000
      end
