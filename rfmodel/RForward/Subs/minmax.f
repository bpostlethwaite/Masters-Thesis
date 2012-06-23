      subroutine minmax(x,npts,min,max,mean)
      dimension x(1)
      real min,max,mean
      min=9.0e+19
      max=-9.0e+19
      mean=0.
      do 1 i=1,npts
           if(x(i).gt.max) max=x(i)
           if(x(i).lt.min) min=x(i)
           mean=mean + x(i)
    1 continue
      mean=mean/float(npts)
      return
      end
