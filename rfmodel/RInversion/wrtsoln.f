      subroutine wrtsoln( nlyrs, alpha, beta, rho, thk, iter, invnum )
      parameter ( nu = 7 )
      integer nlyrs,iter
      real alpha(nlyrs), beta(nlyrs), rho(nlyrs), thk(nlyrs)
      real j1,j2,j3,j4,pr,pos
      integer i,il,invnum
      character*80 filnam, modnam
      character*4 itc
      j1 = 0.0
      j2 = 0.0
      j3 = 0.0
      j4 = 0.0
      write(itc,'(i2.2,i2.2)') invnum,iter
      filnam = 'inv.mdl.' // itc
      open(unit=nu,file=filnam)
      modnam = 'inversion model ' // itc
      write(nu,'(i3,a32)') nlyrs, modnam
      do 23000 i = 1, nlyrs 
         pos = alpha(i)/beta(i)
         pr = vpovs_to_pr(pos)
         write(nu,'(i3,1x,9f8.4)') i, alpha(i),beta(i),rho(i),thk(i),j1,
&         j2,j3,j4,pr
23000    continue
      close(nu)
      return
      end
