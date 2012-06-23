#
#  smthinv - a smoothness suite receiver function inversion program
#
#  VERSION 2.1 George Randall and Chuck Ammon 1997
#
#     This version uses the Poisson's Ratio of the Initial Model
#
      program smthinv

      parameter(NLMAX = 45, NTMAX = 520, NSMAX = 2, NDAT = NTMAX*NSMAX+2*NLMAX)
      dimension alpha(NLMAX),beta(NLMAX),rho(NLMAX),thiki(NLMAX)
      character*32 modela,title
      real minsigma,maxsigma,dsigma
      integer inunit,ounit,oun2,icount
      logical porsv(NSMAX)
      character*24 todays_date
      common /seismo/ seis(NTMAX,NSMAX), dt(NSMAX), dura(NSMAX), dly(NSMAX),gauss(NSMAX),p(NSMAX),nt(NSMAX),porsv(NSMAX)
      common /imodel/alpha(NLMAX),beta(NLMAX),thiki(NLMAX),rho(NLMAX),nlyrs
      common /innout/ inunit,ounit
      real tfraction
      real fmin
      integer npasses
      logical hpfilter, yesno
      common /filter/ fmin, npasses, hpfilter
      
#
      inunit = 5;  ounit = 6;  oun2 = 8
#
#**********************************************************************************************
#     Where to place blame
      write(ounit,'(/)')
      write(ounit,*) '**********************************************************'
      write(ounit,*)'smthinv - Receiver function inversion program.'
      write(ounit,*)'          VERSION 2.1 July 1997'
      write(ounit,*)'    Charles J. Ammon and George Randall.'
      write(ounit,*)'Additional routines by George Zandt and Tom Owens.'
      write(ounit,*) '**********************************************************'
#**********************************************************************************************
      call fdate(todays_date)
      write(ounit,*) 'Inversion run on: ',todays_date
      write(ounit,*) '**********************************************************'
      write(ounit,*)'Maximum Number of points in each waveform = 512'
      write(ounit,*) '**********************************************************'
#**********************************************************************************************
#
      do i = 1,NLMAX {
	   alpha(i) = 0.
	   beta(i) = 0.
	   rho(i) = 0.
	   thiki(i) = 0.
	   }
#
#************************************************************************************************
#      p = true
#      sv = false
#************************************************************************************************
#
       do i = 1,NSMAX{
	   porsv(i) = .true.}
#
#************************************************************************************************
      write(ounit,*)'input velocity model:'
      read(inunit,'(a)')modela
      write(ounit,*)'Enter the max number of iterations per inversion'
      read(inunit,*) maxiter
      write(ounit,*)'Enter the minimum smoothing trade-off parameter'
      read(inunit,*) minsigma
      write(ounit,*)'Enter the maximum smoothing trade-off parameter'
      read(inunit,*) maxsigma
      write(ounit,*)'Enter Singular Value truncation fraction'
      read(inunit,*) tfraction
      
      hpfilter = yesno('Apply a high-pass filter to waveforms? ')
      if(hpfilter) {
         write(ounit,*)'Enter the corner frequency.'
         read(inunit,*) fmin
         write(ounit,*) 'Enter the number of filter passes (1 or 2).'
         read(inunit,*) npasses
      }
#
#************************************************************************************************
# - - read in the waveform for the inversions
#************************************************************************************************
#
      call getseis(ns,seis,NTMAX,NSMAX,dt,dura,dly,gauss,p,nt,porsv)
#************************************************************************************************
#     loop over the smoothing paramter: sigmab
#************************************************************************************************
#
      icount = 1
      dsigma = (maxsigma - minsigma)/10
#
      while (sigjmpb .le. maxsigma)
      {

      sigjmpb = minsigma + (icount-1)*dsigma
      
#************************************************************************************************
      write(ounit,*) ' '
      write(ounit,*) '**********************************************************'
      write(ounit,*)'Smoothness trade-off parameter = ', sigjmpb
      write(ounit,*) '**********************************************************'
      write(ounit,*) ' '

#
#************************************************************************************************
# - - read in the initial velocity model
#************************************************************************************************
#
      open(unit=oun2,file=modela)
      rewind=oun2
      read(oun2,100)nlyrs,title
100   format(i3,1x,a32)
      do i1 = 1,nlyrs {
	 read(oun2,110)idum,alpha(i1),beta(i1),rho(i1),thiki(i1),dum1,dum2,dum3,dum4,dum5
                      }
110   format(i3,1x,9f8.4)
      close(unit=oun2)
#
#************************************************************************************************
#        invert the waveform
#************************************************************************************************
	 
	 invnum = icount
#
	 call jinv(sigjmpb,maxiter,ns,invnum,tfraction)
#************************************************************************************************
#
	 icount = icount + 1
      }

      stop
      end
