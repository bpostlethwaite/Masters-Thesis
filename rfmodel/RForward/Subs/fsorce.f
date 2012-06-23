      function fsorce (isorfn,f,delay,kstrtd,a,b,t,wo,trap)
c
c           function to return the (complex) spectral value of a specifi
c        source function at frequency f, with a specifiable time delay.
c            # 1  s(t) = (a/dt)del(t)              s(w) = a
c            # 2  s(t) = triangle, a by t          s(w) = sqrd sinc(wt/4
c            # 3  s(t) = at*exp(-bt)               s(w) = a/(bb-ww,2wb)
c            # 4  s(t) = a*exp(-bt)*sin(ct)        s(w) = ac/(bb+cc-ww,2
c        calls to ask, sinc.                 a.shakal 10/76, 10/5/78, 8
c
      complex fsorce
      dimension trap(4)
      integer ounit
      common /innout/ inunit,ounit
      data e,twopi/2.7182818,6.2831853/
c
c
      w = twopi*f
      tdelay = delay
      if(kstrtd .gt. 0) go to 20
c
c        initialization of constants.
c
      go to (11,12,13,14,15,15,16), isorfn
      stop ' isorfn ng in fsorce'
c
c           source function # 1.  s(w)=flat, s(t)=spike.  amp(t)=amp(w)/
c
 11   a = ask ('s(w) = a, s(t) = spike of amp a/dt. a= ')
      go to 20
c
c           source function # 2.  triangle of width t, amplitude a.  spe
c        is s(w) = (at/2)*sinc(wt/4)**2*exp(-iwt/2).  it peaks at w = 0,
c        where s(w) = at/2.
c
   12 write(ounit,110)
  110 format(1x,'s(t)=triangle of width t. s(w)=sinc sqrd')
      t= ask('width, t (sec)= ')
      atmp = ask ('amp (in time or freq, +/-) = ')
      if (atmp .gt. 0.) a = atmp*t/2.
      if (atmp .lt. 0.) a = -atmp
      go to 20
c
c           source function # 3.  non-oscillating pulse, bell-shaped spe
c        centered at 0.  s(t)=atexp(-bt), s(w)=a/(b+iw)**2.  max amp in
c        is amp in freq*b/e.  max amp in time is at t =  1/b, at which s
c        a/(b*e).  max in freq is at w = 0, where s(w) = a/b**2.
c
   13 write(ounit,111)
  111 format(1x,'non-oscillating pulse. bell-shaped spectrum',
     *          ' centered at 0')
      trise = ask ('rise time= ')
      b = 1./trise
      atmp = ask ('amp (in time or freq, +/-) = ')
      if (atmp .gt. 0.) a = b*e*atmp
      if (atmp .lt. 0.) a = -b*b*atmp
      go to 20
c
c           source function # 4.  damped sinusoid.  s(t) = aexp(-bt)sin(
c
 14   fo = ask ('damped sinusoid. freq fo = ')
      wo = twopi*fo
      b = ask ('decay, if other than wo/5 ')
      if (b .eq. 0.) b = wo/5.
      atmp = ask ('amp (in time or freq, +/-) = ')
      if (atmp .gt. 0.) tmax = atan(wo/b)/wo
      if (atmp .gt. 0.) a = atmp/(exp(-b*tmax)*sin(wo*tmax))
      if (atmp .lt. 0.) a = -2.*b*atmp
      go to 20
   15 trap(1)=ask('trapezoid.  rise time= ')
      trap(2)=ask('falloff time= ')
      trap(3)=ask('total duration= ')
      trap(4)=ask('amplitude= ')
      go to 20
c
c   source function #4  gaussian
c
   16 a=ask('gaussian function exp(-w*w/4*a*a) a = ')
c
c
 20   go to (21,22,23,24,25,25,26), isorfn
 21   fsorce = cmplx(a, 0.)
      go to 30
 22   if(w.gt.1.e-06) go to 225
      fsorce=cmplx(a,0.)
      tdelay=tdelay+t/2.
      go to 30
 225  fsorce = cmplx(a*(sinc(w*t/4.))**2,0.)
      tdelay = tdelay + t/2.
      go to 30
 23   fsorce = cmplx(a, 0.)/cmplx(b**2-w**2, 2.*w*b)
      go to 30
 24   fsorce = cmplx(a*wo, 0.)/cmplx(b**2+wo**2-w**2, 2.*b*w)
      go to 30
   25 if(w.gt.1e-06) go to 31
      fsorce=cmplx((trap(4)/2.)*(2.*trap(3)-trap(2)-trap(1)),0.)
      go to 30
   26 gauss=-w*w/(4.*a*a)
      fsorce=cmplx(exp(gauss),0.)
      go to 30
   31 ral=(cos(w*trap(1))-1.)/trap(1) +
     *    (cos(w*(trap(3)-trap(2)))-cos(w*trap(3)))
     *    /trap(2)
      aim=sin(w*trap(1))/trap(1) +
     *    (sin(w*(trap(3)-trap(2)))-sin(w*trap(3)))
     *    /trap(2)
      fac=trap(4)/(w*w)
      fsorce=cmplx(fac*ral,-fac*aim)
c
c        apply a time delay by shift theorem
c
 30   if(tdelay .ne. 0.) fsorce = fsorce*exp(cmplx(0., -w*tdelay))
      kstrtd = 1
      return
      end
