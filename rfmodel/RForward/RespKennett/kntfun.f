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
      parameter ( rmin = -20. )
      if ( real(arg) .lt. rmin ) then
         cphs = (0.,0.)
      else
         cphs = cexp(arg)
      endif
      return
      end

      function tauint(func,zlo,zhi,eps)
C     TAUINT -- Compute vertical phase integral of function between two
C               depth levels, to relative tolerance eps.
C
C     Assumes:
C        func(z) - real function to return vertical slowness at depth z
C        zlo - low depth range
C        zhi - high depth range
C        eps - relative tolerance desired

      external func
      parameter (imax=20, kint=3)
      real val(imax+1), div(imax+1), err(imax+1)

      minerr = 1
      t = 1
      do j=1,imax
         div(j) = t
         call trapzd(func,zlo,zhi,val(j),j)
	 if (j.ge.kint) then
	    tauint = ratint(div,val,j,0.0,err(j))
	    if (err(j).le.eps*abs(tauint)) return
	    val(j) = tauint
	    if (abs(err(j)) .le. abs(err(minerr))) minerr = j
	 endif
	 t = 0.25*t
	 val(j+1) = val(j)
      enddo
      write(0,*) '**TAUINT:  Too many steps, returning min error.'
      tauint = val(minerr)
      end

      FUNCTION RATINT(XA,YA,N,X,DY)
      PARAMETER (NMAX=20,TINY=1.E-25)
      DIMENSION XA(N),YA(N),C(NMAX),D(NMAX)
      NU=MIN(N,NMAX)
      NS=1
      HH=ABS(X-XA(1))
      DO 11 I=1,NU
        H=ABS(X-XA(I))
        IF (H.EQ.0.)THEN
          RATINT=YA(I)
          DY=0.0
          RETURN
        ELSE IF (H.LT.HH) THEN
          NS=I
          HH=H
        ENDIF
        C(I)=YA(I)
        D(I)=YA(I)+TINY
11    CONTINUE
      Y=YA(NS)
      NS=NS-1
      DO 13 M=1,NU-1
        DO 12 I=1,NU-M
          W=C(I+1)-D(I)
          H=XA(I+M)-X
          T=(XA(I)-X)*D(I)/H
          DD=T-C(I+1)
          IF(DD.EQ.0.)THEN
	     IF(W.NE.0.)THEN
	        PAUSE '**RATINT:  Duplicate points'
	     ENDIF
	     DD=1.0
	  ELSE
	     DD=W/DD
	  ENDIF
          D(I)=C(I+1)*DD
          C(I)=T*DD
12      CONTINUE
        IF (2*NS.LT.NU-M)THEN
          DY=C(NS+1)
        ELSE
          DY=D(NS)
          NS=NS-1
        ENDIF
        Y=Y+DY
13    CONTINUE
      RATINT = Y
      END

      SUBROUTINE TRAPZD(FUNC,A,B,S,N)
      EXTERNAL FUNC
      SAVE IT
      IF (N.EQ.1) THEN
        S=0.5*(B-A)*(FUNC(A)+FUNC(B))
        IT=1
      ELSE
        TNM=IT
        DEL=(B-A)/TNM
        X=A+0.5*DEL
        SUM=0.
        DO 11 J=1,IT
          SUM=SUM+FUNC(X)
          X=X+DEL
11      CONTINUE
        S=0.5*(S+(B-A)*SUM/TNM)
        IT=2*IT
      ENDIF
      RETURN
      END

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
      call locast(dirctn,invrse,forwrd)
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
      real data(*)
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

      subroutine locast(dirctn,invrse,forwrd)
      character dirctn*(*), dfwd*7, dinv*7
      logical forwrd,invrse
      data dfwd, dinv/'forward','inverse'/
      ix = max(1,len(dirctn))
      if(dirctn.eq.dfwd(1:ix)) then
         invrse=.false.
         forwrd=.true.
      else if(dirctn.eq.dinv(1:ix)) then
         invrse=.true.
         forwrd=.false.
      else
	 write(0,100)dirctn
  100    format(1x,a,1x,'is meaningless to dfftr, ',
     &      'use forward or inverse only')
         invrse=.false.
         forwrd=.false.
      endif
      end

      logical function yesno(quest)
c
c   interactive i-o for logical variables
c    yesno must be declared logical in calling program
c
      character quest*(*),answer*1
      character*8 myformat
      equivalence (myformat,answer)
c
      write(myformat,'(a,i3.3,a)')'(a',len(quest),',$)'
c      
      write(*,myformat) quest

      read(*,'(a)') answer
      yesno = 0 .ne. index('yY',answer)
      end

      function npowr2(n)
c
c finds the next power of 2 .ge.n
c
      ipowr=alog10(2.*float(n)-1.)/.301029996
      if(n.eq.1) ipowr=1
      npowr2=2**ipowr
      return
      end
