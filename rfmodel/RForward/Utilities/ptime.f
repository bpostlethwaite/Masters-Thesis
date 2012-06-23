      program Ptime
c	
c	Two-way P travel time through a 1 d model
c

      dimension t(400),r(400),p(100,3),h(100),qp(100),qs(100),
     *          strike(200),dip(200)
      character*32 vfile,of,title
      integer blank,ounit
      character*4 suf(3)
      common /innout/ inunit,ounit
      data suf /'.dv2p ','.dvs ','.drho'/
c
      inunit=5
      ounit=6
c
      call asktxt('velocity file  ',vfile)
      call rdlyrs(vfile,nlyrs,title,p(1,1),p(1,2),p(1,3),h,
     *            dum1,dum2,strike,dip,-1,ier)
      do 2 ik=1,1
      	t(1)=0.
      	r(1)=0.
      	ij=1
      	do 1 i=1,nlyrs-1
      		v = p(i,ik)
      		v2 = p(i+1,ik)
      		ij = ij+1
      		t(ij) = t(ij-1) -  2 * h(i)*(1/p(i,1))
		r(ij) =0.
      		t(ij+1) = t(ij)
      		r(ij+1) = v2 - v
		t(ij+2) = t(ij)
		r(ij+2) = 0.
      		ij = ij+2
    1 	continue
      	ij=ij+1
      	t(ij)=t(ij-1)-2.
      	r(ij)=0
      	of=vfile(1:blank(vfile))//suf(ik)
      	call wsac2(of,t,ij,r,nerr)
    2 continue
      stop
      end

