C     Stack the data in a collection of SAC files, aligning to a specified time
C     in each.  All files must have the same sample rate.
C
C     Input:
C        Command line has file name for output.
C        -xlim xlo xhi - Relative time window to stack during.
C        -range xlo xhi - Synonym for -xlim.
C        -norm - normalize stack to polarity and unit magnitude at zero offset
C        -envelope - output envelope function of stack.
C        -taper x - cosine taper first and last x seconds of each signal.
C        -blip - subtract 95% confidence from stacked signal.  If negative,
C            force to zero.  Otherwise plot it.  Shows where action is occurring
C            in the trace.
C        -chop - Like blip, but instead of subtracting the 95% confidence level,
C            force the signal to be zero where it is within the bounds.
C        -slow [[ph x | hdr y [ s/deg | s/km ]]] - stack is a slowness stack,
C            not a distance stack.  Slowness specified by either a phase name in
C            a particular header variable (ph KA is typical for phase name in
C            KA), or an explicit slowness in a header variable (hdr USER0 for
C            example), with option units (default s/deg). The
C            horizontal slowness for the becomes the trace's effective distance.
C            Then stacking proceeds normally using relative time deviations
C            from the reference slowness.  If no 'ph' or 'hd' follows -slow,
C            then ph KA is assumed.
C        -ref phase {distance} - Define reference phase and optional distance.
C            Needed for relative slowness calculation for slant stack time
C            shifts.  If distance not given, it is calculated from the data.
C            If reference phase is A/B (e.g. P/PcP), then the alignment time
C            is the A arrival time, but it is shifted in time to the alignment
C            time of phase B.  Thus you can have stacked slownesses and times
C            relative to B even though you picked phase A.
C        -model x - Use model x for reference rather than default.  Only of use
C            if -ref A/B used (to get relative travel times of B and A).
C        -radius n - Averaging length to compute reference distance.  This
C            downweights clusters of stations within the specified distance
C            to give more faithful representation of average distance.
C        -slant low high inc - Define slant stack parameters
C        -nthroot n - Define slant stack parameters
C        -phasweeight n - Define phase weighted stack parameters
C        -picture [sac] - Dump resulting stack to named file, don't write
C            a series of SAC files.  If 'sac' present, write a SAC XYZ file.
C        -magt [max|x] tlo thi - Magnify amplitude by x (or max) between
C            tlo and thi.  May be given more than once.
C        -debug - write picture output in human-readable form
C        -info - write out distance info for each trace
C  
C     Std input has list of file names, alignment times (relative to file zero),
C     and normalization factor.
      parameter (np2=17,nmax=2**np2,nsmax=2*32768,nfmax=800,clfac=2.0)
      parameter (ntt=32, nmmagt=5)
      real data(nmax),stack(nsmax),sumsq(nsmax)
      real sdata(nsmax,nfmax), hdata(nsmax,nfmax), dref(nfmax)
      real st0(nfmax), sx0(nfmax), slat(nfmax), slon(nfmax)
      real tt(ntt), dtdd(ntt), dtdh(ntt)
      real magtlo(nmmagt), magthi(nmmagt), magtv(nmmagt)
      integer ndat(nsmax)
      complex ci,phssum(nsmax)
      parameter (ntmax=3)
      character sacfile*128, arg*128, token(ntmax)*128, pref*8
      character fname(nfmax)*128, idphs(ntt)*8, trcid*16
      character sltp*2, slhv*8
      equivalence (stack,fname)
      equivalence (slat(1),data(1)),(slon(1),data(nfmax+1))
      logical gnum, onorm, oblip, odebug, opic, oenv, ochop, oinfo
      logical oalign, oslow, opws, opsf, otap
      data onorm /.false./, oblip /.false./, odebug /.false./
      data opic /.false./, oenv /.false./, ochop /.false./
      data oinfo /.false./, oalign /.false./, oslow /.false./
      data opws /.false./, opsf /.false./, otap/.false./
      data slo, shi, sin /0.,0.,1./, eps/0.0/, ci/(0.0,1.0)/
      data nmagt/0/, sfac/1/

C     if (len(fname(1))*nfmax/4 .gt. nsmax)
C    &   pause '**equivalence (stack,frame) problem.'
      if (nfmax .gt. 2*nmax) pause '**equivalence (slat,data) problem.'

C     Read data files and parameters.
C     call ieeeset('environment')
      pi = 4.0*atan(1.0)
      hpi = pi/2
      sacfile = ' '
      pref = ' '
      shift = 0.0
      root = 1.0
      iskip = 0
      delref = 0.0
      do 5 i=1,iargc()
	 if (i .le. iskip) go to 5
	 call getarg(i,arg)
	 if (arg(1:1) .ne. '-') then
	    sacfile = arg
	 else if (arg .eq. '-range' .or. arg .eq. '-xlim') then
	    call getarg(i+1,arg)
	    if (gnum(arg,xlo,'shift value')) stop
	    call getarg(i+2,arg)
	    if (gnum(arg,xhi,'shift value')) stop
	    iskip = i+2
	    if (xlo .ge. xhi) stop '**-xlim/-range lo value > high?'
	 else if (arg .eq. '-magt') then
	    nmagt = min(nmmagt,nmagt+1)
	    call getarg(i+1,arg)
	    if (arg .eq. 'max') then
	       magtv(nmagt) = 0.0
	    else
	       if (gnum(arg,magtv(nmagt),'mag value')) stop
	    endif
	    call getarg(i+2,arg)
	    if (gnum(arg,magtlo(nmagt),'low mag value')) stop
	    call getarg(i+3,arg)
	    if (gnum(arg,magthi(nmagt),'high mag value')) stop
	    iskip = i+3
	 else if (arg .eq. '-nthroot') then
	    call getarg(i+1,arg)
	    if (gnum(arg,root,'nthroot value')) stop
	    iskip = i+1
	    opws = .false.
	 else if (arg(1:3) .eq. '-ph') then
	    call getarg(i+1,arg)
	    if (gnum(arg,root,'phaseweighted value')) stop
	    iskip = i+1
	    opws = .true.
	 else if (arg(1:4) .eq. '-tap') then
	    call getarg(i+1,arg)
	    if (gnum(arg,ttap,'taper value')) stop
	    iskip = i+1
	    otap = .true.
	 else if (arg .eq. '-ref') then
	    call getarg(i+1,pref)
	    iskip = i+1
	    call getarg(i+2,arg)
	    if (arg(1:1) .ne. '-') then
	       if (gnum(arg,delref,'reference distance')) stop
	       iskip = i+2
	       call getarg(i+3,arg)
	       if (arg(1:1) .ne. '-') then
		  if (gnum(arg,alat,'reference depth')) stop
		  iskip = i+3
	       endif
	    endif
	 else if (arg .eq. '-model') then
	    call getarg(i+1,arg)
	    call tpmod(arg)
	    iskip = i+1
	 else if (arg .eq. '-radius') then
	    call getarg(i+1,arg)
	    if (gnum(arg,radius,'avg. radius')) stop
	    iskip = i+1
	 else if (arg .eq. '-slant') then
	    call getarg(i+1,arg)
	    if (gnum(arg,slo,'stacking parameters')) stop
	    call getarg(i+2,arg)
	    if (gnum(arg,shi,'stacking parameters')) stop
	    call getarg(i+3,arg)
	    if (gnum(arg,sin,'stacking parameters')) stop
	    iskip = i+3
	 else if (arg .eq. '-slow') then
	    oslow = .true.
	    call getarg(i+1,arg)
	    if (arg(1:2) .eq. 'ph' .or. arg(1:2) .eq. 'hd') then
	       sltp = arg
	       call getarg(i+2,slhv)
	       iskip = i+2
	       call getarg(i+3,arg)
	       if (arg.eq.'s/km' .or. arg.eq.'s/deg') then
	          iskip = i+3
		  if (arg.eq.'s/km') sfac = 111.1949
	       endif
	    else
	       sltp = 'ph'
	       slhv = 'ka'
	    endif
	 else if (arg .eq. '-norm') then
	    onorm = .true.
	 else if (arg .eq. '-info') then
	    oinfo = .true.
	 else if (arg .eq. '-blip') then
	    oblip = .true.
	 else if (arg .eq. '-chop') then
	    oblip = .true.
	    ochop = .true.
	 else if (arg .eq. '-debug') then
	    odebug = .true.
	 else if (arg .eq. '-picture') then
	    opic = .true.
	    call getarg(i+1,arg)
	    if (arg(1:1) .ne. '-') then
	       iskip = i+1
	       opsf = arg .eq. 'sac'
	    endif
	 else if (arg .eq. '-envelope') then
	    oenv = .true.
	 else
	    write(0,*) '**Unrecognized: ',arg(1:index(arg,' '))
	 endif
5     continue
      if (sacfile .eq. ' ') stop '**No output file given.'
      if (pref .eq. ' ' .and. .not.oslow)
     &   stop '**No reference phase given.'
      rooti = 1.0/root
      ixpref = index(pref,'/')
      if (ixpref .ne. 0) oalign = .true.

C     Now have output file, start reading values.
      ixdmx = 1
      ixdmn = 1
      n = 0
100   continue
	 read(5,'(a)',iostat=ios) arg
	 if (ios .ne. 0) go to 159
	 if (arg(1:1) .eq. '*') go to 100
	 call tokens(arg,ntmax,nt,token)
	 if (nt .ne. ntmax) then
	    write(0,*) '**Missing info in input.'
	    go to 100
	 endif
	 read(token(2),*,iostat=ios) t0
	 if (ios .ne. 0) then
	    write(0,*) '**Missing info in input.'
	    go to 100
	 endif
	 read(token(3),*,iostat=ios) x0
	 if (ios .ne. 0) then
	    write(0,*) '**Missing normalization in input.'
	    go to 100
	 endif
         call rsach(token(1),nerr)
C        Read max zero data points to as to read just the header
C        call rsac1(token(1),data,npts,d0,dt,0,nerr)
	 if (nerr .ne. 0) go to 100
	 call getfhv('DELTA',dt,nerr)
	 if (n .ge. nfmax) then
	    write(0,*) '**Too many data files, max ',nfmax,
     +         ', skipping rest.'
            go to 159
	 endif
	 n = n + 1
	 fname(n) = token(1)
	 if (n .eq. 1) then
C           First file - compute number of points, etc.  Get event lat & lon
	    dtfiles = dt
	    call getfhv('EVLA',elat,nerr)
	    call getfhv('EVLO',elon,nerr)
	    call getfhv('EVDP',edep,nerr)
	 endif
	 if (abs(dt-dtfiles) .gt. 1e-6)
     +      stop '**Files don''t have same sample rate.'

C        Get parameters for slant stacking.  Remember shortest and longest
C           distance.
	 call getfhv('GCARC',dref(n),nerr)
	 if (dref(n) .gt. dref(ixdmx)) ixdmx = n
	 if (dref(n) .lt. dref(ixdmn)) ixdmn = n

	 call getfhv('STLA',slat(n),nerr)
	 call getfhv('STLO',slon(n),nerr)

C        Check for alignment to later phase
         if (oalign) then
	    ixpr = 0
	    ixpa = 0
	    np = mtptt('all',dref(n),edep,ntt,idphs,tt,dtdd,dtdh)
	    do i=1,min(np,ntt)
	       if (idphs(i) .eq. pref(1:ixpref-1)) ixpr=i
	       if (idphs(i) .eq. pref(ixpref+1:)) ixpa=i
	    enddo
	    if (ixpr .eq. 0 .or. ixpa .eq. 0) then
	       write(0,*) '**No ',pref(1:nblen(pref)),' at ',dref(n),
     &          ' degrees, skipping file.'
               n = n - 1
	       go to 100
	    endif
	    t0 = t0 + tt(ixpa)-tt(ixpr)
	 else if (oslow) then
	    if (sltp .eq. 'ph') then
	       call getkhv(slhv,arg,nerr)
	       if (nerr .ne. 0) then
	          write(0,*) '**No phase ID in ',slhv(1:nblen(slhv)),
     &               ', skipping file.'
	          n = n - 1
	          go to 100
	       endif
	       np = mtptt('all',dref(n),edep,ntt,idphs,tt,dtdd,dtdh)
	       ixpr = 0
	       do i=1,min(np,ntt)
	          if (idphs(i) .eq. arg) ixpr=i
	       enddo
	       if (ixpr .eq. 0) then
	          write(0,*) '**No reference phase ',arg(1:nblen(arg)),
     &               ' at ',dref(n),', skipping file.'
	          n = n - 1
	          go to 100
	       endif
	       dref(n) = dtdd(ixpr)
	    else if (sltp .eq. 'hd') then
	       call getfhv(slhv,dref(n),nerr)
	       if (nerr .ne. 0) then
	          write(0,*) '**No slowness in ',slhv(1:nblen(slhv)),
     &               ', skipping file.'
                  n = n - 1
		  go to 100
	       endif
	       dref(n) = sfac*dref(n)
	    else
	       pause '**Bad -slow logic'
	    endif
	 endif
	 st0(n) = t0
	 sx0(n) = x0
	 sumsq(n) = 0.0
      go to 100

159   continue
      if (delref .eq. 0.0) call gmean(n,sumsq,dref,radius,alat,delref)
      if (oinfo) write(6,*) 'Sample rate: ',dtfiles
      call gmean(n,slat,slon,radius,alat,alon)
      if (oslow) then
	 write(6,*) 'Array ref. slowness: ',delref/sfac
	 slo=slo*sfac
	 shi=shi*sfac
	 sin=sin*sfac
      else
	 write(6,*) 'Array ref. delta: ',delref,' center: ',alat,alon
      endif

C     Compute amount of shifting resulting from maximum slowness
C     excursion.  This is so that we don't lose data at ends of each trace.
C     delspn = max(abs(shi),abs(slo))*(dref(ixdmx)-dref(ixdmn))
      delspn = max(
     &   abs(slo*(dref(ixdmn)-delref)),
     &   abs(slo*(dref(ixdmx)-delref)),
     &   abs(shi*(dref(ixdmn)-delref)),
     &   abs(shi*(dref(ixdmx)-delref))
     &)
      stxlo = xlo - delspn
      stxhi = xhi + delspn
      nstack = 1 + (xhi-xlo)/dt
      nssave = 1 + (stxhi-stxlo)/dt
      if (nssave .gt. nsmax) then
	 write(0,*) '**Window too large: max is ',nsmax,', ',
     &      nssave,' needed.'
	 stop
      endif
      nstot = nint((shi-slo)/sin)
      if (opic .and. opsf) then
         npts = (1+nstot)*nstack
	 if (npts .gt. nmax)
     &      stop '**Too much data to write SAC XYZ file.'
      endif

C     Load trace arrays with time window of interest.
      do 190 j=1,n
	 arg = ' '
	 call rsac1(fname(j),data,npts,d0,dt,nmax,nerr)
	 if (onorm .and. sx0(j) .eq. 0.0) then
	    write(0,*) '**',fname(j)(1:index(fname(j),' ')),
     +            'is zero at its normalization point, unnormalized.'
	    x0 = 1.0
	 endif
	 if (.not. onorm) then
	    x0 = 1.0
	 else
	    x0 = sx0(j)
	 endif
	 d0 = d0 - st0(j)
         dn = d0+(npts-1)*dt
	 t = stxlo
	 do 170 i=1,nssave
	    if (t .ge. d0 .and. t .le. dn) then
C              Save data for later.  Taper if necessary.
	       sdata(i,j) = wigint(d0,data,npts,dt,eps,t)/x0
	       if (otap) then
	          if (t-d0.lt.ttap) then
		     sdata(i,j) = sdata(i,j)*cos(hpi*(1-(t-d0)/ttap))
		  endif
	          if (dn-t.lt.ttap) then
		     sdata(i,j) = sdata(i,j)*cos(hpi*(1-(dn-t)/ttap))
		  endif
	       endif
	    else
	       sdata(i,j) = 0.0
	       arg = '**TRUNCATED**'
	    endif
	    t = t + dt
170      continue
	 if (opws) call hilbtf(sdata(1,j),hdata(1,j),nssave,nsmax)
         if (oinfo) then
	    write(6,*) 'File: ',fname(j)(1:nblen(fname(j))),' ',
     +         arg(1:nblen(arg))
	    write(6,*) '  ref time, amp: ',st0(j),',',sx0(j),
     +         ', delta ',dref(j)
	 endif
190   continue

C     Compute succession of slant stacks in desired range.
500   continue
      do 200 nslow=0,nstot
	 rs = slo + nslow*sin
C        Clear accumulators
	 do 205 i=1,nstack
	    stack(i) = 0.0
	    phssum(i) = 0.0
	    sumsq(i) = 0.0
	    ndat(i) = 0
205      continue
C        Run over stored data, shifting by relative values
	 do 210 i=1,n
	    so = rs*(delref-dref(i))
C           ix0 = nint(so/dt) + 1
	    do 220 j=1,nstack
C              ixs = ix0+j-1
	       t = xlo - so + (j-1)*dt
	       if (t .ge. stxlo .and. t .le. stxhi) then
C		  pt = sdata(ixs,i)
                  pt = wigint(stxlo,sdata(1,i),nssave,dt,eps,t)
		  if (opws) then
		     ht = wigint(stxlo,hdata(1,i),nssave,dt,eps,t)
	             phssum(j) = phssum(j) + exp(ci*atan2(ht,pt))
		  else
		     if (root .ne. 1.0) pt = sign(abs(pt)**rooti,pt)
		  endif
		  ndat(j) = ndat(j) + 1
		  stack(j) = stack(j) + pt
		  sumsq(j) = sumsq(j) + pt**2
	       endif
220         continue
210      continue

C        Stacking done.  Now compute statistics.
	 do 230 i=1,nstack
	    j = max(ndat(i),1)
	    if (opws) then
C              ***This treatment does not lead to proper defn. for sigma***
	       fac = abs(phssum(i)/j)**root
	       xbar = fac*stack(i)/j
	    else if (root .ne. 1.0) then
C              ***This treatment does not lead to proper defn. for sigma***
               stack(i) = sign((stack(i)/j)**root,stack(i))
	       xbar = stack(i)
	    else
	       xbar = stack(i)/j
	    endif
	    conf = clfac*sqrt(max(0.,
     +         ((sumsq(i) - xbar*stack(i))/j + xbar**2)/max(j-1,1))
     +      )
	    stack(i) = xbar
	    sumsq(i) = conf
	    if (oblip) stack(i) = blip(xbar,conf,ochop)
230      continue
	 if (oenv) call tsenv(nstack,stack)

C        Write mean trace or slant stack slowness-by-slowness
         if (opic) then
	    if (nslow .eq. 0) then
C              First 
               if (odebug) then
		  open(7,file=sacfile,form='FORMATTED')
		  write(7,*) nstot+1,nstack,xlo,xhi,dt,delref,' ',pref
	       else
		  open(7,file=sacfile,form='UNFORMATTED')
		  write(7) nstot+1,nstack,xlo,xhi,dt,delref,pref
	       endif
	    endif
	    if (odebug) then
	       write(7,*) rs,(stack(i),i=1,nstack)
	    else
	       write(7) rs,(stack(i),i=1,nstack)
	    endif
	 else
	    ix = index(sacfile,' ')-1
	    write(arg,'(a,i3.3)') '.',nslow
	    if (nslow .eq. 0) arg = ' '
	    ixa = max(1,index(arg,' ')-1)
	    ixp = max(1,index(pref,' ')-1)
	    if (opws) then
	       write(trcid,'(a,1x,a,i2)') pref(1:ixp),'PWS',int(root)
	    else
	       write(trcid,'(a,1x,a,i2)') pref(1:ixp),'Nth',int(root)
	    endif
	    call newhdr
	    call setnhv('NPTS',nstack,nerr)
	    call setfhv('B',xlo,nerr)
	    call setfhv('DELTA',dtfiles,nerr)
	    call setkhv('KSTNM','STACK',nerr)
	    if (.not.oslow) then
	       call setkhv('KEVNM',trcid,nerr)
	       call setfhv('STLA',alat,nerr)
	       call setfhv('STLO',alon,nerr)
	       call setfhv('EVLA',elat,nerr)
	       call setfhv('EVLO',elon,nerr)
	       call setfhv('EVDP',edep,nerr)
	    endif
	    call setfhv('USER0',rs,nerr)
	    call wsac0(sacfile(1:ix)//arg(1:ixa),
     +              stack,stack,nerr)

C           Write 95% confidence trace
	    call wsac0(sacfile(1:ix)//'.conf'//arg(1:ixa),
     +              sumsq,sumsq,nerr)

C           Write phase stack if used
            if (opws) then
	       do i=1,nstack
		  sumsq(i) = abs(phssum(i)/max(ndat(i),1))**root
	       enddo
	       call wsac0(sacfile(1:ix)//'.phs'//arg(1:ixa),
     +              sumsq,sumsq,nerr)
	    endif
	 endif
200   continue

      if (opic .and. opsf) then
         npts = (1+nstot)*nstack
         rewind(7)
	 if (odebug) then
	    read(7,*) i,i,xlo,xhi,dt,delref,trcid(1:len(pref))
	    do j=0,nstot
	       read(7,*) rs,(data(i+j*nstack),i=1,nstack)
	    enddo
	 else
	    read(7) i,i,xlo,xhi,dt,delref,trcid(1:len(pref))
	    do j=0,nstot
	       read(7) rs,(data(i+j*nstack),i=1,nstack)
	    enddo
	 endif
	 t = 0.0
	 do i=1,npts
	    x0 = data(i)
	    if (x0 .gt. t) t = x0
	 enddo
	 close(7)
	 do i=1,nmagt
	    ixlo = 1 + max(0,nint((magtlo(i)-xlo)/dt))
	    ixhi = 1 + min(nstack-1,nint((magthi(i)-xlo)/dt))
	    if (ixlo .lt. ixhi) then
	       if (magtv(i) .eq. 0) then
C                 Find maximum
                  sum = 0.0
		  do j=0,nstot
		     do k=ixlo,ixhi
			x0 = data(k+j*nstack)
			if (x0 .gt. sum) sum = x0
		     enddo
		  enddo
		  if (sum.ne.0) magtv(i) = t/sum
		  do j=0,nstot
		     do k=ixlo,ixhi
			x0 = data(k+j*nstack)
			data(k+j*nstack) = x0*magtv(i)
		     enddo
		  enddo
	       endif
	    else
	       magtv(i) = 0.0
	    endif
	    write(*,*) 'Mag. factor ',magtv(i),' between ',magtlo(i),
     &                 ' and ',magthi(i)
	 enddo
	 call newhdr
	 call setnhv('NPTS',npts,nerr)
	 call setfhv('B',0.0,nerr)
	 call setfhv('DELTA',1.0,nerr)
	 call setihv('IFTYPE','IXYZ',nerr)
	 call setnhv('NXSIZE',nstack,nerr)
	 call setnhv('NYSIZE',1+nstot,nerr)
	 call setfhv('XMINIMUM',xlo,nerr)
	 call setfhv('XMAXIMUM',xhi,nerr)
	 call setfhv('YMINIMUM',slo/sfac,nerr)
	 call setfhv('YMAXIMUM',shi/sfac,nerr)
	 call wsac0(sacfile,data,data,nerr)
      else if (opic) then
         close(7)
      endif
      end

      function blip(val,sigma,chop)
C     Returned signed difference between value and standard deviation
      logical chop
      diff = abs(val) - sigma
      if (diff .ge. 0.0) then
	 if (chop) then
	    blip = val
	 else
	    blip = sign(diff,val)
	 endif
      else
	 blip = 0.0
      endif
      end

      function nblen(string)
      character string*(*)
      do 10 i=len(string),1,-1
	 if (string(i:i) .ne. ' ') go to 19
10    continue
      i = 1
19    continue
      nblen = i
      end
