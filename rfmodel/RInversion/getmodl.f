      subroutine getmodl( nlyrs, alpha, beta, rho, thk, nlmax )
      parameter ( nu = 7 )
      integer nlyrs, nlmax
      real alpha(nlmax), beta(nlmax), rho(nlmax), thk(nlmax)
      real j1,j2,j3,j4
      integer i,il
      character*80 filnam, modnam
      external blank
      integer blank
      write(*,*) 'starting model file: '
      read(*,'(a80)') modnam
      i = blank(modnam)
      filnam = modnam(1:i)
      open(unit=nu,file=filnam)
      rewind(nu)
      read(nu,'(i3,a32)') nlyrs, modnam
      do 23000 i = 1, nlyrs 
         read(nu,'(i3,1x,8f8.2)') il, alpha(i),beta(i),rho(i),thk(i),j1,
&         j2,j3,j4
23000    continue
      close(nu)
      return
      end
