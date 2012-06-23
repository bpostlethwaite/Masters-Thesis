      integer function lpyr(year)
c
c function lpyr determines if year
c is a leap year.
c
c this function uses the intrinsic
c function mod. if your machine
c does not supply this function,
c make one -
c mod(i,j) = iabs(i - (i/j)*j)
c
c
c calls:
c   mod - intrinsic funtion
c
c      programmed by madeleine zirbes
c         september 15,1980
c
c year - input
      integer year
      if(.not.(mod(year,400).eq.0))goto 23000
         lpyr = (1)
         return
23000 continue
      if(.not.(mod(year,4) .ne. 0))goto 23002
         lpyr = (0)
         return
23002 continue
      if(.not.(mod(year,100).eq.0))goto 23004
         lpyr = (0)
         return
23004 continue
      lpyr = (1)
      return
      end
