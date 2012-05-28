      subroutine emdlv(r,vp,vs)
c         set up information on earth model (specified by
c         subroutine call emiasp)
c         set dimension of cpr,rd  equal to number of radial
c         discontinuities in model
      save
      character*(*) name
      character*20 modnam
      dimension cpr(11)
      common/emdlc/np,rd(11)
      data np,rd/11,1215.,3480.,3630.,5600.,5711.,5961.,6161.,
     1 6251.,6336.,6351.,6371./,rn,vn/1.5696123e-4,6.8501006/
      data modnam/'mdsp6'/
c
      call emmdsp6(rn*r,rho,vp,vs)
      vp=vn*vp
      vs=vn*vs
      return
c
      entry emdld(n,cpr,name)
      n=np
      do 1 i=1,np
 1    cpr(i)=rd(i)
      name=modnam
      return
      end
c
      subroutine emmdsp6(x0,ro,vp,vs)
c
c $$$$$ calls no other routine $$$$$
c
c   Emmsp6 returns model parameters for the model sp6 of 
c   Morelli & Dziewonski (August 1991)
c   
c   Given non-dimensionalized radius x0, emiasp returns
c   non-dimensionalized density, ro, compressional velocity, vp, and
c   shear velocity, vs.  Non-dimensionalization is according to the
c   scheme of Gilbert in program EOS:  x0 by a (the radius of the
c   Earth), ro by robar (the mean density of the Earth), and velocity
c   by a*sqrt(pi*G*robar) (where G is the universal gravitational
c   constant.
c
c
      save
      dimension r(14),d(13,4),p(13,4),s(13,4)
      data r/0.      ,1215.0  ,3480.0  ,3630.  ,5600.   ,5711.   ,
     1 5961.   ,6161.   ,6251.   ,6336.   ,6351.    ,6371.    ,
     2 6371.,6371./
      data d/13.01219,12.58416, 6.8143 , 6.8143 , 6.8143 ,11.11978,
     1  7.15855, 7.15855, 7.15855,  2.92  , 2.72   , 2*0.,
     2        0.     ,-1.69929,-1.66273,-1.66273,-1.66273,-7.87054,
     2 -3.85999,-3.85999,-3.85999,4*0.,
     3       -8.45292,-1.94128,-1.18531,-1.18531,-1.18531,8*0.,
     4        0.     ,-7.11215,11*0./
      data p/11.29719,11.31616,12.84645,23.61837 ,26.01542,29.39809,
     1 30.78588,25.40956, 8.78541, 6.5   , 5.8   ,2*0.,
     2        0.   , -7.091314, 1.36611,-35.5290, -17.00747,-21.40010,
     2-23.25239,-17.69281,-0.74953, 4*0.,
     3       -8.88699 ,15.75426, 0.0  ,45.20724,9*0.,
     4        0.     , -25.70488 , 0.     ,-23.92870,9*0./
      data s/ 3.66780, 0.      , 5.65120,11.87772 ,17.57267,17.72032,
     1 15.24213,5.76198, 6.70623, 3.75   , 3.36   ,2*0.,
     2        0.     , 0.      , 2.78686,-17.43557,-12.92378,-13.49239,
     2-11.08653,-1.27602,-2.24858, 4*0.,
     3       -4.44749 , 0.      , 0.0    ,23.32985 ,9*0.,
     4        0.     , 0.      , 0.     ,-12.31633,9*0./
      data xn,rn,vn/6371.,.18125793,.14598326/,i/1/
c
      x=amax1(x0,0.)
      x1=xn*x
 2    if(x1.ge.r(i)) go to 1
      i=i-1
      go to 2
 1    if(x1.le.r(i+1).or.i.ge.11) go to 3
      i=i+1
      if(i.lt.11) go to 1
 3    ro=rn*(d(i,1)+x*(d(i,2)+x*(d(i,3)+x*d(i,4))))
      vp=vn*(p(i,1)+x*(p(i,2)+x*(p(i,3)+x*p(i,4))))
      vs=vn*(s(i,1)+x*(s(i,2)+x*(s(i,3)+x*s(i,4))))
      return
      end
