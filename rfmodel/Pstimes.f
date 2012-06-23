C	Program to determine the relative time difference between a direct
C       phase arrival and a converted phase arrival (P to S or S to P) from
C       some depth discontinuity that reaches the surface at the same
C       point.
C
C       Uses tau-P table subroutines.
C
C          by G. Helffrich/U. Bristol, 1995-2008.
C
C       Nomenclature:
C          upgoing P, S from source - px or sx
C          upgoing near-receiver conversion to P or S - xp or xs
C          downgoing P, S from source - Px or Sx
C          downgoing near-source conversion to P or S - xP or xS
C
C          Example:
C
C          ===================================================
C                                                :
C                                                :
C                                                :
C          -------x-------------------------------------------
C                / `                             :
C               /    `                           :
C              *       `                         :
C               \        `                       :
C                \         `                     :
C                 \          `                   :
C          --------x-----------------------------x------------
C                   `            `              /
C                     `            `           /
C                       `            `        /
C                      PS            pS     Ps
C
C
C       Input:
C          1 line phase name, slowness, conversion depth
	parameter (ntmax=5)
	real i0
	character inline*64, token(ntmax)*16
 	character cphs*1, tphs*1, mphs*8, sphs*1
C	include 'Pstimes.com'
	logical head, sr, oinfo
C       external smin
	data re /6371./, head /.false./, oinfo/.false./

	pi = 4.0*atan(1.0)

	iskip = 0
	do 5 i=1,iargc()
	   if (i .le. iskip) go to 5
	   call getarg(i,inline)
	   if (inline .eq. '-nohead') then
	      head = .true.
	   else if (inline .eq. '-info') then
	      oinfo = .true.
	   else if (inline .eq. '-model') then
	      call getarg(i+1,inline)
	      if (inline .ne. ' ') call tpmod(inline)
	      iskip = i+1
	   else
	      write(0,*) '**Don''t understand ',
     &           inline(1:index(inline,' ')-1),', skipping.'
           endif
5       continue

10      continue
	   read (5,'(a)',end=999,err=999) inline

C          Abbreviated processing for -info option; just determine slowness.

	   if (oinfo) then
C             Retrieve file header (no data read).
	      call rsac1(inline,data,n,fbeg,fdel,0,nerr)
	      if (nerr.ne.0) then
		 write(0,*) '**Can''t read ',inline(1:index(inline,' '))
		 go to 10
	      endif

C             Retrieve event parameters for main phase.
	      call getfhv('GCARC',d,nerrd)
	      call getfhv('EVDP',evdp,nerrh)
	      if (nerrd.ne.0 .or. nerrh.ne.0) then
	         write(0,*) '**File ',inline(1:index(inline,' ')-1),
     &              ' lacks event information (GCARC and EVDP) - skip.'
		 go to 10
	      endif

	      call getkhv('KA',mphs,nerr)
	      if (mphs .eq. '_') call getkhv('KT0',mphs,nerr)
	      if ((mphs .ne. 'P' .and. mphs .ne. 'PP' .and.
     &             mphs(1:3).ne.'PcP' .and.  mphs(1:3).ne.'ScS' .and.
     &             mphs(1:3) .ne. 'SKS' .and. mphs .ne. 'Pdiff' .and.
     &             mphs .ne. 'S' .and. mphs(1:3) .ne. 'PKP')
     &             .or. nerr .ne. 0) then
	         write(0,*) '**File ',inline(1:index(inline,' ')-1),
     &              ' has no named main phase',
     &              ' (P or PP etc. as KA value in header) - skip.'
                 go to 10
	      endif

C             Get arrival parameters for main phase.
	      ttP = tpttxx(mphs,d,evdp,dtdd,dtdh)

	      write(*,*) inline(1:index(inline,' ')-1),' ',
     &           mphs(1:index(mphs,' ')-1),' ',dtdd
	      go to 10
	   endif

           call tokens(inline,ntmax,n,token)
	   if (n .ne. 3) then
	      write(0,*) '**Not enough information.'
	      go to 10
	   endif
	   inline = token(2)//token(3)
           read(inline,*,iostat=ios) dtddel,disc
	   if (ios .ne. 0) then
	      write(0,*) '**Invalid slowness or disc. depth.'
	      go to 10
	   endif
	   if (.not.(token(1) .eq. 'Ps' .or. token(1) .eq. 'Sp'
     +     )) then
	      write(0,*) '**Don''t understand a ',
     +           token(1)(1:index(token(1),' ')),'conversion.'
	      go to 10
	   endif
C          Set up phase names to match.  Distinguish three:
C             mphs - main phase from quake
C             cphs - phase from discontinuity to surface, converted at disc.
C             tphs - phase from discontinuity to surface, transmitted at disc.
C          sr is true if we are doing a near-source conversion like p410P or
C             S660P
	   cphs = token(1)(2:)
	   tphs = token(1)(1:1)
	   if (tphs .eq. 'p') tphs = 'P'
	   if (tphs .eq. 's') tphs = 'S'
	   if (cphs .eq. 'p') cphs = 'P'
	   if (cphs .eq. 's') cphs = 'S'

C          Find distance range to consider for source positions (going upward).
	   dmaxc = delmax(cphs,disc)
	   dmaxt = delmax(tphs,disc)
	   dmax = max(dmaxc,dmaxt)
	   delt = smatch(tphs,disc,dtddel,dmaxt)
	   delc = smatch(cphs,disc,dtddel,dmaxc)
	   ttast = tpttxx(tphs,delt,disc,pjunk,dtdh)
	   ttasc = tpttxx(cphs,delc,disc,pjunk,dtdh)
	   tdiff = ttasc + (delt-delc)*dtddel - ttast
	   if (.not. head) then
	      write(6,18) 
18            format(' phase ray param. depth  time conv. dist.',/,
     &               '                              trans. conv.')
	      head = .true.
	   endif
	   ix = index(token(1),' ')-1
	   write(6,19) token(1)(1:ix),dtddel,disc,tdiff,delt,delc
19	   format(1X,A6,1X,F8.5,2X,F6.1,1X,F6.2,2(1X,F5.2))
	go to 10
999	continue
	end

	function smatch(phs,h,slow,dmax)
C       Find value of delta for phase S at depth h that matches slowness given.
        character phs*(*)
	parameter (tol = 1e-4)

	xlo = 0.0
	xhi = dmax
        do 10 i=1,25
	   xtry = (xlo + xhi)/2.0
	   tt = tpttxx(phs,xtry,h,dttry,dtdh)
	   if (abs(dttry-slow) .lt. tol*slow) go to 19
	   if (dttry .lt. slow) then
	      xlo = xtry
	   else
	      xhi = xtry
	   endif
10      continue
        write(0,18) phs,slow,abs(dttry-slow)/abs(slow)
18      format('SMATCH:  Didn''t converge for ',a,' at ',1pg12.4,
     +         '; rel. err. is ',1pg12.4)

19      continue
        smatch = xtry
	end

      function delmax(phs, h)
C     DELMAX -- Find distance at which an upgoing wave from a given depth
C               matches a given slowness of a phase.
C
C     Assumes:
C        phs - phase name (P or S)
C        h - depth
C
C     Returns:
C        function result - distance (degrees) at which wave matches
C        time - travel time for matching phase
C
C     Routine starts from zero range, extending outwards and shooting a
C     ray upwards until dp/d(delta) goes negative. Then it does
C     a binary search to locate the extremum.

      parameter (stol = 0.005)
      character phs*(*)
      parameter (ntt=5)
      real tt(ntt),dtdd(ntt),dtdh(ntt),d2tdd2(ntt)
      character idphs(ntt)*8, phsgot*8

C     Bracketing phase.  Extend bracket outwards from zero until target
C        slowness bracketed.
      dlo = 0.0
      dhi = 0.0005
      do i=1,50
	 np = ntptt(phs,dhi,h,ntt,idphs,tt,dtdd,dtdh,d2tdd2)
	 do j=1,np
	    if (idphs(j)(1:1) .eq. phs .and.
     &          0 .ne. index('gbn ',idphs(j)(2:2))) then
C              Check whether: 1) bracketed; 2) downgoing ray
	       if (d2tdd2(j) .lt. 0.0) go to 20
	    endif
	 enddo
	 dlo = dhi
	 dhi = 2*dhi
      enddo
      stop '**Unable to locate max p (max range hunt)' 

C     Gone beyond upward-travelling wave.  Find and use max slowness.
20    continue
      phsgot = idphs(j)
      do k=1,20
	 d = (dlo+dhi)/2
	 np = ntptt(phs,d,h,ntt,idphs,tt,dtdd,dtdh,d2tdd2)
	 do j=1,np
	    if (idphs(j) .eq. phsgot) go to 21
	 enddo
         if (np.gt.1) stop '**Unable to locate max p (lost phase)' 
	 j = 1
21       continue
	 if (abs(d2tdd2(j)) .lt. 1e-6) go to 25
	 if (d2tdd2(j) .gt. 0) then
	    dlo = d
	 else
	    dhi = d
	 endif
      enddo
25    continue
      delmax = d
      end

C       function delmax(phs,depth)
C       DELMAX - find maximum distance an upwards-travelling ray may
C                get starting at a given depth.
C
C       Assumes:
C          phs - character phase name
C          depth - event depth
C
C       Returns:
C          function result - distance where dt/ddelta is maximum for
C             the named phase
C
C       character phs*(*)
C       include 'Pstimes.com'
C       external smin
C
C       sphs = phs
C       sh = depth
C       err = brent(0.0,5.0,30.0,smin,1e-3,delta)
C       delmax = delta
C       end

C       function smin(x)
C       Implicitly called by brent.  Returns -dt/ddelta so that minimum
C       can be found and used for upper bound on search for matching
C       ScS dt/ddelta.
C       include 'Pstimes.com'

C	tt = tpttxx(sphs,x,sh,dtdd,dtdh)
C       smin = -dtdd
C       end

	function tpttxx(id,delta,depth,dtddel,dtddep)
C       tpttxx -- Version of tptt that handles multiple arrivals and
C          returns the first one that matches.  This is hopefully the
C          phase of interest.
	parameter (nmax=10)
	real tt(nmax),dtdd(nmax),dtdh(nmax)
	character idphs(nmax)*8, id*(*)

C       n = mtptt(id,delta,depth,nmax,idphs,tt,dtdd,dtdh)
        n = mtptt('all',delta,depth,nmax,idphs,tt,dtdd,dtdh)
	do 10 i=1,min(n,nmax)
	   if (id .eq. idphs(i)) go to 12
	   if (id .eq. 'P' .and. idphs(i) .eq. 'Pn') go to 12
	   if (id .eq. 'S' .and. idphs(i) .eq. 'Sn') go to 12
	   if (id .eq. 'P' .and. idphs(i) .eq. 'Pg') go to 12
	   if (id .eq. 'S' .and. idphs(i) .eq. 'Sg') go to 12
	   if (id .eq. 'P' .and. idphs(i) .eq. 'Pb') go to 12
	   if (id .eq. 'S' .and. idphs(i) .eq. 'Sb') go to 12
	   if (id .eq. 'P' .and. idphs(i) .eq. 'Pdiff') go to 12
	   if (id .eq. 'S' .and. idphs(i) .eq. 'Sdiff') go to 12
10      continue
C	write(0,*) 'TPTTXX:  No ',id,' arrival at ',delta
        tpttxx = -1.0
        return

12      continue
        dtddel = dtdd(i)
	dtddep = dtdh(i)
	tpttxx = tt(i)
	end

	integer function lenb(string)
	character*(*) string

	do 10 i=len(string),2,-1
	   if (string(i:i) .ne. ' ') go to 12
10      continue
12      continue
	lenb = i
	end
