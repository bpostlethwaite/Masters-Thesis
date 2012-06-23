      program modelgen
      parameter(maxl = 50, max = 5000)
      dimension alfp(maxl),betp(maxl),rhop(maxl),thiki(maxl),h(maxl)
      dimension pert(maxl),alphai(maxl),betai(maxl),rhoi(maxl)
      dimension alfs(max)
      character*32 modela,title
      character ofil*8, mnum*2
      integer inunit,ounit,oun2
c     real function cubic evaluates the
c     expression cubic = z**3 + a2*z**2 + a1*z + a0
c     
      cubic(z,a2,a1,a0) = a0+z*(a1+z*(a2+z))
c
      inunit = 5
      ounit = 6
      oun2 = 8
      ofil = '        '
      mnum = '  '
      do 23000 i = 1,maxl 
         pert(i) = 0.
         alphai(i) = 0.
         alfp(i) = 0.
23000    continue
c
      write(ounit,*)'input velocity model:'
      read(inunit,'(a)')modela
      write(ounit,*)'maximum perturbation in km/sec'
      read(inunit,*) pertmax
      write(ounit,*)'Velocity to cut perturbing off'
      read(inunit,*) vcut
c
      open(unit=oun2,file=modela)
      rewind=oun2
      read(oun2,100)nlyrs,title
100   format(i3,1x,a32)
      do 23002 i1 = 1,nlyrs 
         read(oun2,110)idum,alphai(i1),betai(i1),rhoi(i1),thiki(i1), c 
&         dum1,dum2,dum3,dum4,dum5
23002    continue
110   format(i3,1x,9f8.4)
      close(unit=oun2)
c
c     convert layer thicknesses to depths
      tdpth = 0.
      nlc = nlyrs
      iflag = 0
      do 23004 i2 = 2,nlyrs 
         itemp = i2 - 1
         tdpth = tdpth + thiki(itemp)
         h(i2) = tdpth
         if(.not.(alphai(i2).le.vcut))goto 23006
            cthick = tdpth+thiki(i2+1)
            iflag = 1
            nlc = i2
23006    continue
23004    continue
      if(.not.(iflag .eq. 0))goto 23008
         cthick = thiki(nlyrs)
c
23008 continue
      h(1) = 0.
c
c     r1,r2,r3 are the roots of the cubic
c     perturbation function
c     root r3 is fixed at the bottom of the
c     model.  root r2 steps thru the model
c     root r1 varies from 'above' the model
c     thru the upper part of the model
c
      r1 = -1.
      nmods = 4
      do 23010 j1 = 1,4 
         r2 = 0.
         r3 = 1.
         do 23012 i4 = 1, nmods
c         step the remaining root around and
c           thru the model to generate perturbation
c            functions
            r2 = r2 + float(i4-1)/float(nmods)
c
c        Compute the coefficients for the
c          perturbing cubic function
            a2 = - (r1 + r2 + r3)
            a1 = r1*r2 + r1*r3 + r2*r3
            a0 = -(r1 * r2 * r3)
            amax = 0.
            write(stdout,1961) a0,a1,a2,r1,r2,r3
1961        format(1x,6(f9.3,1x))
            do 23014 i5 = 1,nlc 
               z = h(i5)/cthick
               pert(i5) = cubic(z,a2,a1,a0)
               if(.not.(amax .le. abs(pert(i5))))goto 23016
                  amax = abs(pert(i5))
23016          continue
23014          continue
c           
            anorm = pertmax/amax
            do 23018 i6 = 1,nlyrs 
               alfp(i6) = alphai(i6) + pert(i6) * anorm
23018          continue
c
c        sample the velocity structure evenly and output
c          a a SAC file
c        build the filename
c     
            inm = (j1-1)*nmods + i4
            write(ofil,'(a6,i2.2)')'pmodel',inm
c
            dth = 0.1
            nsmp = (h(nlyrs) + 5)/dth
c
            sdpth = 0.
            j = 2
            do 23020 i3 = 1,nsmp 
               sdpth = float(i3 - 1)*dth
               if(.not.(sdpth .ge. h(j)))goto 23022
                  j = j+1
23022          continue
               index = j-1
               if(.not.(index .gt. nlyrs))goto 23024
                  index = nlyrs
23024          continue
               alfs(i3) = alfp(index)
23020          continue
            open(unit=9,file=ofil)
            do 23026 j3=1,nlyrs-1
               write(9,*) alfp(j3), -h(j3)
               write(9,*) alfp(j3), -h(j3+1)
23026          continue
            write(9,*) alfp(nlyrs), -h(j3)
            write(9,*) alfp(nlyrs), -(h(j3)+10)
            close(9)
c        call wsac1(ofil,alfs,nsmp,0.,dth,nerr)
23012       continue
         r1 = r1 +.5*float(j1)
23010    continue
      stop
      end
