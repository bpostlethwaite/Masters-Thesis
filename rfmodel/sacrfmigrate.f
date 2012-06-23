C     Migrate a collection of SAC receiver function depth-o-grams.  Will make
C     a single migrated trace, or a suite of traces aligned on a transect.
C        G. Helffrich/U. Bristol, March 2003.
C        updated Aug. 1, 2008.
C
C     Input:
C        Command line has file name prefix for output.  If summing into a
C        single trace, this is the output file.  If -sect given, successive
C        sections will be numbered numbered xxxx001 xxxx002, etc.
C        -model x - Use model x for reference rather than default.
C           Choices: ak135, fakeprem, iasp91, sp6.
C        -sect lat lon az lodist hidist count - section specification.
C           Count sections along azimuth az from lat lon between distance lodist
C           and hidist.
C        -slow [phase xx | hdr yy] - Determine trace slowness from the phase
C           name in header variable xx and the event information in the header.
C           Alternately, take slowness from header variable yy.
C        -units [degrees|km] - range units (degrees default).
C        -traces [depth dz|time dt] - give type of trace (either "depth" or
C           "time" and migration increment dz or dt.
C        -ref x - reference slowness (s/deg) for stack
C        -jack - Calculate jackknife standard error rather than algebraic.
C        -phaseweight x - phase weighted stack, power x.
C        -debug - write debugging information
C        -info - write out distance info for each trace
C        -dumpwt x - dump weights for each trace at time/depth x
C        -range x - Value of exponential decay constant for range weighting
C        -type [PS|SP] - default is PS for P-to-S conversion, but can also be
C           SP for S-to-P conversion.
C  
C     Std input has list of file names.
C
C     If a record section is output, each trace's lat and lon are set to the
C     position along the cross section, and GCARC from the fixed point of the
C     section.  KSTNM is the numerical distance along the section. EVLA and
C     EVLO are the fixed point of the section.
C
C     This program uses some strategies to speed computation of piercing
C     points for the receiver functions.  Firstly, the range of slownesses
C     represented by the collection of traces is determined, and for every
C     integral slowness in the range, a set of distance vs depth curves is
C     calculated.  To determine the value for a particular slowness, this
C     table is interpolated through to get delta(z).  For combining
C     depth-o-grams, this is all that needs to be done.
C
C     Combining seismograms is hard, because of the nontrivial relation between
C     depth and time, which is governed by slowness.  The strategy followed
C     here is to calculate the lag for a Ps conversion at the reference
C     slowness.  This defines a time base that relates time to depth z(t).
C     For every time in a seismogram, the reference-slowness z is calculated
C     for that t.  This z is used with delta(z) to determine the range from a
C     station for weighting.  Next, the t(z) for the slowness of that trace is
C     calculated to obtain the sample at the correct time for the trace.
C
C     The reference slowness z(t) is calculated only once.  The t(z) is
C     calculated for each trace at relative coarse increments (5 km; see dzt)
C     and interpolated for each sample point.

      parameter (Re=6371.0)
      parameter (np2=15,nmax=2**np2,nsmax=2*8192,nfmax=2000,slth=6.0)
      real data(nmax), hdata(nmax)
      real dref(nfmax), slat(nfmax), slon(nfmax), sbaz(nfmax)
      real slow(nfmax)
      character fname(nfmax)*64
      parameter (ntt=20)
      real tt(ntt), dtdd(ntt), dtdh(ntt)
      character idphs(ntt)*8
      parameter (nsmx=15,nzmx=1801)
      real tabz(nzmx), tabt(nzmx), tabdel(nsmx,nzmx), tabtim(nsmx,nzmx)
      real tz(nzmx), tp(nsmx), zref(nzmx)
      real sdata(nzmx,nfmax), shlbt(nzmx,nfmax)
      real vel(2), del(2), tim(2), tmp(nzmx)
      character sacfile*128, arg*128, stnm*5, sltp*2, slhv*8
      complex pwsum
      logical gnum, odebug, oinfo, opws, okm, oxt, oslow, ojack, odwt
      logical orep
      data odebug, oinfo, opws, okm, oxt, oslow, ojack /7*.false./
      data odwt /.false./
      data tlat, tlon /2*0./, dello, delhi, eps /3*0.0/, nsect/0/
      data rngwt/50.0/, ops/1/, dx/1.0/, dzt/5.0/, pref/0.0/

C     Read data files and parameters.
      pi = 4.0*atan(1.0)
      degr = 180.0/pi
      degkm = Re/degr
      mix = 2
      stnm = ' '
      sacfile = ' '
      iskip = 0
      do 5 i=1,iargc()
	 if (i .le. iskip) go to 5
	 call getarg(i,arg)
	 if (arg .eq. '-model') then
	    call getarg(i+1,arg)
	    call tpmod(arg)
	    mix = index('fakak1iassp6',arg(1:3))-1
	    if (mix.lt.0) stop '**Bad model'
	    mix = 1 + mix/3
	    iskip = i+1
	 else if (arg(1:5) .eq. '-sect') then
	    call getarg(i+1,arg)
	    if (gnum(arg,tlat0,'section lat/lon')) stop
	    call getarg(i+2,arg)
	    if (gnum(arg,tlon0,'section lat/lon')) stop
	    call getarg(i+3,arg)
	    if (gnum(arg,taz,'section azimuth')) stop
	    call getarg(i+4,arg)
	    if (gnum(arg,dello,'section low/high range')) stop
	    call getarg(i+5,arg)
	    if (gnum(arg,delhi,'section low/high range')) stop
	    call getarg(i+6,arg)
	    if (gnum(arg,temp,'section count')) stop
	    nsect = nint(temp)
	    iskip = i+6
	 else if (arg .eq. '-slow') then
	    oslow = .true.
	    call getarg(i+1,sltp)
	    call getarg(i+2,slhv)
	    iskip = i+2
	 else if (arg .eq. '-traces') then
	    call getarg(i+1,arg)
	    ix = index('deti',arg(1:2))-1
	    if (ix.lt.0) stop '**Bad -traces value:  Use depth or time'
	    oxt = ix .gt. 1
	    call getarg(i+2,arg)
	    if (gnum(arg,dx,'-traces increment')) stop
	    iskip = i+2
	 else if (arg .eq. '-units') then
	    call getarg(i+1,arg)
	    ix = index('dekm',arg(1:2))-1
	    if (ix.lt.0) stop '**Bad -units value:  Use deg or km'
	    okm = ix .gt. 1
	    iskip = i+1
	 else if (arg(1:6) .eq. '-phase') then
	    call getarg(i+1,arg)
	    if (gnum(arg,root,'phaseweight power')) stop
	    opws = .true.
	    iskip = i+1
	 else if (arg .eq. '-range') then
	    call getarg(i+1,arg)
	    if (gnum(arg,rngwt,'range weight')) stop
	    iskip = i+1
	 else if (arg(1:4) .eq. '-ref') then
	    call getarg(i+1,arg)
	    if (gnum(arg,pref,'reference slowness')) stop
	    iskip = i+1
	 else if (arg .eq. '-type') then
	    call getarg(i+1,arg)
	    ops = index('psPSSPsp',arg(1:2))-1
	    if (ops.lt.0) stop '**Bad -type value:  Use PS or SP'
	    ops = ops/2
	    iskip = i+1
	 else if (arg .eq. '-jack') then
	    ojack = .true.
	 else if (arg .eq. '-info') then
	    oinfo = .true.
	 else if (arg .eq. '-debug') then
	    odebug = .true.
	 else if (arg .eq. '-dumpwt') then
	    odwt = .true.
	    call getarg(i+1,arg)
	    if (gnum(arg,wtz,'weight depth')) stop
	    iskip = i+1
	 else if (arg(1:1) .ne. '-' .and. sacfile .eq. ' ') then
	    sacfile = arg
	 else
	    write(0,*) '**Unrecognized: ',arg(1:nblen(arg))
	 endif
5     continue
      if (sacfile .eq. ' ') stop '**No output file/prefix given.'
      if (oinfo) write(*,*) 'Weighting decay constant ',rngwt,'km.'
      if (okm) then
         dello = dello/degkm
         delhi = delhi/degkm
      endif
      if (.not. oslow) then
         sltp = 'ph'
         if (ops .eq. 1) then
	    slhv = 'ka'
	 else
	    slhv = 'kt0'
	 endif
      endif

C     Form reference slowness lag table
      if (oxt) then
	 ix = 1 + mod(ops,2)
         tabz(1) = 0.0
         tabt(1) = 0.0
	 nzt = min(nzmx,1+int(750.0/dzt))
         do i=2,nzt
	    r = 1-tabz(i)/Re
	    tabz(i) = (i-1)*dzt
	    arg = 'PS'
	    do k=1,2
	       del(k) = pmatch(arg(k:k),pref,tabz(i),tim(k))
	    enddo
	    tabt(i) = tim(ix) - tim(ops) + pref*(del(ops)-del(ix))
	 enddo
         if (odebug) then
	    call newhdr
	    call setihv('iftype','ixy',nerr)
	    call setnhv('npts',nzt,nerr)
	    call setlhv('leven',.false.,nerr)
	    call wsac0('/tmp/ztable',tabz,tabt,nerr)
	 endif
         nz = min(nzmx, nint(tabt(nzt)/dx + 10/dx))
	 nb = nint(10/dx)
	 xbeg = -10
	 do i=1,nz
	    ti = xbeg + (i-1)*dx
	    zref(i) = wigint(tabt,tabz,nzt,0.0,eps,abs(ti))
	 enddo
         if (odebug) then
	    call newhdr
	    call wsac1('/tmp/zttable',zref,nz,xbeg,dx,nerr)
	 endif
      else
	 nzt = min(nzmx,1+int(750.0/dzt))
	 do i=1,nzt
	    tabz(i) = (i-1)*dzt
	 enddo
         nz = min(nzmx, nint(100/dx + 750/dx))
	 nb = nint(100/dx)
	 xbeg = -100
      endif

C     Start reading list of file names and extract relevant information.
      n = 0
      ixlo = 1
      ixhi = 1
100   continue
	 read(5,'(a)',iostat=ios) arg
	 if (ios .ne. 0) go to 200
	 if (arg(1:1) .eq. '*') go to 100
	 ix = nblen(arg)

         call rsach(arg,nerr)
	 if (nerr .ne. 0) then
	    write(0,*) '**',arg(1:ix),':  Bad file name, skipping.'
	    go to 100
	 endif

	 n = n + 1
	 if (n .gt. nfmax) stop '**Too many data files.'

	 fname(n) = arg
	 if (sltp .eq. 'hd') then
	    call getfhv(slhv,slow(n),nerr)
	    if (nerr .ne. 0) then
	       write(0,*) '**No slowness in ',slhv(1:nblen(slhv)),
     &         ' for file ',fname(n)(1:ix),', skipping.'
	       n = n - 1
	       go to 100
	    endif
	 else
	    call getfhv('GCARC',dref(n),nerr)
	    call getfhv('STLA',slat(n),nerr)
	    call getfhv('STLO',slon(n),nerr)
	    call getfhv('BAZ',sbaz(n),nerr)

	    call getfhv('EVDP',temp,nerr)
	    call getkhv(slhv,arg,nerr)
	    if (nerr .ne. 0) then
	       write(0,*) '**No phase name in ',slhv(1:nblen(slhv)),
     &         ' for file ',fname(n)(1:ix),', skipping.'
	       n = n - 1
	       go to 100
	    endif

	    np = mtptt('all',dref(n),temp,ntt,idphs,tt,dtdd,dtdh)
	    ixpr = 0
	    do i=1,min(np,ntt)
	       if (idphs(i) .eq. arg) ixpr=i
	    enddo
	    if (ixpr .eq. 0) then
	       write(0,*) '**No reference phase ',arg(1:nblen(arg)),
     &            ' at ',dref(n),', skipping file ',fname(n)(1:ix),'.'
	       n = n - 1
	       go to 100
	    endif
	    slow(n) = dtdd(ixpr)
	 endif
	 if (slow(n) .lt. slow(ixlo)) ixlo = n
	 if (slow(n) .gt. slow(ixhi)) ixhi = n
	 if (stnm .eq. ' ') then
	    call getkhv('kstnm',arg,nerr)
	    if (nerr .eq. 0) stnm = arg
	 endif
      go to 100

200   continue
      if (n.le.0) stop '**No files given.'

      if (oinfo) write(6,*) 'Slowness range: ',slow(ixlo),slow(ixhi)

C     Build up table of depth-distance values.
      nslow = nint(slow(ixhi)+0.5) - int(slow(ixlo)) + 1
      if (slow(ixhi) .gt. slth) then
C        Slownesses higher than this value get finer sampling
         nslow = nslow + nint(slow(ixhi)+0.5 - slth)
      endif
      if (nslow.gt.nsmx) stop '**Slowness range too large.'
      p = int(slow(ixlo))
      do i=1,nslow
         tp(i) = p
	 if (p .lt. slth) then
	    p = p + 1
	 else
	    p = p + 0.5
	 endif
      enddo
      if (odebug) write(0,*) 'p range:',(tp(i),i=1,nslow)
      ix = 1+mod(ops,2)
      do i=1,nslow
	 p = tp(i)
	 tmp(1) = 0.0
	 do j=2,nzt
	    r = 1-tabz(j)/Re
	    arg = 'PS'
	    do k=1,2
	       del(k) = pmatch(arg(k:k),p,tabz(j),tim(k))
	    enddo
	    tmp(j) = del(ops)
	    tabtim(i,j) = tim(ix) - tim(ops) + p*(del(ops) - del(ix))
	    data(j) = tabtim(i,j)
	 enddo
	 if (oxt) then
	    do j=1,nz
	       ti = xbeg+(j-1)*dx
	       tabdel(i,j) = wigint(data,tmp,nzt,0.0,eps,abs(ti))
	    enddo
	 endif
	 if (odebug) then
	    do j=1,nz
	       data(j) = tabdel(i,j)
	    enddo
	    call newhdr
	    call setnhv('npts',nz,nerr)
	    call setfhv('b',xbeg,nerr)
	    call setfhv('delta',dx,nerr)
	    write(arg,'(a,i3.3)') '/tmp/dtable',nint(p*10)
	    call wsac0(arg,data,data,nerr)
	    call setihv('iftype','ixy',nerr)
	    call setlhv('leven',.false.,nerr)
	    call setnhv('npts',nzt,nerr)
	    write(arg,'(a,i3.3)') '/tmp/ttable',nint(p*10)
	    do k=1,nzt
	       data(k) = tabtim(i,k)
	    enddo
	    call wsac0(arg,tabz,data,nerr)
	 endif
      enddo
	    
C     Now have slownesses tabulated.  Run through files and read in the
C        seismogram or depth-o-gram for each of them.

      do j=1,n
	 arg = ' '
	 call rsac1(fname(j),data,npts,d0,dt,nmax,nerr)
	 if (nerr.ne.0) then
	    ix = nblen(fname(j))
	    write(0,*) '**Bad file: ',fname(j)(1:ix),'!'
	    stop
	 endif
	 te = d0 + (npts-1)*dt
	 if (opws) call hilbtf(data,hdata,npts,nmax)
	 if (oxt) then
	    do i=1,nzt
	       tz(i) = wigint(tp,tabtim(1,i),nslow,0.0,eps,slow(j))
	    enddo
	    if (odebug) then
	       call newhdr
	       write(arg,'(a,i3.3)') '/tmp/tptable',j
	       call wsac1(arg,tz,nzt,0.0,dzt,nerr)
	    endif
	 endif
	 do i=1,nz
	    ti = xbeg + (i-1)*dx
	    if (oxt) then
	       ti = sign(wigint(0.0,tz,nzt,dzt,eps,zref(i)),ti)
	    else
	       ti = abs(ti)
	    endif
	    if (ti .le. te .and. ti .ge. d0) then
	       sdata(i,j) = wigint(d0,data,npts,dt,eps,ti)
	       if (opws) shlbt(i,j) = wigint(d0,hdata,npts,dt,eps,ti)
	    else
	       sdata(i,j) = 0.0
	       if (opws) shlbt(i,j) = 0.0
	    endif
         enddo
         if (oinfo) then
	    ix = nblen(fname(j))
	    k = 0
	    do i=0,ix-1
	       if (fname(j)(ix-i:ix-i) .eq. '/') k=max(k,ix-i)
	    enddo
	    k = k+1
	    write(6,*) 'File: ',fname(j)(k:ix),', delta p baz:',
     &         dref(j),slow(j),sbaz(j)
	 endif
	 if (odebug) then
	    call newhdr
	    write(arg,'(a,i3.3)') '/tmp/data',j
	    call wsac1(arg,sdata(1,j),nz,xbeg,dx,nerr)
	 endif
      enddo

C     Compute succession of depth-o-grams along desired transect.

      ix = nblen(sacfile)
      call newhdr
      call setfhv('b',xbeg,nerr)
      call setfhv('delta',dx,nerr)
      call setnhv('npts',nz,nerr)
      if (nsect .le. 0) then
C        Simple sum
         call gmean(n,slat,slon,rngwt,tlat0,tlon0)
         call setfhv('stla',tlat0,nerr)
         call setfhv('stlo',tlon0,nerr)
	 if (stnm .ne. ' ') call setkhv('kstnm',stnm,nerr)
	 call setkhv('kevnm','SUM',nerr)
	 call setfhv('user0',pref,nerr)
	 call setkhv('kuser0','s/deg',nerr)
	 do j=1,nz
	    temp = 0.0
	    pwsum = 0.0
	    do k=1,n
	       temp = temp + sdata(j,k)
	       if (opws) pwsum = pwsum +
     &            exp(cmplx(0.,atan2(shlbt(j,k),sdata(j,k))))
            enddo
	    data(j) = temp/n
	    if (opws) data(j) = data(j)*abs(pwsum/n)**root
	    if (ojack) then
C              Jackknife error estimate
	       sumj = 0.0
	       do ko = 1,n
	          temp = 0.0
	          pwsum = 0.0
	          do k=1,n
	             if (k .ne. ko) then
	                temp = temp + sdata(j,k)
	                if (opws) pwsum = pwsum +
     &                     exp(cmplx(0.,atan2(shlbt(j,k),sdata(j,k))))
                     endif
	          enddo
	          temp = temp/(n-1)
	          if (opws) temp = temp*abs(pwsum/(n-1))**root
	          sumj = sumj + (data(j) - temp)**2
	       enddo
               hdata(j) = sqrt((n-1)*sumj/float(n))
	    else
C              Algebraic error estimate
	       temp = 0.0
               do k=1,n
                  temp = temp + (sdata(j,k) - data(j))**2
	       enddo
	       hdata(j) = sqrt(temp)/n
            endif
	 enddo
	 call wsac0(sacfile,data,data,nerr)
	 if (nerr .ne. 0) then
	    write(0,'(3a)') '**',sacfile(1:ix),':  Bad write.'
	 endif
	 call wsac0(sacfile(1:ix)//'.std',hdata,hdata,nerr)
	 if (nerr .ne. 0) then
	    write(0,'(3a)') '**',sacfile(1:ix),'.std:  Bad write.'
	 endif
      else
C        Succession of sections
	 call setfhv('evla',tlat0,nerr)
	 call setfhv('evlo',tlon0,nerr)
	 call setfhv('evdp',0.0,nerr)
	 call setkhv('kstnm','SECT',nerr)
	 do i=1,nsect
	    tdel = dello + (i-1)*(delhi - dello)/max(1,nsect-1)
	    call dazell(tlat0,tlon0,tdel,taz,tlat,tlon)
	    if (i .eq. 1) then
	       call setfhv('evla',tlat,nerr)
	       call setfhv('evlo',tlon,nerr)
	    endif
	    if (oinfo .or. odwt)
     &         write(*,*) 'Trace ',i,': Lat., Lon.',tlat,tlon
	    do j=1,nz
	       if (odwt) then
	          orep = abs(wtz - (xbeg + (j-1)*dx)) .le. dx
	       else
	          orep = .false.
	       endif
	       pwsum = 0.0
	       wtsum = 0.0
	       temp = 0.0
	       do k=1,n
		  d = wigint(tp,tabdel(1,j),nslow,0.0,eps,slow(k))
		  call dazll(slat(k),slon(k),d,sbaz(k),plat,plon)
		  call gcdse(tlat,tlon,plat,plon,del,rng,sraz,rsaz)
		  wt = exp(-rng/rngwt)
		  wtsum = wtsum + wt
		  temp = temp + sdata(j,k)*wt
		  if (opws) pwsum = pwsum +
     &               wt*exp(cmplx(0.,atan2(shlbt(j,k),sdata(j,k))))
                  if (orep) then
		     ixpr = index(fname(k),' ')
		     write(*,*) fname(k)(1:ixpr),rng,wt,sdata(j,k)
		  endif
	       enddo
	       data(j) = temp/wtsum
	       if (opws) data(j) = data(j)*abs(pwsum/wtsum)**root
	    enddo
	    if (okm) tdel = tdel*degkm
	    write(arg,'(f7.1)') tdel
	    do j=1,7
	       if (arg(j:j) .ne. ' ') go to 250
	    enddo
	    j=1
250         continue
	    call setkhv('kstnm',arg(j:),nerr)
	    call setfhv('stla',tlat,nerr)
	    call setfhv('stlo',tlon,nerr)
	    call setfhv('gcarc',tdel,nerr)
	    write(arg,'(a,i3.3)') sacfile(1:ix),i
	    call wsac0(arg,data,data,nerr)
	    if (nerr .ne. 0) then
	       write(0,'(3a)') '**',arg(1:ix+3),':  Unable to write.'
	    else
	       write(*,*) arg(1:ix+3),tdel
	    endif
	 enddo
      endif
      end

      function nblen(str)
      character str*(*)
      do i=len(str),1,-1
         if (str(i:i) .ne. ' ') exit
      enddo
      nblen = i
      end

      function pmatch(phs, ptgt, h, time)
C     PMATCH -- Find distance at which an upgoing wave from a given depth
C               matches a given slowness of a phase.
C
C     Assumes:
C        phs - phase name (P or S)
C        ptgt - desired slowness
C        h - depth
C
C     Returns:
C        function result - distance (degrees) at which wave matches
C        time - travel time for matching phase
C
C     Routine starts from zero range, extending outwards and shooting a
C     ray upwards until it brackets the desired slowness.  Then it does
C     a binary search to locate the range to within tolerance stol.  If
C     during the bracketing stage, it discovers that the ray changes from
C     upgoing to downgoing, no solution is feasible.  In this case, it
C     returns the range and the travel time of the horizontally-taking off
C     ray.

      parameter (stol = 0.005)
      character phs*(*)
      parameter (ntt=5)
      real tt(ntt),dtdd(ntt),dtdh(ntt),d2tdd2(ntt)
      character idphs(ntt)*8

C     Bracketing phase.  Extend bracket outwards from zero until target
C        slowness passed.
      dlo = 0.0
      dhi = 0.0005
      do i=1,50
	 np = ntptt(phs,dhi,h,ntt,idphs,tt,dtdd,dtdh,d2tdd2)
	 do j=1,np
	    if (idphs(j)(1:1) .eq. phs .and.
     &          0 .ne. index('gbn ',idphs(j)(2:2))) then
C              Check whether: 1) bracketed; 2) downgoing ray
	       if (dtdd(j) .gt. ptgt) go to 10
	       if (d2tdd2(j) .lt. 0.0) go to 20
	    endif
	 enddo
	 dlo = dhi
	 dhi = 2*dhi
      enddo
      stop '**Unable to locate reference p (max range hunt)' 

C     Search phase.  Hunt within bracket by binary search for proper slowness.
10    continue
      do i=1,50
	 d = (dlo+dhi)/2
	 np = mtptt(phs,d,h,ntt,idphs,tt,dtdd,dtdh)
	 do j=1,np
	    if (idphs(j)(1:1) .eq. phs .and.
     &          0 .ne. index('gbn ',idphs(j)(2:2))) then
	       if (abs(dtdd(j) - ptgt) .le. stol .or.
     &             ptgt .le. 0) then
                  time = tt(j)
                  pmatch = d
		  return
	       endif
	       if (dtdd(j) .lt. ptgt) then
		  dlo = d
	       else
		  dhi = d
	       endif
	       exit
	    endif
	 enddo
	 if (j.gt.np) stop '**Unable to locate reference p (bisection)'
      enddo
      stop '**Bad reference p'

C     Gone beyond upward-travelling wave.  Find and use max slowness.
20    continue
      do k=1,20
	 d = (dlo+dhi)/2
	 np = ntptt(phs,d,h,ntt,idphs,tt,dtdd,dtdh,d2tdd2)
	 if (abs(d2tdd2(j)) .lt. 1e-6) go to 25
	 if (d2tdd2(j) .gt. 0) then
	    dlo = d
	 else
	    dhi = d
	 endif
      enddo
25    continue
      pmatch = d
      time = tt(j)
      end
