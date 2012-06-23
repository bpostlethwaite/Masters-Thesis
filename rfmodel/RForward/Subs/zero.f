      subroutine zero(x,start,end)
      dimension x(1)
      integer start,end
      do 1 i=start,end
    1 x(i)=0.
      return
      end
