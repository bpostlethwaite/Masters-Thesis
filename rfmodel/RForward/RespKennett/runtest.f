      character line*128, cmd*128
      integer token, runcmd
      data nrep /5/

C     command line arg, if given, is the number of repetitions (default 5)

      if (iargc() .gt. 0) then
         call getarg(1,line)
	 if (line.ne.' ') then
	    read(line,*,iostat=ios) i
	 else
	    ios = -1
	 endif
	 if (ios.eq.0) nrep = i
      endif

C     cmd = '|runsyn -trace modeltest.nrfr -std modeltest.std ' //
C    &      '-freq 1 -sps 20 -p 6.5 s/deg -win -10 80'
      cmd = '|fecho 3 "go>"'
      token = 0
      llen = runcmd(cmd,token,line)
      if (llen .lt. 0) stop '**Bad command startup'
      do i=1,nrep
	 llen = runcmd('>',token,'Hi')
	 do
	    llen = runcmd('<go>',token,line)
	    if (llen .le. 0) exit
	    write(*,*) line(1:llen)
	 enddo
      enddo
      llen = runcmd('eof',token,line)
      end
