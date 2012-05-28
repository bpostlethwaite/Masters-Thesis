C#######################################################################
	SUBROUTINE DAY(ileap,iday,month,idat)
C-------to get gregorian-date from day number-----------------------
	if(iday.gt.366) then
	    print*,' SOMETHING WRONG WITH DATE'
	    stop
	    end if
	imin=0
	imax=31
	do 1 i=1,12
        idat=iday-imin
	month=i
	      if((iday.gt.imin).and.(iday.le.imax)) return
	if(i.eq.2.or.i.eq.4.or.i.eq.6.or.i.eq.7.or.i.eq.9.or.i.eq.11) then
	   incr=31
	   else
	   incr=30
	end if
        if (i.eq.1.and.ileap.eq.0) incr=28
	if (i.eq.1.and.ileap.ne.0) incr=29
	imin=imax
	imax=imax+incr
1       continue
	return
	end
