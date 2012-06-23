      subroutine putpartl( amat, ntmax, nlmax, dt, nt, nlyrs )
      integer ntmax, nlmax
      integer nt
      real amat(ntmax,nlmax)
      real dt,xtra
      character*80 sacfil
      character*2 ext
      do 23000 i = 1, nlyrs 
         if(.not.( i .gt. nlmax ))goto 23002
            goto 23001
23002    continue
         write(ext,'(i2.2)') i
         sacfil = "partl" // ext
         xtra = float(i)
         call sacout(sacfil, amat(1,i), nt, 0., dt, xtra)
23000    continue
23001 continue
      return
      end
