      subroutine seisio(freq,peak,xr,xi,inout)
c     15-100 system
c     wwssn instrument constants from u. chandra, bssa 1970 vol 60
c     pp 539-563
c     peak magnifications are 350,700,1400,2800,5600
c
c     if inout = +1 response is put in
c     if inout = -1 response is removed
c
      if(freq.lt.0.005) freq = 0.005
    8 we = 6.2831853*freq
      index = (peak + 1.)/375.
      go to (1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,5),index
    1 fmag = 278.
      sigma = 0.003
      go to 6
    2 fmag = 556.
      sigma = 0.013
      go to 6
    3 fmag = 1110.
      sigma = 0.047
      go to 6
    4 fmag = 2190.
      sigma = 0.204
      go to 6
    5 fmag = 3950.
      sigma = 0.805
    6 zeta = 0.93
      zeta1=1.
      wn=.418879
      wn1 = .062831853
      ar= (we*we-wn*wn)*(we*we-wn1*wn1)-4.*zeta*zeta1*wn*wn1*(1.-sigma)
     1*we*we
             ai=2.*we*(zeta1*wn1*(wn*wn-we*we)+zeta*wn*(wn1*wn1-we*we))
      if(inout.eq.+1) go to 7
      factor = 1./(fmag*we*we*we)
      xr = - ai * factor
      xi = ar * factor
      return
    7 factor=fmag*we*we*we/(ai*ai + ar*ar)
      xr=-factor*ai
      xi=-factor*ar
      return
      end
