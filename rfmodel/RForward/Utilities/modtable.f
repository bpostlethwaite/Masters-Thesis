      program modstat

      parameter(maxl = 50, maxfil = 100)
      dimension alfm(maxl),betm(maxl),rhom(maxl),thikm(maxl),h(maxl)
      character*32 namfil,title,fil(maxfil)
      character*32 tempfn,fileout
      common /innout/inunit,ounit
      integer inunit,ounit,oun2
      integer blank

      inunit = 5
      ounit = 6
      oun2 = 8

      write(ounit,*) 'MODTable - Input filename:'
      read(inunit,'(a)') namfil

c     write the troff/tbl information
c      for the table
c
      write(ounit,3000)
      write(ounit,3002)
      write(ounit,3004)
      write(ounit,3006)
      write(ounit,3006)
      write(ounit,3010)
      write(ounit,3012)
      write(ounit,3014)
      write(ounit,3016)
      write(ounit,3018)

      tempfn = namfil
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
      
c     convert layer thicknesses to depths
      
      h(1) = 0.
      tdpth = 0.
      do 2 i2 = 2,nlyrs
	 itemp = i2 - 1
	 tdpth = tdpth + thikm(itemp)
	 h(i2) = tdpth
2     continue
c
c	output the model

      do 1963 i1 = 1, nlyrs
1963  write(ounit, 2000) betm(i1),alfm(i1),rhom(i1),h(i1)


c2000  format(a12,',',6(f4.2,','),f4.1,',',6(f4.2,','),f4.2)
2000  format(4(f6.2,','))
3000  format('.TS')
3002  format('center tab(,) ;')
3004  format('c',/,'cb s s s s',/,'c')
3006  format('c | c | c | c ')
3010  format('n | n | n | n  .')
3012  format('=',/,/,'Velocity Structure',/,/,'=')
3014  format('S Velocity, P Velocity, Density, Depth')
3016  format('(km/sec),(km/sec),(g/cc),(km)')
3018  format('_')
3100  format('=')
3102  format('.TE')

      write(ounit,3100)
      write(ounit,3102)
      
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
