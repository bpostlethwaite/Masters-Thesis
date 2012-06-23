      parameter (max=5300)
      dimension x(max),h(210),y(max),env(max)
      integer stdin,stdout
      character*32 ifil,outfl
      data pi/3.1415926536/
c
c     Calculate the envelope of a function
c       base on a code to perform hilbert transforms
c
c     program to calculate the hilbert
c     transform of a ftn of arbitrary length
c     ( < max pts) in the time domain.
c
c     the transform is found by convolving the
c     trace with a 201 point fir filter
c     the filter impulse response is obtained
c     by windowing an ideal hilbert transformer
c     impulse response with a hamming window.
c  
c      x = input sac time series
c      y = hilbert transform of x
c      h = FIR hilbert transform filter
c
      stdin = 5
      stdout = 6
c
      call zero(max,x)
      call zero(210,h)
      call zero(max,y)
c
c     input the trace to be filtered.
c
      write(stdout,*) 'input file to be filtered: '
      read(stdin,'(a)') ifil
      call rsac1(ifil,x,lx,bx,dx,5000,nerr)
c
c     compute the filter coefficients
c
      do 1 i=1,201
      k=i-101
      fk=float(k)
      if(k.eq.0)fk=.00001
      a=.54+.46*cos(pi*fk/100.)
c
c     fk*dx .eq. time
c
      b=1./(pi*fk)
      c=float((1-(-1)**k))
      h(i)=a*b*c
1     continue
c
c     convolve the filter response and the input trace
c
      ly=lx+201
      do 2 i=1,lx
      do 2 j=1,201
      kk=i+j-1
2     y(kk)=y(kk)+x(i)*h(j)
c
c     write the output file.
c
c     adjust time of convolved trace to allign
c     with input arrivals.
c
      by=bx-100.0*dx
c
c     Compute the envelope = sqrt(x*x + y*y)
c     x = time series
c     y = hilbert transfrom
c
      do 3 i3=1,lx
	 i3m = i3+100
	 env(i3) = x(i3)*x(i3)+y(i3m)*y(i3m)
	 env(i3) = sqrt(env(i3))
3     continue
c
      write(stdout,*) ' output file name: '
      read(stdin,'(a)') outfl
      call wsac1(outfl,env,lx,bx,dx,nerr)
c     call wsac1(outfl,y,ly,by,dx,nerr)
      stop
      end
      subroutine zero(lz,z)
      dimension z(lz)
      if(lx .le. 0) return
      do 1 i=1,lz
1     z(i)=0.0
      return
      end
