      subroutine g1(a,b,cos,sin,sig)
c
c   from lawson and hanson
c
      zero=0.
      one=1.
      if(abs(a).le.abs(b)) go to 10
      xr=b/a
      yr=sqrt(one+xr**2)
      cos=sign(one/yr,a)
      sin=cos*xr
      sig=abs(a)*yr
      return
   10 if(b) 20,30,20
   20 xr=a/b
      yr=sqrt(one+xr**2)
      sin=sign(one/yr,b)
      cos=sin*xr
      sig=abs(b)*yr
      return
   30 sig=zero
      cos= zero
      sin=one
      return
      end
