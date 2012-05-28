      program get_tt

c . . Declarations.
C      implicit undefined(a-z)
      integer dim,dim1
      parameter (dim=60,dim1=5000)
      character*8 phase1(50),phase2(dim1)
      real depth,delta(dim1)
      double precision delt(dim1),t(dim1),p(dim1),dddp(dim1),dtdh(dim1)
      integer nph,n3,m1,i
      logical argu

c . . Get arguments.
      if(.not.argu(phase1,m1,depth,delta,n3))then
        write(0,'(a)')'usage: get_tt -z depth -d delta1...deltaN',
     &                '-p phase1...phaseN'
        write(0,'(a)')'output: i=1..N del(i),phase(i),t(i),p(i)'
        stop
      endif
 
c . . Get traveltimes etc.
      call get_tt_subr(phase1,m1,depth,delta,
     &                 n3,delt,phase2,t,p,dddp,dtdh,nph)

c . . Output.
      do i=1,n3*nph
        write(06,*) real(delt(i)),' ',phase2(i),
     &              real(t(i)),real(p(i))
      enddo
      stop
      end
c--------------------------------------------------------------
      logical function argu(phase1,m1,depth,delta,n3)
 
c      implicit undefined(a-z)
 
c . . Argument retrieval routine:
 
      logical dflag,pflag,zflag
 
      integer dim,dim1
      parameter (dim=60,dim1=5000)
      character*8 phase1(50)
      real depth,delta(dim1)
      integer n3,m1
      character*60 nxtarg
      integer iargc,narg,lenstr,i
      external lenstr,iargc,getarg
 
      data narg/0/
 
c . . Initial housekeeping.
      dflag=.false.
      pflag=.false.
      zflag=.false.

c . . Loop over the arguments
      do while(narg.lt.iargc())
        narg = narg+1
        call getarg(narg,nxtarg)
        if(nxtarg(1:2).eq.'-z') then
          zflag=.true.
          narg = narg + 1
          call getarg(narg,nxtarg)
          read(nxtarg,*)depth
        else if (nxtarg(1:2).eq.'-d') then
          dflag=.true.
          i=1
          narg=narg+1
          call getarg(narg,nxtarg)
          do while(nxtarg(1:1).ne.'-'.and.narg.le.iargc())
            read(nxtarg,*)delta(i)
            i=i+1
            narg=narg+1
            call getarg(narg,nxtarg)
          enddo 
          n3=i-1
          narg=narg-1
        else if (nxtarg(1:2).eq.'-p') then
          pflag=.true.
          i=1
          narg=narg+1
          call getarg(narg,nxtarg)
          do while(nxtarg(1:1).ne.'-'.and.narg.le.iargc())
            phase1(i)=nxtarg
            i=i+1
            narg=narg+1
            call getarg(narg,nxtarg)
          enddo
          m1=i-1
          narg=narg-1
        endif
      enddo
      argu=(dflag.and.pflag.and.zflag)
      return
      end
c--------------------------------------------------------------
      subroutine get_tt_subr(phase1,nphase,depth,delta,n3,
     .                       delt,phase2,t,p,dddp,dtdh,nph)

c      implicit undefined (A-Z)

cINPUT PARAMETERS:
c  phase1  C*8(50)   desired phase names
c  nphase  I         number of phases desired
c  depth   R*4       event depth
c  delta   R*4(dim1) set of epicentral distances
c  n3      I         number of distances
c
cOUTPUT PARAMETERS:
c  delt   R*8(dim1) epicentral distances
c  phase2 C*8(dim1) reinterpreted phase names
c  t      R*8(dim1) travel times (s)
c  p      R*8(dim1) ray parameters (s/deg)
c  dddp   R*8(dim1) d(delta)/d(p) (s/rad^2)
c  dtdh   R*8(dim1) d(time)/d(depth) (s/km)
c  nph    I         number of output phases
c
c  NOTE: phase names are expanded and reinterpreted, also a given phase
c        such as P may be triplicated and appear more than once

      save
      integer dim,dim1,n3,i,j,n,in,nphase,k
      parameter (dim=60,dim1=5000)
      character*8 phase1(50),phase2(dim1)
      real depth,delta(dim1)
      logical prnt(3),tabred
      character*8 phcd(50)
      character*41 modnam
      real tt(dim),dtdd(dim),dtdh4(dim),dddp4(dim),ts(dim)
      double precision delt(dim1),t(dim1),p(dim1),dddp(dim1),dtdh(dim1)
      integer mn(dim),nph
      real usrc(2)
      logical pdif,sdif,d145
      real    ttpd,dtddpd,dtdhpd,dddppd,ttsd,dtddsd,dtdhsd,dddpsd
      data modnam/'iasp91'/,in/1/,
     .     prnt/.false.,.false.,.false./,tabred/.false./

c     initialize program and read tables only on first call from matlab
 
c      if (.not.tabred) then
       call assign(10,2,'ttim1.lis')
       call tabin(in,modnam)
       tabred=.true.
c      endif

c     set phase names

      call brnset(nphase,phase1,prnt)
c      write(0,*) 'depth= ',depth

c     correct tables for exact event depth

      call depset(depth,usrc)

c     write(*,*)
c    %'  delta    # code       time(s)    (min s)    dT/dD',
c    %'     dT/dh      d2T/dD2'
 100  format(1x,f6.2,i5,2x,a,f9.2,i4,f7.2,SP,f11.4,S,2e11.3)
 101  format(/1x,'No arrivals for delta =',f7.2)
     
c if P, S, Pdiff, or Sdiff are requested, and a distance beyond
c 145 is requested then make pdif and/or sdif = true and obtain
c the travel time, ray parameter, dtdh, and dddp for Pdiff and/or
c Sdiff at 144 degrees. this information can then be extrapolated
c to get Pdiff and/or Sdiff at any distance.
      pdif=.false.
      sdif=.false.
      d145=.false.
      do 3 j=1,nphase
       if(phase1(j).eq.'P       '.or.phase1(j).eq.'Pdiff   ')pdif=.true.
       if(phase1(j).eq.'S       '.or.phase1(j).eq.'Sdiff   ')sdif=.true.
3     continue
      if (pdif .or. sdif) then  
        do 4 j=1,n3
          if (delta(j).gt.144.99) d145=.true. 
4       continue
        if (d145) then
          call trtm(144.,dim,n,tt,dtdd,dtdh4,dddp4,phcd)
          do 5 i=1,n
           if (pdif .and. phcd(i).eq.'Pdiff   ') then
             ttpd=tt(i)
             dtddpd=dtdd(i)
             dtdhpd=dtdh4(i)
             dddppd=dddp4(i)
           elseif (sdif .and. phcd(i).eq.'Sdiff   ') then
             ttsd=tt(i)
             dtddsd=dtdd(i)
             dtdhsd=dtdh4(i)
             dddpsd=dddp4(i)
           endif
5        continue
       else
          pdif=.false.
          sdif=.false.
        endif
      endif
        
      k=0
      do 1 j=1,n3
        call trtm(delta(j),dim,n,tt,dtdd,dtdh4,dddp4,phcd)
        if(n.le.0) then
          write(*,101)delta(j) 
        else
          do 2 i=1,n
            k=k+1
            delt(k)=delta(j)
            t(k)=tt(i)
            p(k)=dtdd(i)
            phase2(k)=phcd(i)
            dddp(k)=dddp4(i)
            dtdh(k)=dtdh4(i)
            mn(i)=int(tt(i)/60.)
            ts(i)=amod(tt(i),60.)
 2        continue
          if (pdif .and. delta(j).gt.144.99) then
            do 10 i=1,n
              if (phcd(i).eq.'Pdiff   ') then
                goto 15
              endif
10          continue
c          -add Pdiff to the list of phases
            k=k+1
            delt(k)=delta(j)
            t(k)=ttpd+(delta(j)-144)*dtddpd
            p(k)=dtddpd
            phase2(k)='Pdiff   '
            dddp(k)=dddppd
            dtdh(k)=dtdhpd
            mn(i)=int(tt(i)/60.)
            ts(i)=amod(tt(i),60.)
          endif

15        if (sdif .and. delta(j).gt.144.99) then
            do 16 i=1,n
              if (phcd(i).eq.'Sdiff   ') then
                goto 20
              endif
16          continue
c          -add Sdiff to the list of phases
            k=k+1
            delt(k)=delta(j)
            t(k)=ttsd+(delta(j)-144)*dtddsd
            p(k)=dtddsd
            phase2(k)='Sdiff   '
            dddp(k)=dddpsd
            dtdh(k)=dtdhsd
            mn(i)=int(tt(i)/60.)
            ts(i)=amod(tt(i),60.)
          endif
20        continue
c        write(*,100)(delta(j),i,phcd(i),tt(i),mn(i),ts(i),dtdd(i),
c    .                 dtdh4(i),dddp4(i),i=1,n)
        endif
 1    continue
      nph=k

c     do not close files so subroutine can be run again
c     call retrns(in)
c     call retrns(10)
      return
      end
