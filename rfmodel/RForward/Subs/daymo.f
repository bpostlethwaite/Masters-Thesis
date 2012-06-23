      integer function daymo (dofy,month,day,year)
c
c function daymo determines the month and day
c of the month,given the year and day of year.
c it returns 1 if it was successful,0 otherwise.
c if dofy is not within legal limits,month and
c day will be returned as zero.
c
c
c calls:
c   lpyr
c
c      programmed by madeleine zirbes
c         september 15,1980
c
c day of year - input
      integer dofy
c month - output
      integer month
c day of month - output
      integer day
c year - input
      integer year
c
c day of year
      integer iday
c function
      integer lpyr
c number of days in month
      integer mdays(12)
      data mdays/31,28,31,30,31,30,31,31,30,31,30,31/
c
      iday = dofy
      if(.not.(iday.lt.1))goto 23000
         month = 0
         day = 0
         daymo = (0)
         return
c
23000 continue
      if(.not.(lpyr(year).eq.1))goto 23002
         mdays(2) = 29
         goto 23003
c     else
23002    continue
         mdays(2) = 28
23003 continue
c
      do 23004 month = 1,12
         day = iday
         iday = iday - mdays(month)
         if(.not.(iday.le.0))goto 23006
            daymo = (1)
            return
23006    continue
23004    continue
c
      month = 0
      day = 0
      daymo = (0)
      return
c
      end
