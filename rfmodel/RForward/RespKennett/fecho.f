      character arg*16, pfx*8, in*64

      call getarg(1,arg)
      read(arg,*,iostat=ios) nrep
      if (ios.ne.0) stop '**Bad # repetitions'
      call getarg(2,pfx)
      ixp = index(pfx,' ')-1

      do
         write(*,'(a,$)') pfx(1:ixp)
	 call flush
	 read(*,'(a)',iostat=ios) in
	 if (ios.ne.0) stop
	 ix = index(in,' ')-1
	 do i=1,nrep
	    write(*,'(a,1x,i2)') in(1:ix),i
	 enddo
      enddo
      end
