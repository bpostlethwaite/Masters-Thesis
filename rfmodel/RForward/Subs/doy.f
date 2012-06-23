      integer function doy (month,day,year)
c
c function doy determines the day of the
c year,given the month,da ad year.
c if month or day are illegal,the return
c value of the function is zero.
c
c
c calls:
c   lpyr
c
c      programmed by madeleine zirbes
c         september 15,1980
c
c month - input
      integer month
c day of month - input
      integer day
c year - input
      integer year
c function
      integer lpyr
      integer inc
      integer ndays(12)
      data ndays /0,31,59,90,120,151,181,212,243,273,304,334/
c
      if(.not.(month .lt.1 .or. month .gt. 12))goto 23000
         doy = (0)
         return
23000 continue
      if(.not.(day .lt. 1 .or. day .gt. 31))goto 23002
         doy = (0)
         return
23002 continue
      if(.not.(lpyr(year).eq.1 .and. month .gt. 2))goto 23004
         inc = 1
         goto 23005
c     else
23004    continue
         inc = 0
23005 continue
      doy = (ndays(month) + day + inc)
      return
      end
