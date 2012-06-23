      program vsampl

      parameter(maxl = 50)
      parameter(max = 5000)
      dimension alfm(maxl),betm(maxl),rhom(maxl),thikm(maxl),h(maxl)
      dimension alfs(max),bets(max),rho(max)
      character*32 modela,title
      common /innout/inunit,ounit
      integer inunit,ounit,oun2

      inunit = 5
      ounit = 6
      oun2 = 8

      write(ounit,*)'input velocity model:'
      read(inunit,'(a)')modela

      open(unit=oun2,file=modela)
      rewind=oun2
      read(oun2,100)nlyrs,title
100   format(i3,1x,a32)
      do 1 i1 = 1,nlyrs
	 read(oun2,110)idum,alfm(i1),betm(i1),rhom(i1),thikm(i1),
     *                 dum1,dum2,dum3,dum4,dum5
1     continue

110   format(i3,1x,9f8.4)
      close(unit=oun2)

c     call rdlyrs(modela,nlyrs,title,alfm,betm,rhom,thikm,
c    *            dum1,dum2,dum1,dum2,-1,ier)
      
c     convert layer thicknesses to depths
      
      tdpth = 0.
      do 2 i2 = 2,nlyrs
	 itemp = i2 - 1
	 tdpth = tdpth + thikm(itemp)
	 h(i2) = tdpth
2     continue
      h(1) = 0.

      write(ounit,*)'total model thickness is',h(nlyrs)

      write(ounit,*) 'input sample interval (km):'
      read(inunit,*) dth

      nsmp = h(nlyrs)/dth

      write(ounit,*) 'number of layers in output file:',nsmp

      sdpth = 0.
      j = 2
      do 3 i3 = 1,nsmp
	 sdpth = float(i3 - 1)*dth
	 if(sdpth .ge. h(j))j = j+1
	 alfs(i3) = alfm(j-1)
3     continue

      call wsac1('output ',alfs,nsmp,0.,dth,nerr)

      stop
      end
