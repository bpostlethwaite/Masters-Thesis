      subroutine max(x,n,xmax)
      dimension x(1)
      xmax=0.
      do 1 i=1,n
         if(abs(x(i)).gt.xmax) xmax=abs(x(i))
    1 continue
      return
      end
