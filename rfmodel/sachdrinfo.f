C     Program to read SAC file header and print out quantities in it.
C     Takes SAC file name from command line, followed by a list of
C     file header variable names, prints result on standard output.
C
C     G. Helffrich/DTM 1 Aug. 1992

      character filenm*128, outline*255, vname*16, kvar*16
      parameter (ntoken=20)
      character tok(ntoken)*128
      logical once

      call getarg(1,filenm)
      if (filenm .eq. ' ') stop '**SAC file name missing.'
      once = filenm .ne. '-input'

100   continue
         if (.not. once) then
	    read(5,'(a)',iostat=ios) outline
	    if (ios .ne. 0) stop
            call tokens(outline,ntoken,n,tok)
	    if (n .eq. 0) go to 100
	    filenm = tok(n)
	    if (n .gt. 1) then
	       outline = tok(1)
	       do 5 i=2,n-1
		  ix = lenb(outline)+1
		  outline(ix:) = ' ' // tok(i)
5              continue
	       ix = lenb(outline)+2
	    else
	       ix = 1
	    endif
	 else
	    ix = 1
         endif

C        Mark end of output line.
	 outline(ix:) = filenm(1:lenb(filenm)) // ': |'

	 call rsach(filenm,nerr)
	 if (nerr .ne. 0) then
	    if (once) stop '**Can''t read SAC file.'
	    ix = index(outline,'|')
	    outline(ix:) = '**Can''t read SAC file.'
	    go to 19
	 endif

	 do 10 i=2,iargc()
	    call getarg(i,vname)

C           Call subroutine depending on first character of header
C           variable name.
	    ix = index(outline,'|')
	    if (index('Nn',vname(1:1)) .ne. 0) then
	       call getnhv(vname,nvar,nerr)
	       if (nerr .eq. 0) then
		  write(outline(ix:),*) nvar,' |'
	       else
		  write(outline(ix:),*) 'UNDEFINED |'
	       endif
	    else if (index('Kk',vname(1:1)) .ne. 0) then
C              Eliminate null padding of character strings if present.
	       call getkhv(vname,kvar,nerr)
	       do 15 j=1,len(kvar)
		  if (kvar(i:i) .eq. char(0)) kvar(i:i) = ' '
15             continue
	       write(outline(ix:),*) kvar(1:index(kvar,' ')),'|'
	    else if (index('Ii',vname(1:1)) .ne. 0) then
	       call getihv(vname,kvar,nerr)
	       write(outline(ix:),*) kvar(1:index(kvar,' ')),'|'
	    else
	       call getfhv(vname,fvar,nerr)
	       if (nerr .eq. 0) then
	          write(outline(ix:),*) fvar,' |'
	       else
		  write(outline(ix:),*) 'UNDEFINED |'
	       endif
	    endif
10       continue

19       continue
	 write(6,'(a)') outline(1:index(outline,'|')-1)
      if (.not. once) go to 100
      end

      integer function lenb(str)
      character str*(*)

      do i=len(str),1,-1
	 if (str(i:i) .ne. ' ') then
	    lenb = i
	    return
	 endif
      enddo
      lenb = 1
      end
