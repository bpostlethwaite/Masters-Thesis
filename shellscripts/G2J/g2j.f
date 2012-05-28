      program g2j
      integer iyear,idat,imon,jday
 22   read(05,*,end=999)iyear,imon,idat
        call get_jday(iyear,imon,idat,jday)
        write(06,*)iyear,jday
        go to 22
 999  continue
      stop 
      end

      subroutine get_jday(iyear,imon,iday,jday)
c
      ileap=0
      if((iyear/4)*4.eq.iyear) ileap=1
      if((iyear/400)*400.eq.iyear)ileap=0
      if(iyear.eq.2000)ileap=1

      if(imon.eq.1) then
         jday=iday
      elseif(imon.eq.2)then
         jday=31+iday
      elseif(imon.eq.3)then
         jday=59+ileap+iday
      elseif(imon.eq.4)then
         jday=90+ileap+iday
      elseif(imon.eq.5)then
         jday=120+ileap+iday
      elseif(imon.eq.6)then
         jday=151+ileap+iday
      elseif(imon.eq.7)then
         jday=181+ileap+iday
      elseif(imon.eq.8)then
         jday=212+ileap+iday
      elseif(imon.eq.9)then
         jday=243+ileap+iday
      elseif(imon.eq.10)then
         jday=273+ileap+iday
      elseif(imon.eq.11)then
         jday=304+ileap+iday
      else
         jday=334+ileap+iday
      endif

      return
      end
