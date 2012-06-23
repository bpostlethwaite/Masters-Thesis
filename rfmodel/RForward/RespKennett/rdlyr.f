      logical function rdlyr (iflag,sitefl,nlmax,nlyrs,title,
     &   vp,vs,rho,h,vpb,vsb,rhob,qp,qs)
c
c        rdlyr - read a layered-medium file
c     arguments:
c        iflag - options
c              abs(iflag/2) > 0, don't ask to list model layers
c              abs(iflag/4) > 0, don't write out model description
c     function result:
c        true/false depending on whether read successful or not.

      parameter (iu=20)
      character sitefl*(*),title*32
      logical yes,yesno
      real vp(nlmax),vs(nlmax),rho(nlmax),h(nlmax)
      real vpb(nlmax),vsb(nlmax),rhob(nlmax),qp(nlmax),qs(nlmax)
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
     &   write(*,104) sitefl,title,nlyrs
      if(yes) write(*,105)
      do i=1,min(nlyrs,nlmax)
         read(iu,101) k,
     &      vp(i),vs(i),rho(i),h(i),
     &      vpb(i),vsb(i),rhob(i),qp(i),qs(i)
         if(k.ne.i) then
            close(unit=iu)
            write(0,102)
	    rdlyr = .false.
	    return
	 endif
         if(yes)
     &      write(*,106) i,vp(i),vs(i),rho(i),h(i),
     &                         vpb(i),vsb(i),rhob(i),
     &                         qp(i),qs(i)
         if(i.gt.1) then
	    if (vpb(i-1).ne.0) then
	       if (vpb(i-1).ne.vp(i) .or.
     &             rhob(i-1).ne.rho(i)) go to 999
	    endif
	    if (vsb(i-1).ne.0) then
	       if (vsb(i-1).ne.vs(i) .or.
     &             rhob(i-1).ne.rho(i)) go to 999
	    endif
	 endif
      enddo
      rdlyr = h(min(nlmax,nlyrs)) .eq. 0
      close(unit=iu)
      if (.not.rdlyr) write(*,107) min(nlmax,nlyrs)
      return

  999 continue
      write(0,103) i
      close(unit=iu)
      rdlyr = .false.

  100 format(i3,a10)
  101 format(i3,1x,9f8.2)
  102 format('**RDLYR:  Layers out of order')
  103 format('**RDLYR:  Speed or rho disc. at base of gradient,',
     &   ' layer ',i2)
  104 format(' file: ',a10,' model: ',a10,2x,i3,' layers ')
  105 format(/,/,' lyr     vp      vs     rho      h     vp',
     *           '      vs     rho       ???')
  106 format(1x,i3,1x,9f8.2)
  107 format('**RDLYR:  Last layer ',i3,' not zero thickness')
      end
