      subroutine sit2(psvsh,c,freq,resp,alfa,beta,qp,qs,rho,thik,nlyrs)
c
c           compute the site response for nlyrs-1 dissipative layers ove
c        a halfspace for a p, sv or sh wave incident from the halfspace.
c        frequency domain solution, yeilding the complex response at a
c        given frequency and phase veloctiy.
c        this solution sub-divides layers for which p or q are too
c        large at this freq into equal sub-layers, to prevent machine ov
c        flow problems.
c
c          arguments...
c        psvsh = 1,2,3 for an incident p, sv or sh wave.
c
c        freq,c - prescribed freq (hz) & horizontal phase velocity (c is
c            not restricted to be greater than alfa or beta)
c
c        resp - the complex response in the u,v,w directions.  the respo
c            is the ratio of the free surface to incident displacements
c            velocities, etc), the 'crustal transfer functions' of haske
c            (1962).  for p or sv solution, resp(1) & (3) contain the ho
c            zontal and vertical (u and w) response.  for sh, resp(2)
c            contains the  horizontal (v) response.
c
c        alfa,beta,qp,qs,rho and thik contain the medium properties for
c            layers 1 thru nlyrs (the halfspace).  thik(nlyrs) not refrn
c            input qs(i) as negative if want no dissipation in that laye
c            if qp(i) is input negative, it is calculated from qs(i),
c            assuming qkappa is infinite (eg., stacey,1969).
c
c        note: this is the same solution method as subroutine 'crust', b
c        made specific for the crustal transfer function solution.
c         original routine by:  a. shakal  9/78
c         modified by t.j. owens 7/81
c
      logical psvwav,shwave,test
      integer psvsh,hsize,hafsiz
      real k,alfa(1),beta(1),qp(1),qs(1),rho(1),thik(1)
c
c        complex declarations are in alphabetical order...
c
      complex cosp,cospq1,cosq,d,f,fg,g,gama,gamas,gamas2,g
     &amas3,   gm1,gsm1,gm1gs1,h(4,4),hn(4,2),hprod(4,2)
     &,             i,j(4,2),          kalfa,kbeta,nu,nualfa,nubeta,nupr
     &od,one,p,q,   resp(3),ro,s,shterm,sinp,sinq,two,zero
      integer ounit
      common /innout/ inunit,ounit
      data twopi,eps/6.2831853,.001/,  expmax/30./,  i,zero/(0.,1.),(0.,
     &0.)/,   one,two/(1.,0.),(2.,0.)/
      nu(c,vel) = cmplx(sqrt(abs((c/vel)**2 -1.)), 0.)
c
c
      w = twopi*freq
      if(freq .eq. 0.) w = 1.0e-6
      signw = sign(1.,w)
      k = w/c
      shwave = psvsh .eq. 3
      psvwav = psvsh .le. 2
      hsize = 4
      if(shwave) hsize = 2
      hafsiz = hsize/2
      do 9000  ii=1,3
 9000 resp(ii) = zero
      p = zero
c
c        check that none of the q's are input as zero  (cc pull for spee
c
      do 10 n = 1,nlyrs
      if(abs(qp(n)) .gt. eps  .and.  abs(qs(n)) .gt. eps) go to 10
      write (ounit,108) n
      stop
  10  continue
  108     format('site: q=0 in layr',i3)
c
c
c           calculate hn, the matrix of propagation down to the top of
c        the halfspace:  hn = h(nlyrs-1)*h(nlyrs-2)*...*h(2)*h(1)
c
c
      do 40 n = 1,nlyrs
c
c        values depending on s-wave velocity...
c
      qsinv = amax1(0., 1./qs(n))
      if(qs(n) .lt. 0.) kbeta = cmplx(k, 0.)
      if(qs(n) .gt. 0.) kbeta = cmplx(k, 0.)/csqrt(cmplx(1., signw*qsinv
     &))
      nubeta = nu(c,beta(n))
      if(c .lt. beta(n)) nubeta = -i*nubeta
      gama = cmplx(2.*(beta(n)/c)**2, 0.)
      ro = cmplx(rho(n), 0.)
      if(shwave) shterm = two*kbeta/(ro*gama*nubeta)
      if(shwave) go to 22
c
c        values depending on p-wave velocity...
c
      qpinv = 1./qp(n)
      if(qp(n) .lt. 0.) qpinv = 1.33*(beta(n)/alfa(n))**2*qsinv
      if(qpinv .le. 0.) kalfa = cmplx(k, 0.)
      if(qpinv .gt. 0.) kalfa = cmplx(k, 0.)/csqrt(cmplx(1., signw*qpinv
     &))
      nualfa = nu(c,alfa(n))
      if(c .lt. alfa(n)) nualfa = -i*nualfa
      nuprod = nualfa*nubeta
      s = kalfa/kbeta
      gamas = gama*s
      gamas2 = gamas*gamas
      gamas3 = gamas2*gamas
      gm1 = gama - one
      gsm1 = gamas*s - one
      gm1gs1 = gm1*gsm1
      f = one + gamas - gamas*s
      g = one - gama + gamas
      fg = f*g
 22   if(n .eq. nlyrs .and. nlyrs .gt. 1) go to 42
c
c        if p or q will cause sinh or cosh to be too large for the machi
c        given this layer thickness, divide layer into 'nparts' equal pa
c
      q = kbeta*nubeta*cmplx(thik(n), 0.)
      if(psvwav) p = kalfa*nualfa*cmplx(thik(n), 0.)
      nparts = amax1(abs(aimag(p)),abs(aimag(q)))/expmax +1.
      if(nparts.gt.1) write(ounit,985) w,nparts,n
  985 format(1x,e15.6,2i8)
      if(nparts .gt. 1) q = q/cmplx(float(nparts), 0.)
      if(nparts .gt. 1 .and. psvwav) p = p/cmplx(float(nparts), 0.)
      sinq =csin(q)
      cosq =ccos(q)
      if(shwave) go to 26
      sinp = csin(p)
      cosp = ccos(p)
      cospq1 = cosp - cosq
c
c        compute h, the 4x4 transfer matrix of this layer, analogous
c        to a(m) of haskell(1953).    for p-sv problem...
c
      h(1,1) = (gamas*cosp - gsm1*cosq)/f
      h(2,1) = -i*(gamas*nualfa*sinp + gsm1*sinq/nubeta)/f
      h(3,1) = ro*gama*gsm1*(cospq1)/(kbeta*f)
      h(4,1) = i*ro*(nualfa*gamas2*sinp + gm1gs1*sinq/nubeta)/(kbeta
     &*f)
      h(1,2) = i*(gm1*sinp/nualfa + gamas*nubeta*sinq)/g
      h(2,2) = -(gm1*cosp - gamas*cosq)/g
      h(3,2) = i*ro*(gm1gs1*sinp/nualfa + gamas2*nubeta*sinq)/(kalfa
     &*g)
      h(4,2) = ro*gamas*gm1*(cospq1)/(kbeta*g)
      if(n .eq. 1 .and. nparts .eq. 1) go to 30
      h(1,3) = -kalfa*(cospq1)/(ro*f)
      h(2,3) = i*kalfa*(nualfa*sinp + sinq/nubeta)/(ro*f)
      h(3,3) = -(gsm1*cosp - gamas*cosq)/f
      h(4,3) = -i*s*(gamas*nualfa*sinp + gm1*sinq/nubeta)/f
      h(1,4) = i*kbeta*(sinp/nualfa + nubeta*sinq)/(ro*g)
      h(2,4) = -kbeta*(cospq1)/(ro*g)
      h(3,4) = i*(gsm1*sinp/nualfa + gamas*nubeta*sinq)/(s*g)
      h(4,4) = (gamas*cosp - gm1*cosq)/g
      go to 30
c
c        for sh problem...
c
 26   h(1,1) = cosq
      h(2,1) = i*sinq/shterm
      h(1,2) = i*shterm*sinq
      h(2,2) = h(1,1)
c
c        multiply to obtain the matrix of propagation down thru layer n.
c        only need 1st col of hn for sh, and the 1st 2 cols, with the 1s
c        col of hhn, for psv.  if nparts > 1, do multiplication for each
c        of the nparts this layer is divided into.
c
   30 if(n .gt. 1) go to 34
      do 9004  jj=1,hafsiz
      do 9004  ii=1,hsize
 9004 hn(ii,jj) = h(ii,jj)
      if(nlyrs .eq. 1) go to 42
      nparts = nparts - 1
      if(nparts .eq. 0) go to 40
 34   do 36 npart = 1,nparts
      do 9010  jj = 1,hafsiz
      do 9010  ii = 1,hsize
 9010 hprod(ii,jj) = zero
      do 9012  jj = 1,hafsiz
      do 9012    ii = 1,hsize
      do 9012  kk = 1,hsize
 9012 hprod(ii,jj) = hprod(ii,jj) + h(ii,kk)*hn(kk,jj)
      do 9014  jj=1,hafsiz
      do 9014  ii=1,hsize
 9014 hn(ii,jj) = hprod(ii,jj)
 36   continue
 40   continue
c
c
c           solve for the 'crustal transfer functions', the ratio of the
c        free surface displacements (or velocities, etc) to the incident
c        (i.e., fullspace) displacements (or veloc.).  using left half
c        of j = einvrs*hn.
c
c
 42   if(shwave) go to 50
      do 48 m = 1,2
      j(3,m) = (gsm1*hn(1,m)/kbeta - s*hn(3,m)/ro)/(nubeta*f)
      j(4,m) = (gamas*s*hn(2,m)/kalfa + hn(4,m)/ro)/g
      j(1,m) = (gama*hn(1,m)/kbeta - hn(3,m)/ro)/f
 48   j(2,m) = -(gm1*hn(2,m)/kalfa + hn(4,m)/(ro*s))/(nualfa*g)
      d = (j(1,1)-j(2,1))*(j(3,2)-j(4,2))
     *   +(j(1,2)-j(2,2))*(j(4,1)-j(3,1))
      if(psvsh.eq.1) go to 51
c
c      incident sv wave.  calc usv, wsv of haskell's notation.
c
      resp(1) = two*(j(1,2) -j(2,2))/(kbeta*nubeta*d)
      resp(3) = two*(j(2,1) -j(1,1))/(kbeta*d)
      return
c
c      incident p wave.  calculate up, wp of haskell's notation.
c
   51 resp(1)=two*(j(3,2)-j(4,2))/(kalfa*d)
      resp(3)=two*(j(3,1)-j(4,1))/(kalfa*nualfa*d)
      return
c
c        incident sh wave.  calculate vsh.
c
 50   resp(2) = two/(hn(1,1) +shterm*hn(2,1))
      return
      end
