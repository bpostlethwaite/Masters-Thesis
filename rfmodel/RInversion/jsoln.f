c
c  Added some truncation and some diagnostic output
c  Ammon June 18, 1993
c
c
      subroutine jsoln( a, ndat, npb, ip, b, not_used, s, sol, 
&      tfraction)
      integer ndat, not_used
      integer npb,ip, iused
      real a(ndat,ip), b(ndat), s(ip), sol(ip)
      real trunc, tfraction, smin, smax
      integer stdout
c
      stdout = 6
c
c-- initialize soln
c
      do 23000 i = 1, ip 
         sol(i) = 0.0
23000    continue
c
c-- set up truncation, assume singular values are sorted
c
      trunc = s(1) * tfraction
c
      do 23002 i = 1, ip 
         if(.not.(s(i) .le. trunc))goto 23004
            s(i) = 0.0
23004    continue
23002    continue
c
      iused = 0
      smin = s(1)
      smax = s(1)
c
      do 23006 j = 1, ip 
c-- if the singular value is zero, drop the solution
c-- (use the ordered eigen values to break??
         if(.not.( s(j) .ne. 0.0 ))goto 23008
            p = b(j) / s(j)
            iused = iused + 1
            if(.not.(s(j) .lt. smin))goto 23010
               smin = s(j)
23010       continue
            if(.not.(s(j) .gt. smax))goto 23012
               smax = s(j)
23012       continue
            goto 23009
c        else
23008       continue
            p = 0.0
23009    continue
         do 23014 i = 1, ip 
            sol(i) = sol(i) + p * a(i,j)
23014       continue
23006    continue
      write(stdout,*) ' '
      write(stdout,*) 'SVD truncation summary:'
      write(stdout,*) 'Truncation fraction: ',tfraction
      write(stdout,*) 'Max Singular Value: ', s(1)
      write(stdout,*) 'Min Singular Value: ', s(ip)
      write(stdout,*) 'Min Singular Value used ',smin
      write(stdout,*) 'Condition Number (smax / smin): ', smax / smin
      write(stdout,*) '# parameters, # SV used, # truncated'
      write(stdout,*) ip,iused,ip-iused
      write(stdout,*) ' '
      return
      end
