      parameter (npmax=8,ncmax=npmax/2)
      real rts(2*npmax), amp(ncmax), phs(ncmax)
      complex c,cts(2*ncmax)
      equivalence (rts,cts)
      character arg*32, fname*32
      logical oint, ophs
      data oint/.true./, narg/0/, fname/' '/, ophs/.false./

      pi = 4*atan(1.0)

      iskip = 0
      do 5 i=1,iargc()
         if (i.le.iskip) go to 5
	 call getarg(i,arg)
	 if (arg(1:6).eq.'-noint') then
	    oint = .false.
	 else if (arg(1:3).eq.'-ph') then
	    ophs = .true.
	 else
	    narg = narg + 1
	    if (narg.eq.1) fname = arg
	    if (narg.eq.2.and.arg.ne.' ') read(arg,*) dt
	 endif
5     continue
      if (fname .eq. ' ') stop '**No output file name given.'
	    
      call newhdr

C     Basic signal:  Zero-lag delta function
      cts(1) = (1.,1.)
      do i=2,ncmax
         cts(i) = (1.,0)
      enddo

C     Added signal:  Delta function with lag dt
      cts(1) = cts(1) + cmplx(1., cos(pi*dt))

      do i=2,ncmax
         f = 2*float(i-1)/npmax
         cts(i) = cts(i) + cexp(cmplx(0.,pi*f*dt))
      enddo

      if (oint) then
C        Now interpolate in frequency domain
         phs(1) = 0.0
         amp(1) = real(cts(1))
         do i=2,ncmax
            amp(i) = abs(cts(i))
	    phs(i) = atan2(imag(cts(i)),real(cts(i)))
         enddo
         call drum(ncmax,phs)
	 do i=ncmax,2,-1
	    cts(2*i-1) = cts(i)
	 enddo

	 if (ophs) then
	    f = 0.5*(phs(ncmax)-phs(ncmax-1)) + phs(ncmax)
	    a = 0.5*(amp(ncmax)-amp(ncmax-1)) + amp(ncmax)
	    cts(2*ncmax) = a*cmplx(cos(f),sin(f))
	 else
C           cts(2*ncmax) = cts(ncmax)+0.5*(cts(ncmax)-cts(ncmax-1))
	    cts(2*ncmax) = 0.5*(cts(ncmax)+imag(cts(1)))
	 endif
	 do i=2,2*(ncmax-1),2
	    if (ophs) then
	       j=i/2
	       f = 0.5*(phs(j)+phs(j+1))
	       a = 0.5*(amp(j)+amp(j+1))
	       cts(i) = a*cmplx(cos(f),sin(f))
	    else
	       cts(i) = 0.5*(cts(i-1)+cts(i+1))
	    endif
	 enddo
	 if (.not.ophs) cts(2) = 0.5*(real(cts(1))+cts(3))
	 n = 2*npmax
      else
         n = npmax
      endif

      call realft(rts,n,-1)
      f = float(2)/n
      do i=1,n
         rts(i) = f*rts(i)
      enddo

      call wsac1(fname,rts,n,0.0,1.0,nerr)
      if (nerr .ne. 0) write(0,*) '**Trouble writing file!'
      end

C     SUBROUTINE DRUM(LPHZ,PHZ)
C
C     Robinson's routine to make phase (PHZ) continuous

      SUBROUTINE DRUM (LPHZ,PHZ)
      DIMENSION PHZ(LPHZ)
      PARAMETER (PI=3.141592653589793D0,PI2=6.28318530717959D0)

      PJ=0.
      DO 40 I=2,LPHZ
         IF(ABS(PHZ(I)+PJ-PHZ(I-1))-PI) 40,40,10
10       IF(PHZ(I)+PJ-PHZ(I-1)) 20,40,30
20       PJ=PJ+PI2
         GO TO 40
30       PJ=PJ-PI2
40    PHZ(I)=PHZ(I)+PJ
      RETURN
      END

