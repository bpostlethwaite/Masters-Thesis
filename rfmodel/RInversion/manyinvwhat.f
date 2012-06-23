c
c  MANYINV - a multiple starting model receiver function inversion code
c
c  VERSION 2.1 George Randall and Chuck Ammon 1997
c    This version uses the Poisson's Ratio of the Initial Model
c
c
c**********************************************************************************************
c
      program manyinv
c
c**********************************************************************************************
      parameter(nlmax = 45, ntmax = 520, nsmax = 2, ndat = ntmax*nsmax+
&      2*nlmax)
c     dimension alpha(nlmax),beta(nlmax),rho(nlmax),thiki(nlmax),h(nlmax)
      dimension h(nlmax)
      dimension pert(nlmax),alphai(nlmax),betai(nlmax),rhoi(nlmax)
      character*32 modela,title
      integer inunit,ounit,ifile
      logical porsv
      common /seismo/ seis(ntmax,nsmax), dt(nsmax), dura(nsmax), dly(
&      nsmax),gauss(nsmax),p(nsmax),nt(nsmax),porsv(nsmax)
      common /imodel/alpha(nlmax),beta(nlmax),thiki(nlmax),rho(nlmax),
&      nlyrs
      common /innout/ inunit,ounit
      character*24 todays_date
      real tfraction
      real fmin
      integer npasses
      logical hpfilter, yesno
      common /filter/ fmin, npasses, hpfilter
      external rand
c
c**********************************************************************************************
c
c     Initialize
c
c**********************************************************************************************
      inunit = 5
      ounit = 6
      ifile = 8
      seed = 0.5
      fmin = 0.03
      npasses = 2
      hpfilter = .false.
      call rand(seed)
c
c**********************************************************************************************
c     Where to place blame
      write(ounit,'(/)')
      write(ounit,*) 
&      '**********************************************************'
      write(ounit,*)'manyinv - Receiver function inversion program.'
      write(ounit,*)'          VERSION 2.1 July 1997'
      write(ounit,*)'    Charles J. Ammon and George Randall.'
      write(ounit,*)
&      'Additional routines by George Zandt and Tom Owens.'
      write(ounit,*) 
&      '**********************************************************'
c**********************************************************************************************
      call fdate(todays_date)
      write(ounit,*) 'Inversion run on: ',todays_date
      write(ounit,*) 
&      '**********************************************************'
      write(ounit,*)'Maximum Number of points in each waveform = 512'
      write(ounit,*) 
&      '**********************************************************'
c
c**********************************************************************************************
      do 23000 i = 1,nlmax 
         pert(i) = 0.0
         alphai(i) = 0.0
         alpha(i) = 0.0
23000    continue
c
c**********************************************************************************************
c      set up for P-waves
c
c      p = true
c      sv = false
c
      do 23002 i = 1,nsmax
         porsv(i) = .true.
23002    continue
c
c**********************************************************************************************
c
c     Get the input parameters
c
c**********************************************************************************************
c
      write(ounit,*) ' '
c      
      write(ounit,*)'input velocity model:'
      read(inunit,'(a)')modela
c      
      write(ounit,*)'maximum perturbation in km/sec'
      read(inunit,*) pertmax
c      
      write(ounit,*)'Velocity to cut perturbing off'
      read(inunit,*) vcut
c      
      write(ounit,*)'Maximum perturbation for random component'
      write(ounit,*)'in percent of the maximum perturbation input'
      write(ounit,*)'above (10. -> 10%)'
      read(inunit,*) rpercent
c      
      write(ounit,*) ' '
      write(ounit,*)'Enter the max number of iterations per inversion'
      read(inunit,*) maxiter
c      
      write(ounit,*)'Enter the smoothing trade-off parameter'
      read(inunit,*) sigjmpb
c      
      write(ounit,*) ' '
      write(ounit,*)'Initial models are generated in 2 loops,'
      write(ounit,*)'when you enter the number of inversions'
      write(ounit,*)'you will actually get 4 times that number'
      write(ounit,*)'adjust your choice to compensate for this.'
      write(ounit,*) ' '
      write(ounit,*) 'So how many inversions do you want me to do?'
      read(inunit,*) numinv
c      
      write(ounit,*) ' '
      write(ounit,*)'Enter Singular Value truncation fraction'
      read(inunit,*) tfraction
c
      hpfilter = yesno('Apply a high-pass filter to waveforms? ')
      if(.not.(hpfilter))goto 23004
         write(ounit,*)'Enter the corner frequency.'
         read(inunit,*) fmin
         write(ounit,*) 'Enter the number of filter passes (1 or 2).'
         read(inunit,*) npasses
c
c**********************************************************************************************
c
23004 continue
      rpert = rpercent/100.0
c
c**********************************************************************************************
c - - read in the waveform for the inversions
c**********************************************************************************************
c
c*****call getseis(ns,seis,ntmax,nsmax,dt,dura,dly,gauss,p,nt,porsv)
c
c**********************************************************************************************
c - - read in the initial velocity model
c**********************************************************************************************
c
      open(unit=ifile,file=modela)
      rewind=ifile
      read(ifile,100)nlyrs,title
100   format(i3,1x,a32)
      do 23006 i1 = 1,nlyrs 
         read(ifile,110)idum,alphai(i1),betai(i1),rhoi(i1),thiki(i1),
&         dum1,dum2,dum3,dum4,dum5
23006    continue
110   format(i3,1x,9f8.4)
      close(unit=ifile)
c
c**********************************************************************************************
c     convert layer thicknesses to depths
c**********************************************************************************************
c      
      tdpth = 0.
      nlc = nlyrs
      iflag = 0
      do 23008 i2 = 2,nlyrs 
         itemp = i2 - 1
         tdpth = tdpth + thiki(itemp)
         h(i2) = tdpth
         if(.not.(alphai(i2).le.vcut))goto 23010
            cthick = tdpth+thiki(i2+1)
            iflag = 1
            nlc = i2
23010    continue
23008    continue
      if(.not.(iflag .eq. 0))goto 23012
         cthick = thiki(nlyrs)
c
23012 continue
      h(1) = 0.
c
c**********************************************************************************************
c
c
c  READY TO BEGIN INVERTING THE WAVEFORM(S)
c
c
c
c**********************************************************************************************
c     begin the perturbation calculations for the initial inversion models
c**********************************************************************************************
c
c     r1,r2,r3 are the roots of the cubic perturbation function.
c     
c     Root r3 is fixed at the bottom of the model.
c     Root r2 steps thru the model.
c     Root r1 varies from 'above' the model thru the upper part of the model
c     
c**********************************************************************************************
c
      r1 = -1.
c
c**********************************************************************************************
c
c The outer loop is a loop over the first root
c
      do 23014 iouter = 1, 4 
c
c**********************************************************************************************
c
         r2 = 0.0
         r3 = 1.0
c
c**********************************************************************************************
c
c The inner loop is a loop over the second root
c
         do 23016 inner = 1, numinv 
c
c**********************************************************************************************
c         step the remaining root around and
c           thru the model to generate perturbation
c            functions
c**********************************************************************************************
c
            r2 = r2 + float(inner-1)/float(numinv)
c
c**********************************************************************************************
c        Compute the coefficients for the
c          perturbing cubic function
c**********************************************************************************************
c
            a2 = -(r1 + r2 + r3)
            a1 = r1*r2 + r1*r3 + r2*r3
            a0 = -(r1 * r2 * r3)
c	 
            amax = 0.0
            do 23018 i5 = 1,nlc 
               z = h(i5)/cthick
               pert(i5) = cubic(z,a2,a1,a0)
               if(.not.(amax .le. abs(pert(i5))))goto 23020
                  amax = abs(pert(i5))
23020          continue
23018          continue
c
c**********************************************************************************************
c       Calculate and add a random component to the perturbation
c       rand returns a number between 0 and 1
c       2*(seed - 0.5) is a number between -1 and 1
c       add rpert*100% of pertmax in the random component
c
c       anorm normalizes the cubic part of the perturbation
c**********************************************************************************************
c
            anorm = pertmax/amax
c
            do 23022 i6 = 1,nlyrs 
c   
               call rand(seed)
c
c          scale the random part
c
               randpart = 2.*(seed - 0.5) * pertmax * rpert
c
               alpha(i6) = alphai(i6) + pert(i6) * anorm + randpart
c	   
               beta(i6) = alpha(i6)/1.732050808
               rho(i6) = 0.32 * alpha(i6) + 0.77
c
23022          continue
c
c**********************************************************************************************
c        invert the waveform
c**********************************************************************************************
c
            invnum = float(iouter-1)*numinv + inner
c
            write(ounit,*) 
&            '==========================================================
&            '
            write(ounit,*) 
&            '==========================================================
&            '
            write(ounit,*) '    Inversion Number: ',invnum
            write(ounit,*) 
&            '==========================================================
&            '
            write(ounit,*) 
&            '==========================================================
&            '
c
            write(ounit,*) 'Model (layer, vp, vs, rho): '
	    do i=1,nlyrs
	       write(ounit,1001) i,alpha(i),beta(i),rho(i)
            enddo
1001        format(1x,i3,3(1x,f7.4))
23016       continue
c 
c**********************************************************************************************
c     END OF THE LOOP OVER ROOT 2 (INNER LOOP)
c**********************************************************************************************
c
         r1 = r1 +.5*float(iouter)
c
23014    continue
c
c**********************************************************************************************
c     END OF THE LOOP OVER ROOT 1 (OUTER LOOP)
c**********************************************************************************************
c
      stop
      end

      subroutine rand(x)
      data k,j,m,rm/5701,3612,566927,566927.0/
      ix=int(x*rm)
      irand=mod(j*ix+k,m)
      x=(real(irand)+.5)/rm
      return
      end

      function cubic(z,a2,a1,a0)
      cubic = a0+z*(a1+z*(a2+z))
      end
