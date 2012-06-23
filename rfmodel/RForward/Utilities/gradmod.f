c  program for interactive creation of velocity models
c
      parameter(max=200)
      dimension pv(max),sv(max),rho(max),hinc(max),qp(max),qs(max)
      dimension strk(max),dip(max),por(max),sigma(max)
      integer ounit,oun2
      character*32 ofile,title
      logical yes,yesno
      common /innout/ inunit,ounit
      ounit=6
      inunit=5
      oun2=8
c
c  set defaults
c
      do 98 i=1,max
          qp(i)=0.0
          qs(i)=0.0
          strk(i)=0.0
          dip(i)=0.0
          sigma(i)=0.25
 98   continue
c
 99   write(ounit,*)'top P wave velocity'
      read(inunit,*) vtop
      write(ounit,*)'bottom P wave velocity'
      read(inunit,*) vbot
      write(ounit,*)'transition zone thickness'
      read(inunit,*) thic
      write(ounit,*)'number of layers'
      read(inunit,*) nl
      write(ounit,*)'beginning layer number'
      read(inunit,*) lnum
       
      dv=(vbot-vtop)/float(nl-1)
      dh=thic/float(nl)
c
      do 11 i=1,nl
	 pv(i)=vtop+dv*float(i-1)
	 hinc(i)=dh
11    continue
c
      hinc(nl)=0.0
c
      do 51 i=1,nl
         vpvs=sqrt((2.*(1.-sigma(i)))/(1.-2.*sigma(i)))
         sv(i)=pv(i)/vpvs
 51      rho(i)=0.77+0.32*pv(i)
c
c  calculate poissons ratio
c
 75   do 76 i=1,nl
         vpvs=pv(i)/sv(i)
         vpvs2=vpvs**2
 76      por(i)=0.5*((vpvs2-2.)/(vpvs2-1.))
c
c  check input for corrections
c
      write(ounit,700)
      do 80 i=1,nl
	 il=lnum+i-1
 80   write(ounit,701) il,pv(i),sv(i),rho(i),hinc(i),qp(i),qs(i),
     1                  strk(i),dip(i),por(i)
      yes=yesno('are these ok?  ')
      if(.not.yes) go to 99
c
c  output
c
 85   call asktxt('output file name?   ',ofile)
      open(unit=oun2,file=ofile)
      rewind oun2
      do 81 i=1,nl
	  il=lnum+i-1
 81   write(oun2,701) il,pv(i),sv(i),rho(i),hinc(i),qp(i),qs(i),
     1                 strk(i),dip(i),por(i)
      close(unit=oun2)

c
c  formats
c
 1000 format(' your options are:'
     1       /'   1 -- input all parameters for each layer'
     1       /'   2 -- same as 1 except default qp,qs,strk,dip'
     1       /'   3 -- input pv & poissons ratio; same defaults as 2'
     1       /'   4 -- input sv & poissons ratio; same defaults as 2'
     1       /'   5 -- same as 3 except default rho and poissons rat'
     1       /'   6 -- same as 4 except default rho and poissons rat'
     1       /' please input option no. ')
 1001 format(' choose between:'
     1       /'   1 -- inputting layer thkness, or'
     1       /'   2 -- depth to bottom of layer.')
 1002 format(' choose between:'
     1       /'   1 -- tjo output format'
     1       /'   2 -- srt output format, or'
     1       /'   3 -- output in both formats.')
  100 format(' input is in free format, type 0.0 for h/z to end input')
  101 format(' lyr'/' vp  vs  rho h/z  qp  qs  strk dip')
  102 format(1x,i3)
  201 format(' lyr'/' vp  vs  rho h/z')
  301 format(' lyr'/' vp  rho h/z pois')
  401 format(' lyr'/' vs  rho h/z pois')
  501 format(' lyr'/' vp  h/z')
  601 format(' lyr'/' vs  h/z')
  700 format(' lyr',t9,'vp',t17,'vs',t25,'rho',t33,'h/z',t41,
     1     'qp',t49,'qs',t57,'strk',t64,'dip',t72,'por')
  701 format(i3,1x,9f8.4)
  702 format(5(f10.5,','),f10.5)
  703 format(i3,1x,a32)
      end
