      subroutine putseis( ns, seis, ntmax, nsmax, dt, dura, dly, gauss, 
&      p, nt, porsv, iter, invnum )
      integer ns, ntmax, nsmax, iter, invnum
      integer nt(nsmax)
      real seis(ntmax,nsmax)
      real dt(nsmax), dura(nsmax), dly(nsmax), gauss(nsmax), p(nsmax)
      logical porsv(nsmax)
      logical yesno
      character*80 sacfil
      character*2 ext
      character*4 iext
      do 23000 i = 1, ns 
         if(.not.( i .gt. nsmax ))goto 23002
            goto 23001
23002    continue
         write(ext,'(i2.2)') i
         write(iext,'(i2.2,i2.2)') invnum, iter
c  sacfil="wvfrm" // ext // "." // iext
         sacfil="wvfrm" // ext
         call wsac1(sacfil, seis(1,i), nt(i), 0., dt(i), nerr)
23000    continue
23001 continue
      return
      end
