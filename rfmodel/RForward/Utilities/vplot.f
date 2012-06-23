      program vplot
      dimension x(200),y(200),p(100,3),h(100),qp(100),qs(100),
     *          strike(200),dip(200)
      character*32 vfile,of,title
      integer blank,ounit
      character*4 suf(3)
      common /innout/ inunit,ounit
      data suf /'.vp ','.vs ','.rho'/
c
      inunit=5
      ounit=6
c
      call asktxt('velocity file  ',vfile)
      call rdlyrs(vfile,nlyrs,title,p(1,1),p(1,2),p(1,3),h,
     *            dum1,dum2,strike,dip,-1,ier)
      do 2 ik=1,3
      	x(1)=0.
      	y(1)=p(1,ik)
      	ij=1
      	do 1 i=1,nlyrs-1
      		v=p(i,ik)
      		v2=p(i+1,ik)
      		ij=ij+1
      		x(ij)=x(ij-1)-h(i)
      		y(ij)=v
      		x(ij+1)=x(ij)
      		y(ij+1)=v2
      		ij=ij+1
    1 	continue
      	ij=ij+1
      	x(ij)=x(ij-1)-30.
      	y(ij)=p(nlyrs,ik)
      	of=vfile(1:blank(vfile))//suf(ik)
      	call wsac2(of,x,ij,y,nerr)
    2 continue
      stop
      end

