      program vstack
c
c
c   program stacks equally spaced sac files 
c      filenames to be stacked are
c      stored in an external file
c
c
      parameter(max = 5000)
      parameter(maxfil = 75)
      dimension x(max),sum(max),wt(maxfil),dt(maxfil),sumsq(max),sd(max)
      real lower(max),upper(max)
      dimension npa(maxfil)
      integer blank
      character file(maxfil)*32,sout*32,sdfl*32,slower*32,supper*32
      character*1 awt,nowt
      character*32 namfil
      logical weigh
      integer inunit,ounit
c
      inunit=5
      ounit=6
      ifil = 7

      do 1963 i19 = 1,max
	 lower(i19) = 100.
	 upper(i19) = 0.
1963  continue


      dtol = .005
      nowt = 'n'
      supper = '                                '
      slower = '                                ' 
      sdfl = '                                ' 

      write(ounit,*) 'Input filename for stack list:'
      read(inunit,'(a)') namfil
      open(unit = ifil, file = namfil)
      rewind(ifil)
      
      nstack = 1
  1   continue

      read(ifil,'(a)',end = 2) file(nstack)
      nstack = nstack + 1
      goto 1
 
  2   continue
      nstack = nstack - 1

      if(nstack .eq. 0) then
	 write(ounit,*) 'No filenames in list(?)'
	 stop
      endif
     
      write(ounit,*) 'weight the files? (y) or (n)'
      read(inunit,1961) awt
 1961 format(a1)
      if(awt.eq.nowt) weigh = .false.
      do 3 i3=1,nstack
            if(weigh) then
	    write(ounit,101) file(i3)
  101       format('enter weight for ',a32)
            read(inunit,*) wt(i3)
         else
            wt(i3)=1.
         endif
    3 continue
      
      
      do 4 i4=1,nstack
         call zero(x,1,5000)
         call rsac1(file(i4),x,npts,beg,dt(i4),max,nerr)
         npa(i4)=npts
c
         do 5 i5=1,npts
    5       x(i5)=x(i5)*wt(i4)
         
	 
	 if(i4.ne.1) then
            do 7 i7=1,i4-1
                  if(abs(dt(i4)-dt(i7)).le.dtol) go to 7
                  write(ounit,102)dt(i4),file(i4),dt(i7),file(i7)
  102             format(' incompatible sample rates: dt = ',e15.6,
     *                  ' in ',a32,/,28x,'dt = ',e15.6,' in ',a32)
                  stop

    7       continue

         else
               write(ounit,*) 'stack output file:  '
	       read(inunit,'(a)') sout
               iblank=blank(sout)
               sdfl(1:iblank+4)=sout(1:iblank)//'_sd '
	       slower(1:iblank+4)=sout(1:iblank)//'_le '
	       supper(1:iblank+4)=sout(1:iblank)//'_ue '
               call zero(sum,1,5000)
               call zero(sumsq,1,5000)
         endif
c
c        sum the values and the square of the values
c
         do 8 i8=1,npts
            if(x(i8) .le. lower(i8)) lower(i8) = x(i8)
	    if(x(i8) .gt. upper(i8)) upper(i8) = x(i8)
	    sum(i8) = sum(i8) + x(i8)
            sumsq(i8) = sumsq(i8) + x(i8)*x(i8)
    8    continue

    4 continue
c
      call zero(x,1,max)
      call zero(sd,1,max)
c
c     compute the stack and the standard deviation
c      x = stack
c      sd = standard deviation
c
      do 12 i12=1,npts
         x(i12)=sum(i12)/float(nstack)
         sd(i12)=float(nstack)*sumsq(i12) - sum(i12)*sum(i12)
         sd(i12)=sd(i12)/(float(nstack)*float(nstack-1))
	 sd(i12)=sqrt(sd(i12))
   12 continue
c
      call wsac1(sout,x,npts,beg,dt(1),nerr)
      call wsac1(sdfl,sd,npts,beg,dt(1),nerr)
      call wsac1(slower,lower,npts,beg,dt(1),nerr)
      call wsac1(supper,upper,npts,beg,dt(1),nerr)
      stop
   14 write(ounit,104) file(i4)
  104 format(' no t0 in ',a32)
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
