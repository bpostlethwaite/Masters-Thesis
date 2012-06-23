C     Program with noninteractive input to calculate vertical propagation delay
C     through an RF model.
C
C     Input parameters:
C        -type [ p | s ]: type of wave to calculate lag for.
C        -p x [ s/km | s/deg ]:  input slowness x and unit
C        -sph - Spherical earth calculation, apply earth flattening transform
C
C     Modified from rfksyn by G. Helffrich/U. Bristol, Summer 2011.
      parameter (Re=6371., eps=1e-4)
      include 'tlag.com'
      real alfm(nlmx), betm(nlmx), rhom(nlmx)
      real alfb(nlmx), betb(nlmx), rhob(nlmx)
      real velh(nlmx,2), vell(nlmx,2)
      equivalence (alfm,velh(1,1)),(betm,velh(1,2))
      equivalence (alfb,vell(1,1)),(betb,vell(1,2))
      real delay(2), rng(2)
      external eta, tint, dint
      character modela*256,ofil*80,title*32,pors(2)*1
      logical rdlyr, wh, sunit, oefa
      data ipors/1/, oefa/.false./, pors/'P','S'/
c
      efp(z) = Re/(Re-z)
      efz(z) = Re*log(efp(z))
c
      twopi = 8.*atan(1.)
      pr = -1.0
      iskip = 0
      do i=1,iargc()
         if (i.le.iskip) cycle
         call getarg(i,ofil)
	 if (ofil .eq. '-p') then
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
	       stop '**Bad wave -type (should be either S or P)'
	    endif
	    iskip = i+1
	 else if (ofil(1:4) .eq. '-sph') then
	    oefa = .true.
	 else
            iblank=lenb(ofil)
	    write(0,*) '**Unrecognized parameter: ',ofil(1:iblank)
	    stop
	 endif
      enddo
      if (pr .lt. 0) stop '**No slowness given (-p x s/km or s/deg)'
c
c     write(ounit,*) 'Velocity Model Name'
      read(*,'(a)',iostat=ios) modela
      if (ios.ne.0) stop

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
	    fact= efp(zz )
	    facb= efp(zaw)
	    if (alfb(i) .eq. 0.0) then
	       alfm(i) = alfm(i)*fact
	       betm(i) = betm(i)*fact
	       rhom(i) = rhom(i)/fact
	       alfb(i) = alfm(i)*facb
	       betb(i) = betm(i)*facb
	       rhob(i) = rhom(i)/facb
	    else
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

C     Read succession of depths and write out lag.

1000  continue
         read(*,*,iostat=ios) zz
	 if (ios.ne.0) stop
	 if (oefa) then
	    zf = efz(zz)
	 else
	    zf = zz
	 endif

C     Copy appropriate velocities into integration table
	 do j=1,2
	    z = 0
	    do i=1,nlyrs
	       velt(i) = velh(i,j)
	       velb(i) = vell(i,j)
	       if (velb(i).eq.0) velb(i) = velh(i,j)
	       z = z + thikm(i)
	    enddo
	    z = 0
	    delay(j) = 0.0
	    rng(j) = 0.0
	    do i=1,nlyrs
	       zbot = z + thikm(i)
	       zlim = min(zf,zbot)
	       call qromb(tint, z, zlim, tval)
	       call qromb(dint, z, zlim, dval)
	       delay(j) = delay(j) + tval
	       rng(j) = rng(j) + dval
	       if (zbot.ge.zf) exit
	       z = zbot
	    enddo
	 enddo
	 delay(2) = delay(2) + pr*(rng(1)-rng(2))
	 write(*,*) zz,' P ',delay(1),' S ',delay(2),' S-P',
     &      delay(2)-delay(1)
      go to 1000
      end

      function dint(z)
C     dint -- Return distance integral from surface to depth z.
      include 'tlag.com'

      znow = 0
      do i=1,nlyrs
         znow = znow + thikm(i)
         if (z.le.znow) exit
      enddo

      if (i.gt.nlyrs) then
         i = nlyrs
	 f = 0
      else
         f = 1 - (znow-z)/thikm(i)
      endif
      vel = f*velt(i) + (1-f)*velb(i)

      etasq = 1 - (vel*pr)**2
      if (etasq .lt. 0) then
         write(0,*) '**Evanescent wave at ',z,' km'
	 dint = 0
      else
         dint = pr*vel/sqrt(etasq)
      endif
      end

      function tint(z)
C     tint -- Return travel time integral from surface to depth z.
      include 'tlag.com'

      znow = 0
      do i=1,nlyrs
         znow = znow + thikm(i)
         if (z.le.znow) exit
      enddo

      if (i.gt.nlyrs) then
         i = nlyrs
	 f = 0
      else
         f = 1 - (znow-z)/thikm(i)
      endif
      vel = f*velt(i) + (1-f)*velb(i)

      etasq = 1 - (vel*pr)**2
      if (etasq .lt. 0) then
         write(0,*) '**Evanescent wave at ',z,' km'
	 tint = 0
      else
         tint = 1/(vel*sqrt(etasq))
      endif
      end

      function eta(z)
C     eta -- Return vertical slowness at depth z.
      include 'tlag.com'

      znow = 0
      do i=1,nlyrs
         znow = znow + thikm(i)
         if (z.le.znow) exit
      enddo

      if (i.gt.nlyrs) then
         i = nlyrs
	 f = 0
      else
         f = 1 - (znow-z)/thikm(i)
      endif
      vel = f*velt(i) + (1-f)*velb(i)

      etasq = 1/vel**2 - pr**2
      if (etasq .lt. 0) then
         write(0,*) '**Evanescent wave at ',z,' km'
	 eta = 0
      else
         eta = sqrt(etasq)
      endif
      end

      function lenb(str)
      character str*(*)
      do i=len(str),1,-1
         if (str(i:i) .ne. ' ') exit
      enddo
      lenb = i
      end
