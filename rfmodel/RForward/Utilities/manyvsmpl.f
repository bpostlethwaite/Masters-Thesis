      program manyvsampl

      parameter(maxl = 50, maxfil =100, max = 2500)
      dimension alfm(maxl),betm(maxl),rhom(maxl),thikm(maxl),h(maxl)
      dimension alfs(max),bets(max),rho(max)
      character*32 namfil,title,fil(maxfil)
      character*32 tempfn,fileout
      common /innout/inunit,ounit
      integer inunit,ounit,oun2
      integer blank

      inunit = 5
      ounit = 6
      oun2 = 8

      write(ounit,*) 'Input filename for stack list:'
      read(inunit,'(a)') namfil
      open(unit = oun2, file = namfil)
      rewind(oun2)

      nfile = 1
 1000 continue

      read(oun2,'(a)',end = 2000) fil(nfile)
      nfile = nfile + 1
      goto 1000

2000  continue
      close(unit=oun2)

      nfile = nfile - 1

      do 4 i4 = 1, nfile

      tempfn = fil(i4)
      iblank = blank(tempfn)
      open(unit=oun2,file=tempfn)
      rewind=oun2
      read(oun2,100)nlyrs,title
100   format(i3,1x,a32)
      do 1 i1 = 1,nlyrs
	 read(oun2,110)idum,alfm(i1),betm(i1),rhom(i1),thikm(i1),
     *                 dum1,dum2,dum3,dum4,dum5
1     continue

110   format(i3,1x,9f8.4)
      close(unit=oun2)
      

c     call rdlyrs(tempfn,nlyrs,title,alfm,betm,rhom,thikm,
c    *            dum1,dum2,dum1,dum2,-1,ier)
      
c     convert layer thicknesses to depths
      
      tdpth = 0.
      do 2 i2 = 2,nlyrs
	 itemp = i2 - 1
	 tdpth = tdpth + thikm(itemp)
	 h(i2) = tdpth
2     continue
      h(1) = 0.


c     smapling interval for velocity models
c
      dth = 0.1

      nsmp = h(nlyrs)/dth

      sdpth = 0.
      j = 2
      do 3 i3 = 1,nsmp
	 sdpth = float(i3 - 1)*dth
	 if(sdpth .ge. h(j))j = j+1
	 alfs(i3) = alfm(j-1)
3     continue

      fileout = '                                '
      fileout(1:iblank+1) = tempfn(1:iblank)//'s'
      call wsac1(fileout,alfs,nsmp,0.,dth,nerr)
4     continue
      stop
      end
      integer function blank(file)
      character file*32
      do 1 i=1,32
      if(file(i:i).ne.' ') goto 1
      blank=i-1
      return
1     continue
      write(1,100) file
100   format(' no blanks found in ',a32)
      blank = 0
      return
      end
