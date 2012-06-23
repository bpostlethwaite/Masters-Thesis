      subroutine getseis( ns, seis, ntmax, nsmax, dt, dura, dly, gauss, 
&      p, nt, porsv )
      integer ns, ntmax, nsmax
      integer nt(nsmax)
      real seis(ntmax,nsmax)
      real dt(nsmax), dura(nsmax), dly(nsmax), gauss(nsmax), p(nsmax)
      logical porsv(nsmax)
      logical yesno
      character*80 sacfil
      write(*,*) 'Enter number of seismograms: '
      read (*,*) ns
      do 23000 i = 1, ns 
         if(.not.( i .gt. nsmax ))goto 23002
            goto 23001
23002    continue
         write(*,*) 'Enter sac file name: '
         read(*,*) sacfil
         write(*,*) 'Enter the horizontal slowness: '
         read(*,*) p(i)
         write(*,*) 'Enter the delay: '
         read(*,*) dly(i)
         write(*,*)'Enter the gaussian width factor:'
         read(*,*) gauss(i)
c
         write(*,*) 
&         '**********************************************************'
         write(*,*)'Read in:'
         write(*,99)
         write(*,100)i, sacfil, p(i), dly(i), gauss(i)
99       format(2x,'i',2x,'name',15x,'p',5x,'tdelay',4x,'gauss')
100      format(1x,i2.2,2x,a18,1x,f5.3,1x,f8.3,1x,f5.2)
c
c  porsv(i) = yesno('P wave(y) or SV wave(n): ')
c
         call rsac1(sacfil, seis(1,i), nt(i), b, dt(i), ntmax, nerr)
c
         dura(i) = dt(i) * ( nt(i) - 1 )
c  call getfhv('USER2', gauss(i), nerr)
         if(.not.(nt(i) .gt. 512))goto 23004
            write(*,'(/,1x,a32,1x,a32)') 
&            'ERROR! Too many points in file:',sacfil
            write(*,*) ' Try decimating the waveform.'
            write(*,*)' '
23004    continue
         write(*,*) 
&         '**********************************************************'
23000    continue
23001 continue
      return
      end
