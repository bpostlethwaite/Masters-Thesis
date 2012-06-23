c
c  Function jinv - to invert rftn waveforms
c
c  VERSION 2.1 George Randall and Chuck Ammon 1997
c
c  We haven't verified that this will work with multiple waveforms (CJA)
c
c
      subroutine jinv(sigjmpb,maxiter,ns,invnum,tfraction)
c
c  Constants for array sizes
c
      parameter ( nlmax = 45, ntmax = 520, nsmax = 2, ndat = ntmax*
&      nsmax+2*nlmax)
c
c  Array declarations
c
      real a(ndat,2*nlmax), b(ndat)
      real s(3*nlmax),wk(4*nlmax)
      logical porsv
c     integer nt(nsmax)
      common /seismo/ seis(ntmax,nsmax), dt(nsmax), dura(nsmax), dly(
&      nsmax), gauss(nsmax), p(nsmax),nt(nsmax),porsv(nsmax)
      real fmin
      integer npasses
      logical hpfilter
      common /filter/ fmin, npasses, hpfilter
      real aa(ntmax,nlmax),rms(nsmax)
      real syn(ntmax,nsmax)
      real sol(2*nlmax)
      real tfraction, sig_power(nsmax),misfit(nsmax)
      real perta(nlmax), pertb(nlmax), pertr(nlmax)
      real vp_over_vs(nlmax),pratio(nlmax)
      logical pon(nlmax,6)
      common /imodel/ alpha(nlmax), beta(nlmax), thk(nlmax), rho(nlmax),
&      nlyrs
      logical happy, jumping, yesno
      integer inunit,ounit,iter,maxiter
      common /innout/ inunit,ounit
c
c--------------------------------------------------------------------------------------
c  Initialization
c--------------------------------------------------------------------------------------
c
      inunit=5
      ounit=6
      iter=0
      jumping = .true.
      sigjmpa = 0.
      do 23000 i = 1, nlyrs-1 
         pon(i,1) = .true. 
         pon(i,2) = .true. 
         pon(i,3) = .true.
23000    continue
      pon(nlyrs,1) = .true. 
      pon(nlyrs,2) = .true. 
      pon(nlyrs,3) = .true.
      happy = .false.
c
c  compute the vp/vs ratio of the original model
c   
      write(*,*) 'Initial Model Vp over Vs Ratio'
      write(*,*) 'Layer   Vp/Vs       Poissons Ratio'
      do 23002 ilyr=1,nlyrs
         vp_over_vs(ilyr) = alpha(ilyr)/beta(ilyr)
         pratio(ilyr) = vpovs_to_pr(vp_over_vs(ilyr))
         write(*,'(i5,2x,f10.7,8x,f5.3)') ilyr, vp_over_vs(ilyr),pratio(
&         ilyr)
23002    continue
c
c--------------------------------------------------------------------------------------
c  apply a high-pass filter if requested
c--------------------------------------------------------------------------------------
c
      if(.not.(hpfilter))goto 23004
         do 23006 iseis = 1, ns 
            call hpbufilter(seis(1,iseis),nt(iseis),dt(iseis),fmin,
&            npasses)
23006       continue
c
23004 continue
      call putseis(ns, seis, ntmax, nsmax, dt, dura, dly, gauss, p, nt, 
&      porsv, iter, invnum)
c
c--------------------------------------------------------------------------------------
c  Compute the power in each signal
c--------------------------------------------------------------------------------------
c
      do 23008 iseis = 1, ns 
         sig_power(iseis) = 0.0
         do 23010 j = 1, nt(iseis)
            sig_power(iseis) = sig_power(iseis) + seis(j,iseis)*seis(j,
&            iseis)
23010       continue
         if(.not.(sig_power(iseis) .eq. 0.0))goto 23012
            write(*,*) 'Signal ',iseis,
&            ' has zero power, stopping execution.'
            stop
23012    continue
23008    continue
c
c
c--------------------------------------------------------------------------------------
c  Initialize the matrix of partials and constraints
c--------------------------------------------------------------------------------------
c
c-- clean out leftovers
      do 23014 i = 1, ndat 
         do 23016 j = 1, 2*nlmax 
            a(i,j) = 0.0
23016       continue
23014    continue
c
      noff = 0
      i2flag = 0
c   Set up the perturbations for the layers - keep vp/vs
c
c  perta = 1.0173 ; pertb = 1.01 ; pertr = 1. + (0.32*1.73*.01)
c
c  use the vp/vs ratio of the original model
c   
      do 23018 ilyr=1,nlyrs
         pertb(ilyr) = 1.01
         perta(ilyr) = 1.01
         pertr(ilyr) = 1.01
23018    continue
c     
c--------------------------------------------------------------------------------------
c--  loop on seismograms, setup a matrix
c--------------------------------------------------------------------------------------
      do 23020 iseis = 1, ns 
c
c--------------------------------------------------------------------------------------
c   get the partial derivatives
c--------------------------------------------------------------------------------------
c
         loff = 0
         rp=p(iseis)
         dts=dt(iseis)
         dlys=dly(iseis)
         agauss=gauss(iseis)
c  write(*,'(1x,a8,1x,i2.2)')'Waveform',iseis
c  write(*,*) 'dt =  ',dt,' agauss = ',agauss
c
         call partials( aa, rp, perta, pertb, pertr, nlyrs, nlmax,dts, 
&         ntmax, dlys, agauss,alpha, beta, rho, thk, pon )
c
         if(.not.(i2flag.eq.1))goto 23022
            return
c
c--------------------------------------------------------------------------------------
c  apply filter if requested
c--------------------------------------------------------------------------------------
c
23022    continue
         if(.not.(hpfilter))goto 23024
c--------------------------------------------------------------------------------------
c  filter the partials
c--------------------------------------------------------------------------------------
c
            do 23026 j = 1, nlyrs-1 
               call hpbufilter(aa(1,j),nt(iseis),dt(iseis),fmin,npasses)
23026          continue
c
c--------------------------------------------------------------------------------------
c  filter the synthetic
c--------------------------------------------------------------------------------------
c
            call hpbufilter(aa(1,nlmax),nt(iseis),dt(iseis),fmin,
&            npasses)
c
c
23024    continue
         do 23028 i = 1, nt(iseis) 
            do 23030 j = 1, nlyrs-1 
c--------------------------------------------------------------------------------------
c--  copy partials
c--------------------------------------------------------------------------------------
               a( i+noff, j+loff ) = aa( i, j )
23030          continue
c
c--------------------------------------------------------------------------------------
c--  copy forward model
c--------------------------------------------------------------------------------------
csyn( i, iseis ) = aa( i+noff, NLMAX )  
            syn( i, iseis ) = aa( i, nlmax )
c--------------------------------------------------------------------------------------
c--  calculate residual
c--------------------------------------------------------------------------------------
            b( i+noff ) = seis( i, iseis ) - syn( i, iseis )
            if(.not.( jumping ))goto 23032
               do 23034 j = 1, nlyrs-1 
c--  add jumping
                  b( i+noff ) = b( i+noff ) + aa(i,j) * beta(j)
23034             continue
23032       continue
23028       continue
c--------------------------------------------------------------------------------------
c-- calculate the misfit & rms for each trace
c--------------------------------------------------------------------------------------
         rms(iseis) = 0.0
         do 23036 j = 1, nt(iseis) 
            rms(iseis) = rms(iseis) + ( seis(j,iseis) - syn(j,iseis) ) *
&            * 2
23036       continue
         misfit(iseis) = rms(iseis) / sig_power(iseis)
         rms(iseis) = sqrt( rms(iseis) / nt(iseis) )
         noff = noff + nt(iseis)
23020    continue
c--------------------------------------------------------------------------------------
c--  end of loop on seismograms
c--------------------------------------------------------------------------------------
c--------------------------------------------------------------------------------------
c-- calculate the model roughness, second difference
c--------------------------------------------------------------------------------------
      ruffa = 0.0
      ruffb = 0.0
      do 23038 i = 1, nlyrs-2 
         ruffa = ruffa + ( alpha(i) - 2.*alpha(i+1) + alpha(i+2) ) ** 2
         ruffb = ruffb + ( beta(i) - 2.*beta(i+1) + beta(i+2) ) ** 2
23038    continue
      ruffa0 = sqrt( ruffa / (nlyrs-2) )
      ruffb0 = sqrt( ruffb / (nlyrs-2) )
      write(*,*) 
&      '**********************************************************'
      write(*,*) 'Iteration: ', iter
      write(*,'(/)')
      write(*,*) 'initial fractional square misfit: ', ( misfit(i), i = 
&      1, ns )
      write(*,*) 'initial rms errors: ', ( rms(i), i = 1, ns )
      write(*,*) 'initial roughness alpha, beta:', ruffa0, ruffb0
      write(*,*) 
&      '**********************************************************'
c--------------------------------------------------------------------------------------
c--  if jumping, setup the smoothing contraint equations
c--------------------------------------------------------------------------------------
      if(.not.( jumping ))goto 23040
         do 23042 i = 1, nlyrs 
            b( i+noff ) = 0.0
            b( i+noff + nlyrs-1 ) = 0.0
            if(.not.( i .lt. nlyrs-1 ))goto 23044
c-- smoothness ( second diference ) constraint
               a( i+noff, i ) = sigjmpb
               a( i+noff, i+1 ) = -2. * sigjmpb
               a( i+noff, i+2 ) = sigjmpb
               goto 23045
c           else
23044          continue
               if(.not.(i .eq. nlyrs-1))goto 23046
                  a(i+noff, i) = sigjmpb
                  a(i+noff, i+1) = -sigjmpb
                  goto 23047
c              else
23046             continue
c-- constrain bottom layer velocity
                  a( i+noff, nlyrs ) = 1.0
                  b( i+noff ) = beta(nlyrs)
23047          continue
23045       continue
23042       continue
         noff = noff + nlyrs
c--------------------------------------------------------------------------------------
c--  end of jumping constraint setup
c--------------------------------------------------------------------------------------
c
c--------------------------------------------------------------------------------------
c  OK, it initialized, now
c  Loop until solved...
c--------------------------------------------------------------------------------------
c
23040 continue
c     while
23048 if(.not.( .not. happy ))goto 23049
c--------------------------------------------------------------------------------------
c-- now write synthetics and partials
         call putsyn( ns, syn, ntmax, nsmax, dt, dura, dly, gauss, p, 
&         nt, porsv, iter, invnum )
         call wrtsoln( nlyrs, alpha, beta, rho, thk, iter ,invnum )
c-- call putpartl( a, NDAT, 2*NLMAX, dt(1), noff, 2*nlyrs)
c--------------------------------------------------------------------------------------
c--------------------------------------------------------------------------------------
c
c  The computation of the svd for generalized inverse....
c
c--------------------------------------------------------------------------------------
         npb = noff
         if(.not.( jumping ))goto 23050
            ip = nlyrs
            if(.not.(ns .eq. 1))goto 23052
               ip = nlyrs
23052       continue
            goto 23051
c        else
23050       continue
            ip = (nlyrs-1)
            if(.not.(ns .eq. 1))goto 23054
               ip = nlyrs-1
23054       continue
23051    continue
c
         call svdrs( a, ndat, npb, ip, b, ndat, 1, s)
c
         write(*,*) 
&         '**********************************************************'
         write(*,*) 'Iteration: ', iter+1
c--------------------------------------------------------------------------------------
c-- form the solutions ( velocity model/perturbations )
c--------------------------------------------------------------------------------------
         if(.not.( jumping ))goto 23056
            call jsoln( a, ndat, npb, ip, b, ndat, s, sol, tfraction)
c
            call putsvalues(s,ip,invnum)
c
            do 23058 i = 1, nlyrs 
               beta(i) = sol(i)
               alpha(i) = beta(i)*vp_over_vs(i)
               rho(i) = 0.32 * alpha(i) + 0.77
23058          continue
c
c   Make sure the inversions hasn't gone far astray
c
23056    continue
         yesno = .true.
         do 23060 i = 1, nlyrs
            if (beta(i) .le. 0.0) then
	       if (yesno) then
               write(*,*)'Oops - negative velocities, trying to fix.'
               write(*,*)'Try increasing smoothing weight or'
               write(*,*)'decreasing initial-model perturbation size.'
               write(*,*)'Watch out for really slow near-surface'
               write(*,*)
&               'layers and large initial model perturbations.'
               yesno = .false.
	       endif
               beta(i) = 0.1
               alpha(i) = beta(i)*vp_over_vs(i)
               rho(i) = 0.32 * alpha(i) + 0.77
            endif
23060       continue
c
c--------------------------------------------------------------------------------------
c  Now get ready for the next iteration...
c  The partials and forward model
c--------------------------------------------------------------------------------------
c
c--------------------------------------------------------------------------------------
c-- clean out leftovers
c--------------------------------------------------------------------------------------
         do 23064 i = 1, ndat 
            do 23066 j = 1, 2*nlmax 
               a(i,j) = 0.0
23066          continue
23064       continue
         noff = 0
c--------------------------------------------------------------------------------------
c--  loop on seismograms, setup a matrix
c--------------------------------------------------------------------------------------
c
         do 23068 iseis = 1, ns 
            loff = 0
c        perta = 1.0173 ; pertb = 1.01 ; pertr = 1. + (0.32*1.73*.01)
            rp=p(iseis)
            dts=dt(iseis)
            dlys=dly(iseis)
            agauss=gauss(iseis)
            call partials( aa, rp, perta, pertb, pertr, nlyrs, nlmax,
&            dts, ntmax, dlys, agauss,alpha, beta, rho, thk, pon )
c
c--------------------------------------------------------------------------------------
c  apply filter if requested
c--------------------------------------------------------------------------------------
c
            if(.not.(hpfilter))goto 23070
c--------------------------------------------------------------------------------------
c  filter the partials
c--------------------------------------------------------------------------------------
c
               do 23072 j = 1, nlyrs-1 
                  call hpbufilter(aa(1,j),nt(iseis),dt(iseis),fmin,
&                  npasses)
23072             continue
c
c--------------------------------------------------------------------------------------
c  filter the synthetic
c--------------------------------------------------------------------------------------
c
               call hpbufilter(aa(1,nlmax),nt(iseis),dt(iseis),fmin,
&               npasses)
c
c
23070       continue
            do 23074 i = 1, nt(iseis) 
               do 23076 j = 1, nlyrs-1 
c--------------------------------------------------------------------------------------
c--  copy partials
c--------------------------------------------------------------------------------------
                  a( i+noff, j+loff ) = aa( i, j )
23076             continue
c--  copy forward model
               syn( i, iseis ) = aa( i, nlmax )
c--  calculate residual
               b( i+noff ) = seis( i, iseis ) - syn( i, iseis )
               if(.not.( jumping ))goto 23078
                  do 23080 j = 1, nlyrs-1 
c--  add jumping
                     b( i+noff ) = b( i+noff ) + aa(i,j) * beta(j)
23080                continue
23078          continue
23074          continue
c
c--------------------------------------------------------------------------------------
c-- the rms for each trace
c--------------------------------------------------------------------------------------
c
            rms(iseis) = 0.0
            do 23082 j = 1, nt(iseis) 
               rms(iseis) = rms(iseis) + ( seis(j,iseis) - syn(j,iseis) 
&               ) ** 2
23082          continue
            misfit(iseis) = rms(iseis) / sig_power(iseis)
            rms(iseis) = sqrt( rms(iseis) / nt(iseis) )
c
c--------------------------------------------------------------------------------------
c-- adjust the offset pointer
c--------------------------------------------------------------------------------------
c
            noff = noff + nt(iseis)
23068       continue
c--------------------------------------------------------------------------------------
c--  end of loop on seismograms
c--------------------------------------------------------------------------------------
c--------------------------------------------------------------------------------------
c--  if jumping, setup the smoothing contraint equations
c--------------------------------------------------------------------------------------
         if(.not.( jumping ))goto 23084
            do 23086 i = 1, nlyrs 
               b( i+noff ) = 0.0
               b( i+noff + nlyrs-1 ) = 0.0
               if(.not.( i .lt. nlyrs-1 ))goto 23088
c-- smoothness ( second diference ) constraint
                  a( i+noff, i ) = sigjmpb
                  a( i+noff, i+1 ) = -2. * sigjmpb
                  a( i+noff, i+2 ) = sigjmpb
                  goto 23089
c              else
23088             continue
                  if(.not.(i .eq. nlyrs-1))goto 23090
                     a(i+noff, i) = sigjmpb
                     a(i+noff, i+1) = -sigjmpb
                     goto 23091
c                 else
23090                continue
c-- constrain bottom layer velocity
                     a( i+noff, nlyrs ) = 1.0
                     b( i+noff ) = beta(nlyrs)
23091             continue
23089          continue
23086          continue
            noff = noff + nlyrs
c--------------------------------------------------------------------------------------
c--  end of jumping constraint setup
c--------------------------------------------------------------------------------------
c--------------------------------------------------------------------------------------
c-- calculate the model roughness, second difference
c--------------------------------------------------------------------------------------
23084    continue
         ruffa = 0.0
         ruffb = 0.0
         do 23092 i = 1, nlyrs-2 
            ruffa = ruffa + ( alpha(i) - 2.*alpha(i+1) + alpha(i+2) ) **
&             2
            ruffb = ruffb + ( beta(i) - 2.* beta(i+1) + beta(i+2) ) ** 
&            2
23092       continue
         ruffa = sqrt( ruffa / (nlyrs-2) )
         ruffb = sqrt( ruffb / (nlyrs-2) )
         write(*,*) 'fractional square misfit: ',( misfit(i), i = 1, ns 
&         )
         write(*,*) 'rms errors: ',( rms(i), i = 1, ns )
         write(*,*) 'roughness alpha, beta:',ruffa, ruffb
         if(.not.(ruffa0 .ne. 0 .and. ruffb0 .ne. 0))goto 23094
            write(*,'(a40,f8.2,1x,f8.2)') 
&            ' Percent Roughness Change (alpha,beta): ', 100*ruffa/
&            ruffa0, 100*ruffb0/ruffb
            write(*,*) 
&            '**********************************************************
&            '
23094    continue
         iter = iter + 1
         happy = ( iter .ge. maxiter)
         goto 23048
c     endwhile
23049 continue
c
c--------------------------------------------------------------------------------------
c  Wrap up
c--------------------------------------------------------------------------------------
c
      call wrtsoln( nlyrs, alpha, beta, rho, thk, iter, invnum )
      call putsyn( ns, syn, ntmax, nsmax, dt, dura, dly, gauss, p, nt, 
&      porsv, iter, invnum)
c
c  compute the vp/vs ratio of the final model
c   
      write(*,*) 'Final Model '
      write(*,*) 'Layer   Vp/Vs       Poissons Ratio'
      do 23096 ilyr=1,nlyrs
         vp_over_vs(ilyr) = alpha(ilyr)/beta(ilyr)
         pratio(ilyr) = vpovs_to_pr(vp_over_vs(ilyr))
         write(*,'(i5,2x,f10.7,8x,f5.3)') ilyr, vp_over_vs(ilyr),pratio(
&         ilyr)
23096    continue
      return
      end
