subroutine putsvalues(s, n, invnum )
integer n, invnum
real s(n)
character*80 sacfil
character*2 ext 
character*4 iext

write(ext,'(i2.2)') invnum
write(iext,'(i2.2,i2.2)') invnum
sacfil="svalues_inv" // ext 
call wsac1(sacfil, s, n, 1.0,1.0, nerr)

return
end
