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
