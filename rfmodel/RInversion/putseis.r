subroutine putseis( ns, seis, NTMAX, NSMAX, dt, dura, dly, gauss, p, nt, porsv, iter, invnum )
{
integer ns, NTMAX, NSMAX, iter, invnum
integer nt(NSMAX)
real seis(NTMAX,NSMAX)
real dt(NSMAX), dura(NSMAX), dly(NSMAX), gauss(NSMAX), p(NSMAX)
logical porsv(NSMAX)
logical yesno
character*80 sacfil
character*2 ext 
character*4 iext



do i = 1, ns {
   if ( i > NSMAX ) break
   write(ext,'(i2.2)') i
   write(iext,'(i2.2,i2.2)') invnum, iter
#  sacfil="wvfrm" // ext // "." // iext
   sacfil="wvfrm" // ext 
   call wsac1(sacfil, seis(1,i), nt(i), 0., dt(i), nerr)
   }

return
end
}
