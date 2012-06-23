subroutine putpartl( amat, NTMAX, NLMAX, dt, nt, nlyrs ) 
{
integer NTMAX, NLMAX
integer nt
real amat(NTMAX,NLMAX)
real dt,xtra
character*80 sacfil
character*2 ext



do i = 1, nlyrs {
   if ( i > NLMAX ) break
   write(ext,'(i2.2)') i
   sacfil = "partl" // ext
   xtra = float(i)
   call sacout(sacfil, amat(1,i), nt, 0., dt, xtra)
   }

return
end
}
