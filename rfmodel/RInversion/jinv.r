#
#  Function jinv - to invert rftn waveforms
#
#  VERSION 2.1 George Randall and Chuck Ammon 1997
#
#  We haven't verified that this will work with multiple waveforms (CJA)
#
#
subroutine jinv(sigjmpb,maxiter,ns,invnum,tfraction)
{
#
#  Constants for array sizes
#

parameter ( NLMAX = 45, NTMAX = 520, NSMAX = 2, NDAT = NTMAX*NSMAX+2*NLMAX)

#
#  Array declarations
#

real a(NDAT,2*NLMAX), b(NDAT)
real s(3*NLMAX),wk(4*NLMAX)
logical porsv(NSMAX)
integer nt(NSMAX)
common /seismo/ seis(NTMAX,NSMAX), dt(NSMAX), dura(NSMAX), dly(NSMAX), gauss(NSMAX), p(NSMAX),nt(NSMAX),porsv(NSMAX)

real fmin
integer npasses
logical hpfilter
common /filter/ fmin, npasses, hpfilter

real aa(NTMAX,NLMAX),rms(NSMAX)
real syn(NTMAX,NSMAX)
real sol(2*NLMAX)
real tfraction, sig_power(NSMAX),misfit(NSMAX)
real perta(NLMAX), pertb(NLMAX), pertr(NLMAX)
real vp_over_vs(NLMAX),pratio(NLMAX)
logical pon(NLMAX,6)

common /imodel/ alpha(NLMAX), beta(NLMAX), thk(NLMAX), rho(NLMAX),nlyrs

logical happy, jumping, yesno
integer inunit,ounit,iter,maxiter
common /innout/ inunit,ounit

#
#--------------------------------------------------------------------------------------
#  Initialization
#--------------------------------------------------------------------------------------
#
inunit=5; ounit=6; iter=0
jumping = .true.
sigjmpa = 0.

do i = 1, nlyrs-1 {
   pon(i,1) = .true. ; pon(i,2) = .true. ; pon(i,3) = .true.
}
pon(nlyrs,1) = .true. ; pon(nlyrs,2) = .true. ; pon(nlyrs,3) = .true.
happy = .false.
#
#  compute the vp/vs ratio of the original model
#   
write(*,*) 'Initial Model Vp over Vs Ratio'
write(*,*) 'Layer   Vp/Vs       Poissons Ratio'
do ilyr=1,nlyrs 
{
   vp_over_vs(ilyr) = alpha(ilyr)/beta(ilyr)
   pratio(ilyr) = vpovs_to_pr(vp_over_vs(ilyr))
   write(*,'(i5,2x,f10.7,8x,f5.3)') ilyr, vp_over_vs(ilyr),pratio(ilyr)
} 
#
#--------------------------------------------------------------------------------------
#  apply a high-pass filter if requested
#--------------------------------------------------------------------------------------
#
if(hpfilter){
  do iseis = 1, ns {
    call hpbufilter(seis(1,iseis),nt(iseis),dt(iseis),fmin,npasses)
  }
}
#
call putseis(ns, seis, NTMAX, NSMAX, dt, dura, dly, gauss, p, nt, porsv, iter, invnum)
#
#--------------------------------------------------------------------------------------
#  Compute the power in each signal
#--------------------------------------------------------------------------------------
#
do iseis = 1, ns {
  sig_power(iseis) = 0.0
  do j = 1, nt(iseis){
    sig_power(iseis) = sig_power(iseis) + seis(j,iseis)*seis(j,iseis)
  }
  if(sig_power(iseis) == 0.0){
    write(*,*) 'Signal ',iseis,' has zero power, stopping execution.'
    stop
  }
}
#
#
#--------------------------------------------------------------------------------------
#  Initialize the matrix of partials and constraints
#--------------------------------------------------------------------------------------
#
#-- clean out leftovers
do i = 1, NDAT {
  do j = 1, 2*NLMAX {
   a(i,j) = 0.0
  }
}
#
noff = 0
I2FLAG = 0
#   Set up the perturbations for the layers - keep vp/vs
#
#  perta = 1.0173 ; pertb = 1.01 ; pertr = 1. + (0.32*1.73*.01)
#
#  use the vp/vs ratio of the original model
#   
   do ilyr=1,nlyrs 
   {
      pertb(ilyr) = 1.01
      perta(ilyr) = 1.01
      pertr(ilyr) = 1.01
   } 
#     
#--------------------------------------------------------------------------------------
#--  loop on seismograms, setup a matrix
#--------------------------------------------------------------------------------------
do iseis = 1, ns {
#
#--------------------------------------------------------------------------------------
#   get the partial derivatives
#--------------------------------------------------------------------------------------
#
   loff = 0
   rp=p(iseis);dts=dt(iseis);dlys=dly(iseis);agauss=gauss(iseis)

#  write(*,'(1x,a8,1x,i2.2)')'Waveform',iseis
#  write(*,*) 'dt =  ',dt,' agauss = ',agauss
#
   call partials( aa, rp, perta, pertb, pertr, nlyrs, NLMAX, 
		  dts, NTMAX, dlys, agauss, 
		  alpha, beta, rho, thk, pon )
#
   IF(I2FLAG.EQ.1) RETURN 

    #
    #--------------------------------------------------------------------------------------
    #  apply filter if requested
    #--------------------------------------------------------------------------------------
    #
    if(hpfilter){
         #--------------------------------------------------------------------------------------
         #  filter the partials
         #--------------------------------------------------------------------------------------
         #
	 do j = 1, nlyrs-1 {
            call hpbufilter(aa(1,j),nt(iseis),dt(iseis),fmin,npasses)
         }      
         #
         #--------------------------------------------------------------------------------------
         #  filter the synthetic
         #--------------------------------------------------------------------------------------
         #
         call hpbufilter(aa(1,NLMAX),nt(iseis),dt(iseis),fmin,npasses)
         #
     }
#
do i = 1, nt(iseis) {
   do j = 1, nlyrs-1 {
     #--------------------------------------------------------------------------------------
     #--  copy partials
     #--------------------------------------------------------------------------------------
      a( i+noff, j+loff ) = aa( i, j )   
   }
   #
   #--------------------------------------------------------------------------------------
   #--  copy forward model
   #--------------------------------------------------------------------------------------
   #syn( i, iseis ) = aa( i+noff, NLMAX )  
   syn( i, iseis ) = aa( i, NLMAX )  
   #--------------------------------------------------------------------------------------
   #--  calculate residual
   #--------------------------------------------------------------------------------------
   b( i+noff ) = seis( i, iseis ) - syn( i, iseis )  
   if ( jumping ) {
      do j = 1, nlyrs-1 {
	 #--  add jumping
	    b( i+noff ) = b( i+noff ) + aa(i,j) * beta(j)  
	      }
   }
}


#--------------------------------------------------------------------------------------
#-- calculate the misfit & rms for each trace
#--------------------------------------------------------------------------------------
rms(iseis) = 0.0
do j = 1, nt(iseis) {
   rms(iseis) = rms(iseis) + ( seis(j,iseis) - syn(j,iseis) ) ** 2
}
misfit(iseis) = rms(iseis) / sig_power(iseis)
rms(iseis) = sqrt( rms(iseis) / nt(iseis) )
noff = noff + nt(iseis)
}
#--------------------------------------------------------------------------------------
#--  end of loop on seismograms
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
#-- calculate the model roughness, second difference
#--------------------------------------------------------------------------------------
ruffa = 0.0;  ruffb = 0.0
do i = 1, nlyrs-2 {
   ruffa = ruffa + ( alpha(i) - 2.*alpha(i+1) + alpha(i+2) ) ** 2
   ruffb = ruffb + ( beta(i) - 2.*beta(i+1) + beta(i+2) ) ** 2
}
ruffa0 = sqrt( ruffa / (nlyrs-2) )  
ruffb0 = sqrt( ruffb / (nlyrs-2) )  

write(*,*) '**********************************************************'
write(*,*) 'Iteration: ', iter
write(*,'(/)')
write(*,*) 'initial fractional square misfit: ', ( misfit(i), i = 1, ns )
write(*,*) 'initial rms errors: ', ( rms(i), i = 1, ns )
write(*,*) 'initial roughness alpha, beta:', ruffa0, ruffb0
write(*,*) '**********************************************************'


#--------------------------------------------------------------------------------------
#--  if jumping, setup the smoothing contraint equations
#--------------------------------------------------------------------------------------
if ( jumping ) {
do i = 1, nlyrs {
   b( i+noff ) = 0.0
   b( i+noff + nlyrs-1 ) = 0.0
   if ( i < nlyrs-1 ) {
      #-- smoothness ( second diference ) constraint
      a( i+noff, i ) = sigjmpb
      a( i+noff, i+1 ) = -2. * sigjmpb
      a( i+noff, i+2 ) = sigjmpb
   } else if(i == nlyrs-1){
      a(i+noff, i) = sigjmpb
      a(i+noff, i+1) = -sigjmpb
   } else {
      #-- constrain bottom layer velocity
      a( i+noff, nlyrs ) = 1.0
      b( i+noff ) = beta(nlyrs)      
   }
}

noff = noff + nlyrs

}
#--------------------------------------------------------------------------------------
#--  end of jumping constraint setup
#--------------------------------------------------------------------------------------

#
#--------------------------------------------------------------------------------------
#  OK, it initialized, now
#  Loop until solved...
#--------------------------------------------------------------------------------------
#

while ( ! happy ) {

   #--------------------------------------------------------------------------------------
   #-- now write synthetics and partials
   call putsyn(  ns, syn, NTMAX, NSMAX, dt, dura, dly, gauss, p, nt, porsv, iter, invnum )
   call wrtsoln( nlyrs, alpha, beta, rho, thk, iter ,invnum )
   #-- call putpartl( a, NDAT, 2*NLMAX, dt(1), noff, 2*nlyrs)
   #--------------------------------------------------------------------------------------

   #--------------------------------------------------------------------------------------
   #
   #  The computation of the svd for generalized inverse....
   #
   #--------------------------------------------------------------------------------------

   npb = noff
   if ( jumping ) {
      ip = nlyrs
      if(ns .eq. 1) ip = nlyrs
   } else {
      ip = (nlyrs-1)
      if(ns .eq. 1) ip = nlyrs-1
   }
   #
   call svdrs( a, NDAT, npb, ip, b, NDAT, 1, s)
   #
   write(*,*) '**********************************************************'
   write(*,*) 'Iteration: ', iter+1

   #--------------------------------------------------------------------------------------
   #-- form the solutions ( velocity model/perturbations )
   #--------------------------------------------------------------------------------------
   if ( jumping ) {
      call jsoln( a, NDAT, npb, ip, b, NDAT, s, sol, tfraction)
      #
      call putsvalues(s,ip,invnum)
      #
      do i = 1, nlyrs {
	 beta(i) = sol(i)
	 alpha(i) = beta(i)*vp_over_vs(i)
	 rho(i) = 0.32 * alpha(i) + 0.77
      }
    }
   #
   #   Make sure the inversions hasn't gone far astray
   #
    do i = 1, nlyrs
    {
       if(beta(i) .le. 0.0){
	 write(*,*)'Oops - negative velocities, quitting.'
	 write(*,*)'Try increasing smoothing weight or'
	 write(*,*)'decreasing initial-model perturbation size.'
	 write(*,*)'Watch out for really slow near-surface'
	 write(*,*)'layers and large initial model perturbations.'
	 stop
       }
    }
   #
   #--------------------------------------------------------------------------------------
   #  Now get ready for the next iteration...
   #  The partials and forward model
   #--------------------------------------------------------------------------------------
   #

   #--------------------------------------------------------------------------------------
   #-- clean out leftovers
   #--------------------------------------------------------------------------------------
   do i = 1, NDAT {
      do j = 1, 2*NLMAX {
	 a(i,j) = 0.0
      }
   }

   noff = 0
   
   #--------------------------------------------------------------------------------------
   #--  loop on seismograms, setup a matrix
   #--------------------------------------------------------------------------------------
   #
   
   do iseis = 1, ns {

 	 loff = 0
#        perta = 1.0173 ; pertb = 1.01 ; pertr = 1. + (0.32*1.73*.01)
	 rp=p(iseis);dts=dt(iseis);dlys=dly(iseis);agauss=gauss(iseis)
	 call partials( aa, rp, perta, pertb, pertr, nlyrs, NLMAX, 
			dts, NTMAX, dlys, agauss, 
			alpha, beta, rho, thk, pon )

    #
    #--------------------------------------------------------------------------------------
    #  apply filter if requested
    #--------------------------------------------------------------------------------------
    #
    if(hpfilter){
         #--------------------------------------------------------------------------------------
         #  filter the partials
         #--------------------------------------------------------------------------------------
         #
	 do j = 1, nlyrs-1 {
            call hpbufilter(aa(1,j),nt(iseis),dt(iseis),fmin,npasses)
         }      
         #
         #--------------------------------------------------------------------------------------
         #  filter the synthetic
         #--------------------------------------------------------------------------------------
         #
         call hpbufilter(aa(1,NLMAX),nt(iseis),dt(iseis),fmin,npasses)
         #
     }
#
      do i = 1, nt(iseis) {
	 do j = 1, nlyrs-1 {
            #--------------------------------------------------------------------------------------
	    #--  copy partials
            #--------------------------------------------------------------------------------------
	    a( i+noff, j+loff ) = aa( i, j )   
	 }
	 #--  copy forward model
	 syn( i, iseis ) = aa( i, NLMAX )  
	 #--  calculate residual
	 b( i+noff ) = seis( i, iseis ) - syn( i, iseis )  
	 if ( jumping ) {
	    do j = 1, nlyrs-1 {
	       #--  add jumping
		  b( i+noff ) = b( i+noff ) + aa(i,j) * beta(j)  
	    }
	 }
      }
   #
   #--------------------------------------------------------------------------------------
   #-- the rms for each trace
   #--------------------------------------------------------------------------------------
   #
      rms(iseis) = 0.0
      do j = 1, nt(iseis) {
	 rms(iseis) = rms(iseis) + ( seis(j,iseis) - syn(j,iseis) ) ** 2
      }
      misfit(iseis) = rms(iseis) / sig_power(iseis)
      rms(iseis) = sqrt( rms(iseis) / nt(iseis) )

   #
   #--------------------------------------------------------------------------------------
   #-- adjust the offset pointer
   #--------------------------------------------------------------------------------------
   #
         noff = noff + nt(iseis)
   }
   #--------------------------------------------------------------------------------------
   #--  end of loop on seismograms
   #--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
#--  if jumping, setup the smoothing contraint equations
#--------------------------------------------------------------------------------------
   if ( jumping ) {
      do i = 1, nlyrs {
	 b( i+noff ) = 0.0
	 b( i+noff + nlyrs-1 ) = 0.0
	 if ( i < nlyrs-1 ) {
	    #-- smoothness ( second diference ) constraint
	    a( i+noff, i ) = sigjmpb
	    a( i+noff, i+1 ) = -2. * sigjmpb
	    a( i+noff, i+2 ) = sigjmpb
	 } else  if(i == nlyrs-1){
            a(i+noff, i) = sigjmpb
            a(i+noff, i+1) = -sigjmpb
         } else {
            #-- constrain bottom layer velocity
            a( i+noff, nlyrs ) = 1.0
            b( i+noff ) = beta(nlyrs)      
         }
      }
      
      noff = noff + nlyrs
      
   }
   #--------------------------------------------------------------------------------------
   #--  end of jumping constraint setup
   #--------------------------------------------------------------------------------------

   #--------------------------------------------------------------------------------------
   #-- calculate the model roughness, second difference
   #--------------------------------------------------------------------------------------
   ruffa = 0.0;  ruffb = 0.0
   do i = 1, nlyrs-2 {
      ruffa = ruffa + ( alpha(i) - 2.*alpha(i+1) + alpha(i+2) ) ** 2
      ruffb = ruffb + (  beta(i) - 2.* beta(i+1) +  beta(i+2) ) ** 2
   }
   ruffa = sqrt( ruffa / (nlyrs-2) );  ruffb = sqrt( ruffb / (nlyrs-2) )
   
   write(*,*) 'fractional square misfit: ',( misfit(i), i = 1, ns )
   write(*,*) 'rms errors: ',( rms(i), i = 1, ns )
   write(*,*) 'roughness alpha, beta:',ruffa, ruffb
   
   if(ruffa0 != 0 && ruffb0 != 0){
       write(*,'(a40,f8.2,1x,f8.2)') ' Percent Roughness Change (alpha,beta): ', 100*ruffa/ruffa0, 100*ruffb0/ruffb
   write(*,*) '**********************************************************'
   }

   iter = iter + 1

   happy =  ( iter .ge. maxiter)

   }
#
#--------------------------------------------------------------------------------------
#  Wrap up
#--------------------------------------------------------------------------------------
#

call wrtsoln( nlyrs, alpha, beta, rho, thk, iter, invnum )
call putsyn(  ns, syn, NTMAX, NSMAX, dt, dura, dly, gauss, p, nt, porsv, iter, invnum)
#
#  compute the vp/vs ratio of the final model
#   
write(*,*) 'Final Model '
write(*,*) 'Layer   Vp/Vs       Poissons Ratio'
do ilyr=1,nlyrs 
{
   vp_over_vs(ilyr) = alpha(ilyr)/beta(ilyr)
   pratio(ilyr) = vpovs_to_pr(vp_over_vs(ilyr))
   write(*,'(i5,2x,f10.7,8x,f5.3)') ilyr, vp_over_vs(ilyr),pratio(ilyr)
}

return
end
}
