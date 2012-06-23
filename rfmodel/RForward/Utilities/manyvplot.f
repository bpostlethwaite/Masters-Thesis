      program manyvplot

      parameter(maxl = 50, maxfil = 100, maxpt = 2 * maxl)
      dimension alfm(maxl),betm(maxl),rhom(maxl),thikm(maxl)
      dimension x(maxpt),y(maxpt)
      character*32 namfil,title,fil(maxfil)
      character*32 tempfn,fileout
      common /innout/inunit,ounit
      integer inunit,ounit,oun2
      integer blank

      inunit = 5
      ounit = 6
      oun2 = 8

      write(ounit,*) 'MANYVPLOT - Input filename (contains list):'
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
      
      x(1) = 0.
      y(1) = alfm(1)
      ij = 1
      do 50 i50 = 1,nlyrs-1
	  v = alfm(i50)
	  v2 = alfm(i50+1)
	  ij = ij + 1
	  x(ij)=x(ij-1)-thikm(i50)
	  y(ij)=v
	  x(ij+1)=x(ij)
	  y(ij+1)=v2
	  ij=ij+1
50    continue

      ij = ij+1
      x(ij)=x(ij-1)-30.
      y(ij)=alfm(nlyrs)
     
     
      fileout = '                                '
      fileout(1:iblank+3) = tempfn(1:iblank)//'.vp'


      call wsac2(fileout,x,ij,y,nerr)


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
