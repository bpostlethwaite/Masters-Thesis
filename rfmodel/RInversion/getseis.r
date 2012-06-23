subroutine getseis( ns, seis, NTMAX, NSMAX, dt, dura, dly, gauss, p, nt, porsv )
{
integer ns, NTMAX, NSMAX
integer nt(NSMAX)
real seis(NTMAX,NSMAX)
real dt(NSMAX), dura(NSMAX), dly(NSMAX), gauss(NSMAX), p(NSMAX)
logical porsv(NSMAX)
logical yesno
character*80 sacfil


write(*,*) 'Enter number of seismograms: '
read (*,*) ns

do i = 1, ns {
   if ( i > NSMAX ) break
   write(*,*) 'Enter sac file name: '
   read(*,*) sacfil
   write(*,*) 'Enter the horizontal slowness: '
   read(*,*) p(i)
   write(*,*) 'Enter the delay: '
   read(*,*) dly(i)
   write(*,*)'Enter the gaussian width factor:'
   read(*,*) gauss(i)
#
    write(*,*) '**********************************************************'
    write(*,*)'Read in:'
    write(*,99)  
    write(*,100)i, sacfil, p(i), dly(i), gauss(i)   
99  format(2x,'i',2x,'name',15x,'p',5x,'tdelay',4x,'gauss')
100 format(1x,i2.2,2x,a18,1x,f5.3,1x,f8.3,1x,f5.2)
#
#  porsv(i) = yesno('P wave(y) or SV wave(n): ')
#
   call rsac1(sacfil, seis(1,i), nt(i), b, dt(i), NTMAX, nerr)
#
   dura(i) = dt(i) * ( nt(i) - 1 )

#  call getfhv('USER2', gauss(i), nerr)

   if(nt(i) > 512)
   {
      write(*,'(/,1x,a32,1x,a32)') 'ERROR! Too many points in file:',sacfil
      write(*,*) ' Try decimating the waveform.'
      write(*,*)' '
   }
   write(*,*) '**********************************************************'

   }

return
end
}
