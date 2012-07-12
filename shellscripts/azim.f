c-----------------------------------------------------------------------
      program azim

c . . Read earthquake location info. from a NEIC style line
c . . Output earthquake name, location (either relative to  
c . . Whitehorse Y.T.) or absolute coordinates.
      character*1 sq, wq
      real*4 eqlat, eqlon, eqdep, eqtim
      real*4 late,lone,lats,lons,pdedel,pdeazi,dum1
      real*4 dum
      character*30 comment
      character*10 name
      logical rflag
      logical argu
      f=180.0/3.1415927
      if(.not.argu(lone,late,lons,lats))then
        write(0,'(a)')'usage: azim -s slon slat -e elon elat'
        stop
      endif
      call delaz2(late/f, lone/f, dum1, dum2, dum3, 0)
      call delaz2(lats/f, lons/f, pdedel, pdeazi, dum1, 1)
      write(06,*) 'DELTA: ',pdedel*f
      write(06,*) 'AZIM: ',pdedazi*f
      write(06,*) 'BAZ: ',dum1*f
      stop
      end
c---------------------------------------------------------------
      logical function argu(lone,late,lons,lats)

      implicit none

c . . Argument retrieval routine:
c . . rflag determines whether lat,lon or delta, az are output 

      logical rflag

      real*4 lats,lons,late,lone
      integer iargc,narg,lenstr
      character*60 nxtarg
      external lenstr,iargc,getarg

      data narg/0/

c . . initial housekeeping
      argu = .true.
c . . loop over the arguments
      do while(narg.lt.iargc())
        narg = narg+1
        nxtarg = ' '
        call getarg(narg,nxtarg)
        if(nxtarg(1:2).eq.'-s') then
          narg=narg+1 
          call getarg(narg,nxtarg)
          read(nxtarg,*)lons
          narg=narg+1 
          call getarg(narg,nxtarg)
          read(nxtarg,*)lats
        elseif(nxtarg(1:2).eq.'-e') then
          narg=narg+1
          call getarg(narg,nxtarg)
          read(nxtarg,*)lone
          narg=narg+1
          call getarg(narg,nxtarg)
          read(nxtarg,*)late
        else
          argu = .false.
        endif
      enddo
      return
      end
