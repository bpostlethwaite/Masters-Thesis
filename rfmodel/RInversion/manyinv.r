#
#  MANYINV - a multiple starting model receiver function inversion code
#
#  VERSION 2.1 George Randall and Chuck Ammon 1997
#    This version uses the Poisson's Ratio of the Initial Model
#
#
#**********************************************************************************************
#
      program manyinv
#
#**********************************************************************************************
      parameter(NLMAX = 45, NTMAX = 520, NSMAX = 2, NDAT = NTMAX*NSMAX+2*NLMAX)
      dimension alpha(NLMAX),beta(NLMAX),rho(NLMAX),thiki(NLMAX),h(NLMAX)
      dimension pert(NLMAX),alphai(NLMAX),betai(NLMAX),rhoi(NLMAX)
      character*32 modela,title
      integer inunit,ounit,ifile
      logical porsv(NSMAX)
      common /seismo/ seis(NTMAX,NSMAX), dt(NSMAX), dura(NSMAX), dly(NSMAX),gauss(NSMAX),p(NSMAX),nt(NSMAX),porsv(NSMAX)
      common /imodel/alpha(NLMAX),beta(NLMAX),thiki(NLMAX),rho(NLMAX),nlyrs
      common /innout/ inunit,ounit
      character*24 todays_date
      real tfraction
      real fmin
      integer npasses
      logical hpfilter, yesno
      common /filter/ fmin, npasses, hpfilter
#
#**********************************************************************************************
#
#     Initialize
#
#**********************************************************************************************
      inunit = 5;  ounit = 6;  ifile = 8; seed = 0.5
      fmin = 0.03; npasses = 2; hpfilter = .false.
      call rand(seed)
#
#**********************************************************************************************
#     Where to place blame
      write(ounit,'(/)')
      write(ounit,*) '**********************************************************'
      write(ounit,*)'manyinv - Receiver function inversion program.'
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
#
#**********************************************************************************************
      do i = 1,NLMAX {
	   pert(i) = 0.0
	   alphai(i) = 0.0
	   alpha(i) = 0.0
	   }
#
#**********************************************************************************************
#      set up for P-waves
#
#      p = true
#      sv = false
#
       do i = 1,NSMAX{ porsv(i) = .true.}
#
#**********************************************************************************************
#
#     Get the input parameters
#
#**********************************************************************************************
#
      write(ounit,*) ' '
#      
      write(ounit,*)'input velocity model:'
      read(inunit,'(a)')modela
#      
      write(ounit,*)'maximum perturbation in km/sec'
      read(inunit,*) pertmax
#      
      write(ounit,*)'Velocity to cut perturbing off'
      read(inunit,*) vcut
#      
      write(ounit,*)'Maximum perturbation for random component'
      write(ounit,*)'in percent of the maximum perturbation input'
      write(ounit,*)'above (10. -> 10%)'
      read(inunit,*) rpercent
#      
      write(ounit,*) ' '
      write(ounit,*)'Enter the max number of iterations per inversion'
      read(inunit,*) maxiter
#      
      write(ounit,*)'Enter the smoothing trade-off parameter'
      read(inunit,*) sigjmpb
#      
      write(ounit,*) ' '
      write(ounit,*)'Initial models are generated in 2 loops,'
      write(ounit,*)'when you enter the number of inversions'
      write(ounit,*)'you will actually get 4 times that number'
      write(ounit,*)'adjust your choice to compensate for this.'
      write(ounit,*) ' '
      write(ounit,*) 'So how many inversions do you want me to do?'
      read(inunit,*) numinv
#      
      write(ounit,*) ' '
      write(ounit,*)'Enter Singular Value truncation fraction'
      read(inunit,*) tfraction
#
      hpfilter = yesno('Apply a high-pass filter to waveforms? ')
      if(hpfilter) {
         write(ounit,*)'Enter the corner frequency.'
         read(inunit,*) fmin
         write(ounit,*) 'Enter the number of filter passes (1 or 2).'
         read(inunit,*) npasses
      }
#
#**********************************************************************************************
#
      rpert = rpercent/100.0
#
#**********************************************************************************************
# - - read in the waveform for the inversions
#**********************************************************************************************
#
      call getseis(ns,seis,NTMAX,NSMAX,dt,dura,dly,gauss,p,nt,porsv)
#
#**********************************************************************************************
# - - read in the initial velocity model
#**********************************************************************************************
#
      open(unit=ifile,file=modela)
      rewind=ifile
      read(ifile,100)nlyrs,title
100   format(i3,1x,a32)
      do i1 = 1,nlyrs {
	 read(ifile,110)idum,alphai(i1),betai(i1),rhoi(i1),thiki(i1),dum1,dum2,dum3,dum4,dum5
       }
110   format(i3,1x,9f8.4)
      close(unit=ifile)
#
#**********************************************************************************************
#     convert layer thicknesses to depths
#**********************************************************************************************
#      
      tdpth = 0.
      nlc = nlyrs
      iflag = 0
      do i2 = 2,nlyrs {
	 itemp = i2 - 1
	 tdpth = tdpth + thiki(itemp)
	 h(i2) = tdpth
	  if(alphai(i2).le.vcut) {
	     cthick = tdpth+thiki(i2+1)
	     iflag = 1
	     nlc = i2
          }
      }
      if(iflag .eq. 0) cthick = thiki(nlyrs)
#
      h(1) = 0.
#
#**********************************************************************************************
#
#
#  READY TO BEGIN INVERTING THE WAVEFORM(S)
#
#
#
#**********************************************************************************************
#     begin the perturbation calculations for the initial inversion models
#**********************************************************************************************
#
#     r1,r2,r3 are the roots of the cubic perturbation function.
#     
#     Root r3 is fixed at the bottom of the model.
#     Root r2 steps thru the model.
#     Root r1 varies from 'above' the model thru the upper part of the model
#     
#**********************************************************************************************
#
      r1 = -1.
#
#**********************************************************************************************
#
# The outer loop is a loop over the first root
#
      do iouter = 1, 4 {
#
#**********************************************************************************************
#
         r2 = 0.0
         r3 = 1.0
#
#**********************************************************************************************
#
# The inner loop is a loop over the second root
#
      do inner = 1, numinv {
#
#**********************************************************************************************
#         step the remaining root around and
#           thru the model to generate perturbation
#            functions
#**********************************************************************************************
#
	 r2 = r2 + float(inner-1)/float(numinv)
#
#**********************************************************************************************
#        Compute the coefficients for the
#          perturbing cubic function
#**********************************************************************************************
#
	 a2 = -(r1 + r2 + r3)
	 a1 =  r1*r2 + r1*r3 + r2*r3
	 a0 = -(r1 * r2 * r3)
#	 
	 amax = 0.0
	 do i5 = 1,nlc {
	    z = h(i5)/cthick
	    pert(i5) = cubic(z,a2,a1,a0)
	    if(amax .le. abs(pert(i5))) amax = abs(pert(i5))
         }
#
#**********************************************************************************************
#       Calculate and add a random component to the perturbation
#       rand returns a number between 0 and 1
#       2*(seed - 0.5) is a number between -1 and 1
#       add rpert*100% of pertmax in the random component
#
#       anorm normalizes the cubic part of the perturbation
#**********************************************************************************************
#
	 anorm = pertmax/amax
#
	 do i6 = 1,nlyrs {
#   
	   call rand(seed)
#
#          scale the random part
#
	   randpart = 2.*(seed - 0.5) * pertmax * rpert
#
	   alpha(i6) = alphai(i6) + pert(i6) * anorm + randpart
#	   
	   beta(i6) = alpha(i6)/1.732050808
	    rho(i6) = 0.32 * alpha(i6) + 0.77
#
         }
#
#**********************************************************************************************
#        invert the waveform
#**********************************************************************************************
#
	 invnum = float(iouter-1)*numinv + inner
#
         write(ounit,*) '=========================================================='
         write(ounit,*) '=========================================================='
         write(ounit,*) '    Inversion Number: ',invnum
         write(ounit,*) '=========================================================='
         write(ounit,*) '=========================================================='
#
	 call jinv(sigjmpb,maxiter,ns,invnum,tfraction)

      }
# 
#**********************************************************************************************
#     END OF THE LOOP OVER ROOT 2 (INNER LOOP)
#**********************************************************************************************
#
	 r1 = r1 +.5*float(iouter)
#
      }
#
#**********************************************************************************************
#     END OF THE LOOP OVER ROOT 1 (OUTER LOOP)
#**********************************************************************************************
#
      stop
      end
#
#**********************************************************************************************
#  END of MAIN PROGRAM
#**********************************************************************************************
#
#
#
#**********************************************************************************************
      subroutine rand(x)
#**********************************************************************************************
      data k,j,m,rm/5701,3612,566927,566927.0/
	  ix=int(x*rm)
          irand=mod(j*ix+k,m)
	  x=(real(irand)+.5)/rm
      return
      end
#
#
#
#**********************************************************************************************
      real function cubic(z,a2,a1,a0) 
#**********************************************************************************************
      cubic = a0+z*(a1+z*(a2+z))
      end
