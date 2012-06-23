      subroutine g2(cos,sin,x,y)
c
c   from lawson and hanson
c
      xr=cos*x+sin*y
      y=-sin*x+cos*y
      x=xr
      return
      end
