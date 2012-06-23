      function ttest(data1,n1,data2,n2)
      real data1(n1),data2(n2)
      call avevar(data1,n1,ave1,var1)
      call avevar(data2,n2,ave2,var2)
      df=n1+n2-2
      var=((n1-1)*var1 + (n2-1)*var2)/df
      t=(ave1-ave2)/sqrt(var*(1./n1 + 1./n2))
      ttest=betai(0.5*df,0.5,df/(df+t**2))
      end

      subroutine avevar(data,n,ave,var)
      real data(n)
      ave=0.0
      do j=1,n
         ave=ave+data(j)
      enddo
      ave=ave/n
      var=0.0
      ep=0.0
      do j=1,n
         s=data(j)-ave
	 ep=ep+s
	 var=var+s*s
      enddo
      var=(var-ep**2/n)/(n-1)
      end

      FUNCTION BETAI(A,B,X)
      IF(X.LT.0..OR.X.GT.1.)PAUSE 'bad argument X in BETAI'
      IF(X.EQ.0..OR.X.EQ.1.)THEN
        BT=0.
      ELSE
        BT=EXP(GAMMLN(A+B)-GAMMLN(A)-GAMMLN(B)
     *      +A*ALOG(X)+B*ALOG(1.-X))
      ENDIF
      IF(X.LT.(A+1.)/(A+B+2.))THEN
        BETAI=BT*BETACF(A,B,X)/A
        RETURN
      ELSE
        BETAI=1.-BT*BETACF(B,A,1.-X)/B
        RETURN
      ENDIF
      END

      FUNCTION GAMMLN(XX)
C     Returns the value ln(gamma(x)) for x > 0.  Full accuracy is obtained
C     for x > 1.  For 0 < x < 1, the reflection formula can be used first.
      REAL*8 COF(6),STP,HALF,ONE,FPF,X,TMP,SER
      DATA COF,STP/76.18009173D0,-86.50532033D0,24.01409822D0,
     *    -1.231739516D0,.120858003D-2,-.536382D-5,2.50662827465D0/
      DATA HALF,ONE,FPF/0.5D0,1.0D0,5.5D0/
      X=XX-ONE
      TMP=X+FPF
      TMP=(X+HALF)*LOG(TMP)-TMP
      SER=ONE
      DO 11 J=1,6
        X=X+ONE
        SER=SER+COF(J)/X
11    CONTINUE
      GAMMLN=TMP+LOG(STP*SER)
      RETURN
      END

      FUNCTION betacf(a,b,x)
      INTEGER MAXIT
      REAL betacf,a,b,x,EPS,FPMIN
      PARAMETER (MAXIT=100,EPS=3.e-7,FPMIN=1.e-30)
      INTEGER m,m2
      REAL aa,c,d,del,h,qab,qam,qap
      qab=a+b
      qap=a+1.
      qam=a-1.
      c=1.
      d=1.-qab*x/qap
      if(abs(d).lt.FPMIN)d=FPMIN
      d=1./d
      h=d
      do 11 m=1,MAXIT
        m2=2*m
        aa=m*(b-m)*x/((qam+m2)*(a+m2))
        d=1.+aa*d
        if(abs(d).lt.FPMIN)d=FPMIN
        c=1.+aa/c
        if(abs(c).lt.FPMIN)c=FPMIN
        d=1./d
        h=h*d*c
        aa=-(a+m)*(qab+m)*x/((a+m2)*(qap+m2))
        d=1.+aa*d
        if(abs(d).lt.FPMIN)d=FPMIN
        c=1.+aa/c
        if(abs(c).lt.FPMIN)c=FPMIN
        d=1./d
        del=d*c
        h=h*del
        if(abs(del-1.).lt.EPS)goto 1
11    continue
      pause 'a or b too big, or MAXIT too small in betacf'
1     betacf=h
      return
      END
