      subroutine iniocm
c
c     subroutine to initialize all variables in /tjocm/
c
c **********************************************************************
c
c common block info for link with subroutine sacio
c
      real instr
      integer year,jday,hour,min,isec,msec,idf
      character*8 sta,cmpnm,evnm,kdf
      common /tjocm/ dmin,dmax,dmean,year,jday,hour,min,isec,msec,sta,
     *            cmpnm,az,cinc,evnm,baz,delta,rayp,depth,decon,agauss,
     *              c,tq,instr,dlen,begin,t0,t1,t2
c
c **************************************************************************
c
      data df,idf,kdf,zero/-12345.,-12345,'        ',0./
      dmin=zero
      dmax=zero
      dmean=zero
      year=idf
      jday=idf
      hour=idf
      min=idf
      isec=idf
      msec=idf
      sta=kdf
      cmpnm=kdf
      az=df
      cinc=df
      evnm=kdf
      baz=df
      delta=df
      rayp=df
      depth=df
      decon=zero
      agauss=df
      c=df
      tq=df
      instr=df
      dlen=df
      begin=df
      t0=df
      t1=df
      t2=df
      return
      end
