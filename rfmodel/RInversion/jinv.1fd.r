subroutine jinv(sigjmpb,maxiter,ns,invnum)
{
#
#  Constants for array sizes
#

parameter ( NLMAX = 45, NTMAX = 520, NSMAX = 2, NDAT = NTMAX*NSMAX+2*NLMAX)

#
#  Array declarations
#

real a(NDAT,2*NLMAX), b(NDAT)
real s(2*NLMAX),wk(4*NLMAX)
logical porsv(NSMAX)
integer nt(NSMAX)
common /seismo/ seis(NTMAX,NSMAX), dt(NSMAX), dura(NSMAX), dly(NSMAX), gauss(NSMAX), p(NSMAX),nt(NSMAX),porsv(NSMAX)
real aa(NTMAX,NLMAX),rms(NSMAX)
real syn(NTMAX,NSMAX)
real sol(2*NLMAX)
logical pon(NLMAX,6)

common /imodel/ alpha(NLMAX), beta(NLMAX), thk(NLMAX), rho(NLMAX),nlyrs

logical happy, jumping, yesno
integer inunit,ounit,iter,maxiter
common /innout/ inunit,ounit

#
#  Initialization
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
#  Initialize the matrix of partials and constraints
#

#
#  The partials and forward model
#

#-- clean out leftovers
do i = 1, NDAT {
do j = 1, 2*NLMAX {
   a(i,j) = 0.0
}
}

noff = 0
I2FLAG = 0

#--  loop on seismograms, setup a matrix
do iseis = 1, ns {

if ( porsv(iseis) ) {
   #-- the P case
   loff = 0
   perta = 1.0173 ; pertb = 1.01 ; pertr = 1. + (0.32*1.73*.01)
   rp=p(iseis);dts=dt(iseis);dlys=dly(iseis);agauss=gauss(iseis)
   call partials( aa, rp, perta, pertb, pertr, nlyrs, NLMAX, 
		  dts, NTMAX, dlys, agauss, 
		  alpha, beta, rho, thk, pon )
   IF(I2FLAG.EQ.1) RETURN } 
   else { 
   #-- the SV case loff = nlyrs
   perta = 1.01 ; pertb = 1. + (0.01/1.73) ; pertr = 1.0032
   call spartials( aa, p(iseis), perta, pertb, pertr, nlyrs, NLMAX, 
		  dt(iseis), NTMAX, dly(iseis), gauss(iseis), dura(iseis),
		  alpha, beta, rho, thk, pon )
}

do i = 1, nt(iseis) {
   do j = 1, nlyrs-1 {
      #--  copy partials
      a( i+noff, j+loff ) = aa( i, j )   
   }
   #--  copy forward model
   syn( i, iseis ) = aa( i, NLMAX )  
   #--  calculate resiual
   b( i+noff ) = seis( i, iseis ) - syn( i, iseis )  
   if ( jumping ) {
      do j = 1, nlyrs-1 {
	 #--  add jumping
	 if ( porsv(iseis) ) {
	    #-- p wave case
	    b( i+noff ) = b( i+noff ) + aa(i,j) * beta(j)  
	 } else {
	    #-- sv wave case
	    b( i+noff ) = b( i+noff ) + aa(i,j) * alpha(j)  
	 }
      }
   }
}


#-- the rms for each trace
rms(iseis) = 0.0
do j = 1, nt(iseis) {
   rms(iseis) = rms(iseis) + ( seis(j,iseis) - syn(j,iseis) ) ** 2
}
rms(iseis) = sqrt( rms(iseis) / nt(iseis) )

noff = noff + nt(iseis)
}

#-- calculate the model roughness, second difference
ruffa = 0.0;  ruffb = 0.0
do i = 1, nlyrs-2 {
   ruffa = ruffa + ( alpha(i) -  alpha(i+2) ) ** 2
   ruffb = ruffb + ( beta(i) -  beta(i+2) ) ** 2
}
ruffa = sqrt( ruffa / (nlyrs-2) )  
ruffb = sqrt( ruffb / (nlyrs-2) )  

write(*,'(//)')
write(*,*) 'initial rms errors: '
write(*,*) ( rms(i), i = 1, ns )
write(*,*) 'initial roughness alpha, beta:'
write(*,*) ruffa, ruffb

#--  end of loop on seismograms

#--  if jumping, setup the contraint equations
if ( jumping ) {
do i = 1, nlyrs {
   b( i+noff ) = 0.0
   if ( i < nlyrs) {
      #-- smoothness ( second diference ) constraint
      a( i+noff, i ) = sigjmpb
      a( i+noff, i+1 ) = -sigjmpb
     } else {
      #-- constrain bottom layer velocity
      a( i+noff, nlyrs ) = 1.0
      a( i+noff + nlyrs-1, nlyrs+nlyrs ) = 1.0
      b( i+noff ) = beta(nlyrs)
      b( i+noff + nlyrs-1 ) = alpha(nlyrs)
   }
}
#noff = noff + 2*(nlyrs-1)
noff = noff + (nlyrs-1)
}
#--  end of jumping constraint setup

#
#  OK, it initialized, now
#  Loop until solved...
#

while ( ! happy ) {

   #-- now write synthetics and partials
   call putsyn(  ns, syn, NTMAX, NSMAX, dt, dura, dly, gauss, p, nt, porsv, iter, invnum )
   call wrtsoln( nlyrs, alpha, beta, rho, thk, iter ,invnum )
   #-- call putpartl( a, NDAT, 2*NLMAX, dt(1), noff, 2*nlyrs)

   
   #
   #  The computation of the svd for generalized inverse....
   #

   npb = noff
   if ( jumping ) {
      ip = 2*nlyrs
      if(ns .eq. 1) ip = nlyrs
   } else {
      ip = 2*(nlyrs-1)
      if(ns .eq. 1) ip = nlyrs-1
   }
#  IMSL LIB: call lsvdf( a, NDAT, npb, ip, b, NDAT, 1, s, wk, ier)

   call svdrs( a, NDAT, npb, ip, b, NDAT, 1, s)

   #-- form the solutions ( velocity model/perturbatations )
   if ( jumping ) {
      call jsoln( a, NDAT, npb, ip, b, NDAT, s, sol )
      do i = 1, nlyrs {
	# alpha(i) = sol(i+nlyrs) 
	 beta(i) = sol(i)
	 alpha(i) = beta(i)*1.73205081
	 rho(i) = 0.32 * alpha(i) + 0.77
      }
    } else {
      call csoln( a, NDAT, npb, ip, b, NDAT, s, sol )
   }



   #
   #  Now get ready for the next iteration...
   #  The partials and forward model
   #

   #-- clean out leftovers
   do i = 1, NDAT {
      do j = 1, 2*NLMAX {
	 a(i,j) = 0.0
      }
   }

   noff = 0

   #--  loop on seismograms, setup a matrix
   do iseis = 1, ns {

      if ( porsv(iseis) ) {
	 #-- the P case
	 loff = 0
	 perta = 1.0173 ; pertb = 1.01 ; pertr = 1. + (0.32*1.73*.01)
	 rp=p(iseis);dts=dt(iseis);dlys=dly(iseis);agauss=gauss(iseis)
	 call partials( aa, rp, perta, pertb, pertr, nlyrs, NLMAX, 
			dts, NTMAX, dlys, agauss, 
			alpha, beta, rho, thk, pon )
        } else {
	 #-- the SV case
	 loff = nlyrs
	 perta = 1.01 ; pertb = 1. + (0.01/1.73) ; pertr = 1.0032
	 call spartials( aa, p(iseis), perta, pertb, pertr, nlyrs, NLMAX, 
			dt(iseis), NTMAX, dly(iseis), gauss(iseis), dura(iseis),
			alpha, beta, rho, thk, pon )
      }

      do i = 1, nt(iseis) {
	 do j = 1, nlyrs-1 {
	    #--  copy partials
	    a( i+noff, j+loff ) = aa( i, j )   
	 }
	 #--  copy forward model
	 syn( i, iseis ) = aa( i, NLMAX )  
	 #--  calculate resiual
	 b( i+noff ) = seis( i, iseis ) - syn( i, iseis )  
	 if ( jumping ) {
	    do j = 1, nlyrs-1 {
	       #--  add jumping
	       if ( porsv(iseis) ) {
		  #-- p wave case
		  b( i+noff ) = b( i+noff ) + aa(i,j) * beta(j)  
	       } else {
		  #-- sv wave case
		  b( i+noff ) = b( i+noff ) + aa(i,j) * alpha(j)  
	       }
	    }
	 }
      }

      #-- the rms for each trace
      rms(iseis) = 0.0
      do j = 1, nt(iseis) {
	 rms(iseis) = rms(iseis) + ( seis(j,iseis) - syn(j,iseis) ) ** 2
      }
      rms(iseis) = sqrt( rms(iseis) / nt(iseis) )

      noff = noff + nt(iseis)
   }
   #--  end of loop on seismograms

   #--  if jumping, setup the contraint equations
   if ( jumping ) {
      do i = 1, nlyrs {
	 b( i+noff ) = 0.0
	 if ( i < nlyrs ) {
	    #-- smoothness ( second diference ) constraint
	    a( i+noff, i ) = sigjmpb
	    a( i+noff, i+1 ) = - sigjmpb
	   } else {
	    #-- constrain bottom layer velocity
	    a( i+noff, nlyrs ) = 1.0
	    b( i+noff ) = beta(nlyrs)
	 }
      }
      noff = noff + 2*(nlyrs-1)
      if(ns .eq.1 )noff = noff + nlyrs-1
   }
   #--  end of jumping constraint setup

   #-- calculate the model roughness, second difference
   ruffa = 0.0;  ruffb = 0.0
   do i = 1, nlyrs-2 {
      ruffa = ruffa + ( alpha(i) - 2.*alpha(i+1) + alpha(i+2) ) ** 2
      ruffb = ruffb + ( beta(i) - 2.*beta(i+1) + beta(i+2) ) ** 2
   }
   ruffa = sqrt( ruffa / (nlyrs-2) );  ruffb = sqrt( ruffb / (nlyrs-2) )

   write(*,*) 'rms errors: '
   write(*,*) ( rms(i), i = 1, ns )
   write(*,*) 'roughness alpha, beta:'
   write(*,*) ruffa, ruffb
   iter = iter + 1

   happy =  ( iter .ge. maxiter)

   }
#
#  Wrap up
#

call wrtsoln( nlyrs, alpha, beta, rho, thk, iter, invnum )
call putsyn(  ns, syn, NTMAX, NSMAX, dt, dura, dly, gauss, p, nt, porsv, iter, invnum)


return
end
}
