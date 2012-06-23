      subroutine juli(yr,jday,month,iday,monum)
c
c     converts julian day to month dat,year
c       month in a3 format
c       iday = day of month
c       monum = number of month
c
      dimension mon(12),num(12)
      integer yr
      character mon*3,month*3
      data mon/'jan','feb','mar','apr','may','jun','jul','aug',
     *         'sep','oct','nov','dec'/,
     *     num/31,28,31,30,31,30,31,31,30,31,30,31/
      iday=jday
      ind=0
      do 1 i=1,12
         ind=ind + num(i)
         if(yr.ne.(yr/4)*4) go to 2
            if(i.ne.2) go to 2
              ind=ind+1
    2    if(iday.gt.ind) go to 1
            month=mon(i)
            iday=num(i)-(ind-iday)
            monum = i
            go to 3
    1 continue
    3 return
      end
