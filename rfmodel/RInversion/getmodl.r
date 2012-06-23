subroutine getmodl( nlyrs, alpha, beta, rho, thk, NLMAX )
{

parameter ( NU = 7 )
integer nlyrs, NLMAX

real alpha(NLMAX), beta(NLMAX), rho(NLMAX), thk(NLMAX)

real j1,j2,j2,j4
integer i,il
character*80 filnam, modnam
external blank
integer blank

write(*,*) 'starting model file: '
read(*,'(a80)') modnam
i = blank(modnam)
filnam = modnam(1:i)
open(unit=NU,file=filnam)
rewind(NU)

read(NU,'(i3,a32)') nlyrs, modnam

do i = 1, nlyrs {
   read(NU,'(i3,1x,8f8.2)') il, alpha(i),beta(i),rho(i),thk(i),j1,j2,j3,j4
}

close(NU)

return
end
}
