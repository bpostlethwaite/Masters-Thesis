      program j2g
      real eps
      integer jday,idat,imon,iyear 
      integer leap
      read(05,*)iyear,jday
      leap=0
      eps=0.01
      if(abs((float(iyear/4)-iyear/4.)).lt.eps) leap=1
      call day(leap,jday,idat,imon)
      write(06,*)idat,imon
      stop
      end
