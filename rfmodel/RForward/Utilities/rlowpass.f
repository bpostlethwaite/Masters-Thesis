      program rlowpass
c
c  ********************************************************************
c
c    *** modified by C Ammon 062789
c
c  *************************************************************************
c
      real NewGauss
      character eqfile*32,outfil*32,comp*6,outc*5,knm(2)*8
      complex data(16384),zero1
      logical yes,yesno,rel
      integer blank,ounit
c **********************************************************************
c
c common block info for link with subroutine sacio
c
      real instr
      integer year,jday,hour,min,isec,msec
      character*8 sta,cmpnm,evnm
      common /tjocm/ dmin,dmax,dmean,year,jday,hour,min,isec,msec,sta,
     *            cmpnm,az,cinc,evnm,baz,delta,rayp,depth,decon,agauss,
     *              c,tq,instr,dlen,begin,t0,t1,t2
c
c **************************************************************************
c
c   parameter definitions may be found in sacio comments
c
      common /win/ data
      common /innout/ inunit,ounit
      data comp/'.eqr  '/, outc/'.lp '/,knm/'radial  ','tangentl'/
      inunit=5
      ounit=6
      zero1=cmplx(0.,0.)
      pi=3.141592654
      call iniocm
    2 call asktxt('Specify file: ',eqfile)
      iblank=blank(eqfile)
      i = 1
         call zero(data(1),1,8200)
c         eqfile(1:iblank + 6)=eqfile(1:iblank)//comp
         call sacio(eqfile,data(1),npts,dt,+1)
         caz=az
c
c    *******************************************************************
c
    4 nft=npowr2(npts)
      nfpts=nft/2 + 1
      fny=1./(2.*dt)
      delf=fny/float(nft/2)
      write(ounit,102) npts,nft,fny,delf,dt
  102 format(1x,'npts=',i5,1x,'nft=',i5,1x,'fny=',f7.4,1x,
     *          'delf=',f8.4,1x,'dt=',f6.3)
c
c
      cdelf = 1. / (float( nft ) * dt)
      call asktxt('Specify outfil: ',outfil)
         call dfftr(data(1),nft,'forward',dt)
      
      OldGauss=ask('Old Gaussian width factor =  ')
      NewGauss=ask('New Gaussian width factor =  ')
      gnorm = 0.
         do 9 j=1,nfpts
            freq=float(j-1)*delf
            w=2.*pi*freq
	    gnorm = exp(-(w*w/4.)*1./(NewGauss*NewGauss)) + gnorm
            gauss=-(w*w/4.)*(1./(NewGauss*NewGauss) -
     *            1./(OldGauss*OldGauss))
            data(j)=data(j) * cmplx(exp(gauss),0.)
    9    continue

c     compute the area uder the gaussian curve

      gnorm = 2. * gnorm * fny 
c
c     account for the fft scaling
      gnorm = gnorm * cdelf

      do 10 j = 1,nfpts
	data(j) = data(j)/gnorm
10    continue
         
	 
	 call dfftr(data(1),nft,'inverse',cdelf)
c
c
      iblank=blank(outfil)
           
	   outfil(1:iblank + 5)=outfil(1:iblank)//outc
           call minmax(data(1),npts,dmin,dmax,dmean)
           
	   call sacio(outfil,data(1),npts,dt,-1)


      stop
      end
