#
#  Added some truncation and some diagnostic output
#  Ammon June 18, 1993
#
#
subroutine jsoln( a, NDAT, npb, ip, b, not_used, s, sol, tfraction)
{
integer NDAT, not_used
integer npb,ip, iused
real a(NDAT,ip), b(NDAT), s(ip), sol(ip)
real trunc, tfraction, smin, smax
integer  stdout
#
stdout = 6
#
#-- initialize soln
#
do i = 1, ip {
   sol(i) = 0.0
   }
#
#-- set up truncation, assume singular values are sorted
#
trunc = s(1) * tfraction
#
do i = 1, ip {
   if(s(i) <= trunc) s(i) = 0.0
   }
#
iused = 0
smin = s(1)
smax = s(1)
#
do j = 1, ip {
   #-- if the singular value is zero, drop the solution
   #-- (use the ordered eigen values to break??
   if ( s(j) != 0.0 ) {
      		p = b(j) / s(j)
      		iused = iused + 1
      		if(s(j) .lt. smin) smin = s(j)
		if(s(j) .gt. smax) smax = s(j)
      } else {
      		p = 0.0
      }
   do i = 1, ip {
      sol(i) = sol(i) + p * a(i,j)
      }
   }
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
}
