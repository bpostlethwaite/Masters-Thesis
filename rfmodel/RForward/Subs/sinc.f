      function sinc(x)
      integer ounit
      common /innout/ inunit,ounit
      if(abs(x).le.1.0e-08) go to 1
      sinc=sin(x)/x
      return
    1 sinc=0.
      write(ounit,100)
  100 format(' arg sinc = 0, sinc set to 0')
      return
      end
