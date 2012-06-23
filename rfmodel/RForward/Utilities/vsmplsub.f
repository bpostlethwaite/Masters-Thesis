      subroutine vsmpl(alfm,thikm,modela,dth)
      parameter(maxl = 50)
      parameter(max = 5000)
      dimension alfm(maxl),betm(maxl),rhom(maxl),thikm(maxl),h(maxl)
      dimension alfs(max),bets(max),rho(max)
      character*32 modela,title
      common /innout/inunit,ounit
      integer inunit,ounit,oun2

      inunit = 5
      ounit = 6
c
c     convert layer thicknesses to depths
      
      tdpth = 0.
      do 2 i2 = 2,nlyrs
	 itemp = i2 - 1
	 tdpth = tdpth + thikm(itemp)
	 h(i2) = tdpth
2     continue
      h(1) = 0.

      nsmp = h(nlyrs)/dth

      write(ounit,*) 'number of layers in output file:',nsmp

      sdpth = 0.
      j = 2
      do 3 i3 = 1,nsmp
	 sdpth = float(i3 - 1)*dth
	 if(sdpth .ge. h(j))j = j+1
	 alfs(i3) = alfm(j)
3     continue

      call wsac1('output ',alfs,nsmp,0.,dth,nerr)

      stop
      end
