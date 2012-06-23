      program modelgen

      parameter(maxl = 50, max = 5000)
      dimension alfp(maxl),thiki(maxl),h(maxl)
      dimension pert(maxl),alphai(maxl),betai(maxl),rhoi(maxl)
      character*32 modela,title
      character ofil*32, mnum*2
      integer inunit,ounit,oun2
      
#     real function cubic evaluates the
#     expression cubic = z**3 + a2*z**2 + a1*z + a0
#     
      cubic(z,a2,a1,a0) = a0+z*(a1+z*(a2+z))
#
      inunit = 5;  ounit = 6;  oun2 = 8
      ofil = '        '
      mnum = '  '
      do i = 1,maxl {
	   pert(i) = 0.
	   alphai(i) = 0.
	   alfp(i) = 0.
	   }
#
      write(ounit,*)'input velocity model:'
      read(inunit,'(a)')modela
      write(ounit,*)'maximum perturbation in km/sec'
      read(inunit,*) pertmax
      write(ounit,*)'Velocity to cut perturbing off'
      read(inunit,*) vcut
#
      open(unit=oun2,file=modela)
      rewind=oun2
      read(oun2,100)nlyrs,title
100   format(i3,1x,a32)
      do i1 = 1,nlyrs {
	 read(oun2,110)idum,alphai(i1),betai(i1),rhoi(i1),thiki(i1),
     c                 dum1,dum2,dum3,dum4,dum5
                      }
110   format(i3,1x,9f8.4)
      close(unit=oun2)
#
#     convert layer thicknesses to depths
      
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
#     r1,r2,r3 are the roots of the cubic
#     perturbation function
#     root r3 is fixed at the bottom of the
#     model.  root r2 steps thru the model
#     root r1 varies from 'above' the model
#     thru the upper part of the model
#
      r1 = -1.
      do j1 = 1,4 {
      r2 = 0.
      r3 = 1.
      nmods = 4

      do i4 = 1, nmods
      {
#         step the remaining root around and
#           thru the model to generate perturbation
#            functions
	 r2 = r2 + float(i4-1)/float(nmods)
#
#        Compute the coefficients for the
#          perturbing cubic function
	 a2 = - (r1 + r2 + r3)
	 a1 = r1*r2 + r1*r3 + r2*r3
	 a0 = -(r1 * r2 * r3)
	 amax = 0.
	 do i5 = 1,nlc {
	    z = h(i5)/cthick
	    pert(i5) = cubic(z,a2,a1,a0)
	    if(amax .le. abs(pert(i5))) amax = abs(pert(i5))
			 }
#           
	 anorm = pertmax/amax
	 do i6 = 1,nlyrs {
	   alfp(i6) = alphai(i6) + pert(i6) * anorm
			    }
#
#        sample the velocity structure evenly and output
#          a a SAC file
#        build the filename
#     
	 ofil = '                                '
	 inm = (j1-1)*nmods + i4
         if(inm.lt.10){write(mnum,120) inm}
                else {write(mnum,130) inm}
 120     format(i1)
 130     format(i2)
         ofil(1:8) = 'pmodel'//mnum(1:3)

	 call model_out(ofil,nlyrs,alfp,thiki)

      }
	 r1 = r1 +.5*float(j1-1)
      }
      stop
      end
      subroutine model_out(tempname,nl,pv,thik)
#
      parameter(LMAX = 50)
      dimension pv(LMAX),sv(LMAX),rho(LMAX),thik(LMAX)
      dimension qp(LMAX),qs(LMAX)
      dimension strk(LMAX),dip(LMAX),por(LMAX),sigma(LMAX)
      integer ounit,oun2
      character*32 ofile,title,tempname
      common /innout/ inunit,ounit
      ounit=6
      inunit=5
      oun2 = 8
#
#  set defaults
#
      do i=1,LMAX {
          qp(i)=0.0
          qs(i)=0.0
          strk(i)=0.0
          dip(i)=0.0
          sigma(i)=0.25
        }
#
#     compute the shear wave velocity form the
#      P wave velocity
#
      do i=1,nl {
         vpvs=sqrt((2.*(1.-sigma(i)))/(1.-2.*sigma(i)))
         sv(i)=pv(i)/vpvs
         rho(i)=0.77+0.32*pv(i)
       }
#
#  output the velocities in TJO format
#
      ofile= '                                '
      ofile(1:8) = tempname(1:8)
      title = ofile
      open(unit=oun2 ,file=ofile)
      rewind oun2

      write(oun2,200) nl,title
   
      do i=1,nl {

        write(oun2,100) i,pv(i),sv(i),rho(i),thik(i),qp(i),qs(i),strk(i),dip(i),por(i)
      }
      
      close(unit=oun2)

#
#  formats
#
  100 format(i3,1x,9f8.4)
  200 format(i3,1x,a32)
      end
