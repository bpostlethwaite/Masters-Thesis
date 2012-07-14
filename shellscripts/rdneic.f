c-------------------------------------------------------------------------
      program rdneic

c . . Read earthquake location info. from a NEIC style line
c . . Output earthquake name, location (either relative to  
c . . Whitehorse Y.T.) or absolute coordinates.
      character*1 sq, wq
      integer lati, latd, loni, lond, dpth
      real*4 eqlat, eqlon, eqdep, eqtim
      real*4 lato,lono,pdedel,pdeazi,dum1
      real*4 dum
      character*30 comment
      character*10 name
      logical rflag
      logical argu
      f=180.0/3.1415927
c      lato = 49.2
c      lono = -123.2
      lato = 62.4932
      lono = -114.6050
      if(.not.argu(lono,lato))then
        write(0,'(a)')'usage: rdneic [-s lono lato]'
        stop
      endif
      call delaz2(lato/f, lono/f, dum1, dum2, dum3, 0)
 998  read(05,1000,end=999)id,name,dum,eqlat,sq,eqlon,wq,dpth,
     &                     rmag,comment 
        if(sq.eq.'S') eqlat = -eqlat
        if(wq.eq.'W') eqlon = -eqlon
        call delaz2(eqlat/f, eqlon/f, pdedel, pdeazi, dum1, 1)
        write(06,1200)name,dum,eqlat,eqlon,dpth,rmag,pdedel*f,
     &                pdeazi*f,comment
        go to 998
  999 continue
 1000 format(i3,2x,a10,1x,f3.0,1x,f5.2,1x,a1,2x,f6.2,1x,a1,2x,
     &       i3,2x,f3.1,2x,a30)
c 1200 format(a10,1x,f5.1,1x,f6.1,1x,i3,1x,f3.1,1x,f6.2,1x,
c     &       f6.2,1x,a30)
 1200 format(a10,1x,f3.0,1x,f6.2,1x,f7.2,1x,i3,1x,f3.1,1x,f6.2,1x,
     &       f6.2,1x,a30)
      stop
      end
c---------------------------------------------------------------
      logical function argu(lono,lato)

      implicit none

c . . Argument retrieval routine:
c . . rflag determines whether lat,lon or delta, az are output 

      logical rflag

      real*4 lato,lono
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
          read(nxtarg,*)lono
          narg=narg+1 
          call getarg(narg,nxtarg)
          read(nxtarg,*)lato
        else 
          argu = .false.
        endif
      enddo
      return
      end
