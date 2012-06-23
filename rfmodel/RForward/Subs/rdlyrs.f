      subroutine rdlyrs (sitefl,nlyrs,title,vp,vs,rho,h,
     *qp,qs,strike,dip,iflag,ier)
c
c        rdlyr - read a layered-medium file
c     arguments:
c        iflag = -1 a dipping layer model is read in with
c                   the strike and dip of the bottom of the ith layer
c                   given in the input file
c              = 0  an infinite q, flat layered model is assumed
c              = 1  a finite q, flat-layered model is assumed, qp & qs
c                   must be non-zero in the file
c              abs(iflag/2) > 0, don't ask to list model layers
c              abs(iflag/4) > 0, don't write out model description
c        ier = 0 unless the layered numbers are screwed up
c
      character*32 sitefl,title
      logical yes,yesno
      real  vp(1),vs(1),qp(1),qs(1),rho(1),h(1),strike(1),dip(1)
      integer ounit
      common /innout/ inunit,ounit
      iu=20
      if (mod(abs(iflag/2),2) .gt. 0) then
	yes=.false.
      else
        yes=yesno('List the site model? (y or n) ')
      endif
      open(unit=iu,file=sitefl)
      rewind iu
      read (iu,100) nlyrs,title
      ier=0
      if (mod(abs(iflag/4),2) .eq. 0)
     &   write(ounit,104) sitefl,title,nlyrs
      if(yes) write(ounit,105)
      do 6 i=1,nlyrs
      read(iu,101) k,vp(i),vs(i),rho(i),h(i),qpk,qsk,theta,delta
      if(k.eq.i) go to 4
        write(ounit,102)
        ier=1
        close(unit=iu)
        return
    4 if(sign(mod(iflag,2),iflag)) 1,2,3
    1 strike(i)=theta
      dip(i)=delta
      if(i.ne.nlyrs) go to 5
         if((theta.ne.0)) write(ounit,103)
         if((delta.ne.0)) write(ounit,103)
         go to 5
    2 qp(i)=-1.
      qs(i)=-1.
      go to 5
    3 qp(i)=qpk
      qs(i)=qsk
      if(qp(i).lt.0) qp(i)=.75*(vp(i)/vs(i))**2*qs(i)
    5 if(yes) write(ounit,106) i,vp(i),vs(i),rho(i),h(i),
     *                         qpk,qsk,theta,delta
    6 continue
      close(unit=iu)
      return
  100 format(i3,a10)
  101 format(i3,1x,8f8.2)
  102 format(' layers out of order in rdlyrs *******')
  103 format(' warning -- strike and dip of half space were given')
  104 format(' file: ',a10,' model: ',a10,2x,i3,' layers ')
  105 format(/,/,' lyr     vp      vs     rho      h     qp',
     *           '      qs     strike    dip')
  106 format(1x,i3,1x,8f8.2)
      end
