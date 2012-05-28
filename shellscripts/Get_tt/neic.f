      implicit undefined (A-Z)

      save 
      real delta,m,depth,tstart(4),tend(4)
      integer iflag,i

      m=6.
      depth=0.
      iflag=0
      open(unit=54,file='neic.mat')

      do 1, m=4.3,8.4,.4
        do 1, delta = 0,180,2.5
          call neic(delta,m,depth,iflag,tstart,tend)
          write(54,*) delta, (tstart(i),tend(i),  i=2,4)
1     continue
      close(54)
      end

      subroutine neic(delta,m,depth,iflag,tstart,tend)

c  Select time windows for seismic data based on event windows
c  using the NEIC criteria

c  INPUT PARAMETERS:

c  delta R4 epicentral distance
c  m     R4 event magnitude
c  depth R4 event depth
c  iflag I4 =0 for all channels
c           =1 for broad-band
c           =2 for long-period
c           =3 for intermediate-period
c           =4 for short-period

c OUTPUT PARAMETERS:
c  tstart R(4) vector of window start times (in seconds relative to origin time)
c  tend   R(4) vector of window end   times (in seconds relative to origin time)
c         tstart(i)/tend(i) are  start/end times for broad-band(i=1), long-period(i=2), 
c         intermediate-period(i=3) and short-period(i=4) data.


      save 

      implicit undefined (A-Z)

      integer dim1,nph,i,i1,iflag
      parameter (dim1=5000)
      character*8 phase1(50),phase2(dim1),phase,phasess,phasescs
      double precision delt(dim1),t(dim1),p(dim1),dddp(dim1),dtdh(dim1)
      real tf,tss,tscs,x1,x2
      real delta,m,depth,tstart(4),tend(4),tmin,tmax

      do 10 i=1,4
        tstart(i)=-999.
        tend(i)=-999.
10    continue

c define tf = 'first arrival'

c     get arrival times of all P, Pdiff, PKP, and PKiKP phases using iasp91 model
      phase1(1)='P       '
      phase1(2)='PKiKP   '
      call get_tt_subr(phase1,2,depth,delta,1,
     .                 delt,phase2,t,p,dddp,dtdh,nph)
c     out of the list of times, choose the earliest arrival
c     unless the event is smaller than 5.7 and the first arrival is
c     Pdiff.  in that case choose the next earliest arrival which is PKIKP or PKiKP.
      tf=10000.
      i1=1
      do 1 i=1,nph
        if (t(i).lt.tf) then
          if (phase2(i).ne.'Pdiff   ' .or. 
     .        (m.gt.5.7 .and. delta.le.120.)) then
            tf=t(i)
            i1=i
          endif
        endif
1     continue
      phase=phase2(i1)

cccccccccccccccccccccccccc    
c  long-period channels  c
cccccccccccccccccccccccccc    

      if (iflag.eq.0 .or. iflag.eq.2) then
        tmin=tf-600.
        x1=delta*111.111
        x2=40000-x1
        if      (m .lt. 5.5) then
          tmax=-999.
          tmin=-999.
        elseif (m .lt. 5.65) then
          tmax=x1/2.9+600.
        elseif (m .lt. 5.95) then
          tmax=x2/3.6+600.
        elseif (m .lt. 6.35) then
          tmax=(x1+ 40000)/3.6+600.
        elseif (m .lt. 6.75) then
          tmax=(x2+ 40000)/3.6+600.
        elseif (m .lt. 7.15) then
          tmax=(x1+ 80000)/3.6+600.
        elseif (m .lt. 7.55) then
          tmax=(x2+ 80000)/3.6+600.
        elseif (m .lt. 7.95) then
          tmax=(x1+120000)/3.6+600.
        else
          tmax=(x2+120000)/3.6+600.
        endif
        tstart(2)=tmin
        tend(2)=tmax
      endif

cccccccccccccccccccccccccc    
c  short-period channels c 
cccccccccccccccccccccccccc    

      if (iflag.eq.0 .or. iflag.eq.4) then
        tmin=tf-60.
        if     (m .lt. 4.9) then
          tmax=-999.
          tmin=-999.
        elseif (m .le. 5.7) then
          tmax=tf+300.
        elseif (m .le. 7.7) then
          tmax=tf+3000.
        else
          tmax=tf+10800.
        endif
        tstart(4)=tmin
        tend(4)=tmax
      endif

ccccccccccccccccccccccccccccccccccccccccccccccccc    
c  broad-band and intermediate-period channels  c
ccccccccccccccccccccccccccccccccccccccccccccccccc    

      if (iflag.eq.0 .or. iflag.eq.1 .or. iflag.eq.3) then
        if     (m .lt. 4.9) then
          tmax=-999.
          tmax=-999.
        elseif (m .le. 6.7) then

c         get times of SS and ScS phases
          phase1(1)='ScS     '
          phase1(2)='SS      '
          call get_tt_subr(phase1,2,depth,delta,1,
     .                     delt,phase2,t,p,dddp,dtdh,nph)

c     find the first arriving SS phase. Possible phase names include
c     SS, SnSn, SgSg, etc, but not names like ScS, S'S'ac or S'S'df.
          tss=10000.
          i1=1
          do 2 i=1,nph
            if (t(i).lt.tss) then
              if (phase2(i)(1:1).eq.'S'  .and. 
     .            phase2(i)(2:2).ne.'''' .and. 
     .            phase2(i)(2:2).ne.'c' ) then
                tss=t(i)
                i1=i
              endif
            endif
2         continue
          phasess=phase2(i1)
          if (tss.eq.10000.) tss=0

c     find the first arriving ScS phase.
          tscs=10000.
          i1=1
          do 3 i=1,nph
            if (t(i).lt.tscs) then
              if (phase2(i).eq.'ScS     ') then
                tscs=t(i)
                i1=i
              endif
            endif
3         continue
          phasescs=phase2(i1)
          if (tscs.eq.10000.) tscs=0
          tmax=amax1(tscs,tss)+ 200.
        elseif (m .le. 7.7) then
          tmax=delta*111.111/2.9+600.
        else
          tmax=tf+10800.
        endif
        if (depth.ge.300. .and. m.ge.5.7) then
          tmax=amax1(tmax,tf+4500)
        endif
        tstart(1)=tmin
        tstart(3)=tmin
        tend(1)=tmax
        tend(3)=tmax
      endif

      end

      subroutine get_tt_subr(phase1,nphase,depth,delta,n3,
     .                       delt,phase2,t,p,dddp,dtdh,nph)

      implicit undefined (A-Z)

cINPUT PARAMETERS:
c  phase1  C*8(50) desired phase names
c  nphase  I       number of phases desired
c  depth   R*4     event depth
c  delta   R*4(dim1) set of epicentral distances
c  n3      I       number of distances
c
cOUTPUT PARAMETERS:
c  delt   R*8(dim1)  epicentral distances
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
      data modnam/'/u4/iris/MATLAB/tau_p/iasp91'/,in/1/,
     .     prnt/.true.,.true.,.true./,tabred/.false./

c     initialize program and read tables only on first call from matlab
 
      if (.not.tabred) then
        call assign(10,2,'/u4/iris/MATLAB/tau_p/ttim1.lis')
        call tabin(in,modnam)
        tabred=.true.
      endif

c     set phase names

      call brnset(nphase,phase1,prnt)

c     correct tables for exact event depth

      call depset(depth,usrc)

c     write(*,*)
c    %'  delta    # code       time(s)    (min s)    dT/dD',
c    %'     dT/dh      d2T/dD2'
 100  format(1x,f6.2,i5,2x,a,f9.2,i4,f7.2,SP,f11.4,S,2e11.3)
 101  format(/1x,'No arrivals for delta =',f7.2)
     
c obtain travel times for each phase at each distance

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
c         write(*,100)(delta(j),i,phcd(i),tt(i),mn(i),ts(i),dtdd(i),
c    .                 dtdh4(i),dddp4(i),i=1,n)
        endif
 1    continue
      nph=k

c     do not close files so subroutine can be run again
c     call retrns(in)
c     call retrns(10)
      return
      end
