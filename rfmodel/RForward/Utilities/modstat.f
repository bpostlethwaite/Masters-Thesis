      program modstat

      parameter(maxl = 50, maxfil = 100)
      dimension alfm(maxl),betm(maxl),rhom(maxl),thikm(maxl),h(maxl)
      character*32 namfil,title,fil(maxfil)
      character*32 tempfn,fileout
      integer stdin,stdout,inunit,ounit,inunit1
      integer blank

      stdin = 5
      stdout = 6
      ounit = 7
      inunit1 = 8

      write(stdout,*) 'MODSTAT - Input, filename with list:'
      read(stdin,'(a)') namfil
      write(stdout,*) 'Output file name, please:'
      read(stdin,'(a)') fileout 
      open(unit = inunit1, file = fileout)
      rewind(inunit1)

c     write the troff/tbl information
c      for the table
c
      write(ounit,3000)
      write(ounit,3002)
      write(ounit,3004)
      write(ounit,3006)
      write(ounit,3008)
      write(ounit,3010)
      write(ounit,3012)
      write(ounit,3014)
      write(ounit,3016)
      write(ounit,3018)

      Pn2velocity = 7.8
      ucrust2thick = 12.


      nfile = 1
 1000 continue

      read(inunit1,'(a)',end = 6000) fil(nfile)
      nfile = nfile + 1
      goto 1000

6000  continue
      close(unit=inunit1)

      nfile = nfile - 1

      do 10 i10 = 1, nfile

      tempfn = fil(i10)
      iblank = blank(tempfn)
      open(unit=inunit1,file=tempfn)
      rewind=inunit1
      read(inunit1,100)nlyrs,title
100   format(i3,1x,a32)
      do 1 i1 = 1,nlyrs
	 read(inunit1,110)idum,alfm(i1),betm(i1),rhom(i1),thikm(i1),
     *                 dum1,dum2,dum3,dum4,dum5
1     continue

110   format(i3,1x,9f8.4)
      close(unit=inunit1)
      
c     convert layer thicknesses to depths
      
      tdpth = 0.
      do 2 i2 = 2,nlyrs
	 itemp = i2 - 1
	 tdpth = tdpth + thikm(itemp)
	 h(i2) = tdpth
2     continue
      h(1) = 0.

c     COMPUTE MODEL STATISTICS

      thick2u = 0.
      vu2max = 0.
      vu2min = 9.
      tt2upper = 0.

      thick2l = 0.
      vl2max = 0.
      vl2min = 9.
      tt2lower = 0.

      thick2crust = 0.
      vc2max = 0.
      vc2min = 9.
      tt2crust = 0.

      thick2mantle = 0.
      vmn2max = 0.
      vmn2min = 9.
      tt2mantle = 0.

      thick2model = 0.
      vm2max = 0.
      vm2min = 9.
      tt2model = 0.

      inmantle = 0
c
      do 3 i3 = 1,nlyrs
c
c     UPPER crustal average velocity
c      and extreme velocities
c
c     the average velocity is the travel time
c       divided by the thickness
c     keep track of travel time and thickness

      if(h(i3).le. ucrust2thick) then
	 tt2upper = tt2upper + thikm(i3)/alfm(i3)
	 thick2u = thick2u + thikm(i3)

	 if(alfm(i3) .ge. vu2max) vu2max = alfm(i3)
	 if(alfm(i3) .le. vu2min) vu2min = alfm(i3)

      end if

c     CRUSTAL THICKNESS (defined by first depth
c                        the Pn velocity is reached)
c      and extreme velocities
c
      if(alfm(i3) .ge. Pn2velocity) inmantle=1

      if(inmantle .eq.  0) then

	 tt2crust = tt2crust + thikm(i3)/alfm(i3)
         thick2crust = thick2crust + thikm(i3)

	 if(alfm(i3) .ge. vc2max) vc2max = alfm(i3)
	 if(alfm(i3) .le. vc2min) vc2min = alfm(i3)

c	 LOWER CRUST
         
	 if(h(i3) .gt. ucrust2thick) then
	   tt2lower = tt2lower + thikm(i3)/alfm(i3)
	   thick2l = thick2l + thikm(i3)
	   if(alfm(i3) .ge. vl2max) vl2max = alfm(i3)
	   if(alfm(i3) .le. vl2min) vl2min = alfm(i3)
	 endif
      
      end if
c     
c     MANTLE

      if(inmantle .eq.  1) then

	 tt2mantle = tt2mantle + thikm(i3)/alfm(i3)
	 thick2mantle = thick2mantle + thikm(i3)
	 if(alfm(i3) .ge. vmn2max) vmn2max = alfm(i3)
	 if(alfm(i3) .le. vmn2min) vmn2min = alfm(i3)
      end if 

c     THE ENTIRE Model
c
      tt2model = tt2model + thikm(i3)/alfm(i3)
      thick2model = thick2model + thikm(i3)
      if(alfm(i3) .ge. vm2max) vm2max = alfm(i3)
      if(alfm(i3) .le. vm2min) vm2min = alfm(i3)

3     continue

      avg2upper = thick2u/tt2upper
      avg2lower = thick2l/tt2lower
      avg2crust = thick2crust/tt2crust
      avg2mantle = 0.
      if(inmantle .eq.1)then
	 if(vmn2max .eq. vmn2min)then
	  avg2mantle = vmn2max
	 else
	  avg2mantle = thick2mantle/tt2mantle
	 end if
      end if
      avg2model = thick2model/tt2model

c     Output the statistics

      write(ounit,2000) tempfn,avg2upper,vu2max,vu2min
     2            ,avg2lower,vl2max,vl2min
     3            ,thick2crust,avg2crust,tt2crust
     4            ,avg2mantle,vmn2max,vmn2min
     5            ,avg2model,tt2model
2000  format(a12,',',6(f4.2,','),f4.1,',',6(f4.2,','),f4.2)
3000  format('.TS')
3002  format('tab(,) ;')
3004  format('c',/,'cb s s s s s s s s s s s s s s',/,'c')
3006  format('c | c s s | c s s | c s s | c s s | c s')
3008  format('c | c c c | c c c | c c c | c c c | c c')
3010  format('l | n n n | n n n | n n n | n n n | n n  .')
3012  format('=',/,/,'Inversion Results',/,/,'=')
3014  format('Model,Upper Crust,Lower Crust,Total Crust,Mantle,Model')
3016  format(',avg,max,min,avg,max,min,thick,avg,TT,avg,max,min,avg,TT')
3018  format('_')
3100  format('=')
3102  format('.TE')
4000  format('Crustal thickness defined by velocities less than ',
     3f4.2,' km/sec.')
4002  format('.br',/,'Upper crust defined as top ',f4.1,' kilometers.')

c

10     continue

      write(ounit,3100)
      write(ounit,3102)
      write(ounit,4000)Pn2velocity
      write(ounit,4002)thick2u
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
