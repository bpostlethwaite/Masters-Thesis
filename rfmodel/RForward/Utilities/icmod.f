c  program for interactive creation of velocity models
c
      dimension pv(100),sv(100),rho(100),hinc(100),qp(100),qs(100)
      dimension strk(100),dip(100),por(100),sigma(100)
      integer ounit,oun2
      character*32 ofile,ofile2,title
      logical splt,yes,yesno
      common /innout/ inunit,ounit
      ounit=6
      inunit=5
c
c  set defaults
c
      do 98 i=1,100
          qp(i)=0.0
          qs(i)=0.0
          strk(i)=0.0
          dip(i)=0.0
          sigma(i)=0.25
 98   continue
c
c  options
c
 99   write(ounit,1000)
      read(inunit,*) iopt
      write(ounit,1001)
      read(inunit,*) ilyr
      write(ounit,1002)
      read(inunit,*) iofm
c
c  branch point
c
      go to (1,2,3,4,5,6) iopt
c
c  option one
c
 1    continue
      write(ounit,100)
      write(ounit,101)
      nl=0
 10   nl=nl+1
      write(ounit,102) nl
      read(inunit,*) pv(nl),sv(nl),rho(nl),hinc(nl),qp(nl),qs(nl),
     1                strk(nl),dip(nl)
      if(hinc(nl).ne.0.0) go to 10
      go to 70
c
c  option two
c
 2    continue
      write(ounit,100)
      write(ounit,201)
      nl=0
 20   nl=nl+1
      write(ounit,102) nl
      read(inunit,*) pv(nl),sv(nl),rho(nl),hinc(nl)
      if(hinc(nl).ne.0.0) go to 20
      go to 70
c
c  option three
c
 3    continue
      write(ounit,100)
      write(ounit,301)
      nl=0
 30   nl=nl+1
      write(ounit,102) nl
      read(inunit,*) pv(nl),rho(nl),hinc(nl),sigma(nl)
      if(hinc(nl).ne.0.0) go to 30
      do 31 i=1,nl
      vpvs=sqrt((2.*(1.-sigma(i)))/(1.-2.*sigma(i)))
 31   sv(i)=pv(i)/vpvs
      go to 70
c
c  option four
c
 4    continue
      write(ounit,100)
      write(ounit,401)
      nl=0
 40   nl=nl+1
      write(ounit,102) nl
      read(inunit,*) sv(nl),rho(nl),hinc(nl),sigma(nl)
      if(hinc(nl).ne.0.0) go to 40
      do 41 i=1,nl
      vpvs=sqrt((2.*(1.-sigma(i)))/(1.-2.*sigma(i)))
 41   pv(i)=sv(i)*vpvs
      go to 70
c
c  option five
c
 5    continue
      write(ounit,100)
      write(ounit,501)
      nl=0
 50   nl=nl+1
      write(ounit,102) nl
      read(inunit,*) pv(nl),hinc(nl)
      if(hinc(nl).ne.0.0) go to 50
      do 51 i=1,nl
      vpvs=sqrt((2.*(1.-sigma(i)))/(1.-2.*sigma(i)))
      sv(i)=pv(i)/vpvs
 51   rho(i)=0.77+0.32*pv(i)
      go to 70
c
c  option six
c
 6    continue
      write(ounit,100)
      write(ounit,601)
      nl=0
 60   nl=nl+1
      write(ounit,102) nl
      read(inunit,*) sv(nl),hinc(nl)
      if(hinc(nl).ne.0.0) go to 60
      do 61 i=1,nl
      vpvs=sqrt((2.*(1.-sigma(i)))/(1.-2.*sigma(i)))
      pv(i)=sv(i)*vpvs
 61   rho(i)=0.77+0.32*pv(i)
c
c  change depths to thkness
c
 70   if(ilyr.eq.1.or.nl.lt.3) go to 75
      nlm2=nl-2
      do 71 i=1,nlm2
      nlmi=nl-i
      nlm1=nlmi-1
 71   hinc(nlmi)=hinc(nlmi)-hinc(nlm1)
c
c  calculate poissons ratio
c
 75   do 76 i=1,nl
      vpvs=pv(i)/sv(i)
      vpvs2=vpvs**2
 76   por(i)=0.5*((vpvs2-2.)/(vpvs2-1.))
c
c  check input for corrections
c
      write(ounit,700)
      do 80 i=1,nl
 80   write(ounit,701) i,pv(i),sv(i),rho(i),hinc(i),qp(i),qs(i),
     1                  strk(i),dip(i),por(i)
      yes=yesno('are these ok?  ')
      if(.not.yes) go to 99
      splt=yesno('split lyrs for inv? ')
      if(.not.splt) go to 85
c
c  output
c
 85   call asktxt('output file name?   ',ofile)
      if(iofm.eq.1.or.iofm.eq.3) call asktxt('title?    ',title)
      open(unit=8,file=ofile)
      rewind 8
      oun2=8
      if(iofm.eq.2) go to 82
      write(oun2,703) nl,title
      do 81 i=1,nl
 81   write(oun2,701) i,pv(i),sv(i),rho(i),hinc(i),qp(i),qs(i),
     1                 strk(i),dip(i),por(i)
      if(iofm.eq.1) go to 84
      if(iofm.eq.3) then
          close(unit=8)
          call asktxt('2nd file name? ',ofile2)
          open(unit=9,file=ofile2)
          rewind 9
          oun2=9
      endif
 82   do 83 i=1,nl
 83   write(oun2,702) hinc(i),pv(i),sv(i),rho(i),qp(i),qs(i)
 84   continue
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
