subroutine wrtsoln( nlyrs, alpha, beta, rho, thk, iter, invnum )
{

parameter ( NU = 7 )
integer nlyrs,iter

real alpha(nlyrs), beta(nlyrs), rho(nlyrs), thk(nlyrs)

real j1,j2,j3,j4,pr,pos
integer i,il,invnum
character*80 filnam, modnam
character*4 itc

j1 = 0.0; j2 = 0.0; j3 = 0.0; j4 = 0.0
write(itc,'(i2.2,i2.2)') invnum,iter
filnam = 'inv.mdl.' // itc
open(unit=NU,file=filnam)

modnam = 'inversion model ' // itc
write(NU,'(i3,a32)') nlyrs, modnam

do i = 1, nlyrs {
   pos = alpha(i)/beta(i)
   pr = vpovs_to_pr(pos)
   write(NU,'(i3,1x,9f8.4)') i, alpha(i),beta(i),rho(i),thk(i),j1,j2,j3,j4,pr
}

close(NU)

return
end
}
