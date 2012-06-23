      SUBROUTINE QROMB(FUNC,A,B,SS)
      PARAMETER(EPS=1.E-6,JMAX=20,JMAXP=JMAX+1,K=5,KM=4)
      DIMENSION S(JMAXP),H(JMAXP),ERR(JMAXP)
      MINERR = 1
      H(1)=1.
      DO 11 J=1,JMAX
        CALL TRAPZD(FUNC,A,B,S(J),J)
        IF (J.GE.K) THEN
          L=J-KM
          CALL POLINT(H(L),S(L),K,0.0,SS,DSS)
          IF (ABS(DSS).LE.EPS*ABS(SS)) RETURN
	  ERR(L)=DSS
	  IF (ABS(DSS) .LE. ABS(ERR(MINERR))) THEN
	    MINERR=L
	    SSMIN=SS
	  ENDIF
        ENDIF
        S(J+1)=S(J)
        H(J+1)=0.25*H(J)
11    CONTINUE
      WRITE(0,*) 'QROMB: Too many steps, returning min. error.'
      SS=SSMIN
      END
      SUBROUTINE QROMBE(FUNC,A,B,EPS,SS)
      PARAMETER(JMAX=20,JMAXP=JMAX+1,K=5,KM=4)
      DIMENSION S(JMAXP),H(JMAXP),ERR(JMAXP)
      MINERR = 1
      H(1)=1.
      DO 11 J=1,JMAX
        CALL TRAPZD(FUNC,A,B,S(J),J)
        IF (J.GE.K) THEN
          L=J-KM
          CALL POLINT(H(L),S(L),K,0.0,SS,DSS)
          IF (ABS(DSS).LE.EPS*ABS(SS)) RETURN
	  ERR(L)=DSS
	  IF (ABS(DSS) .LE. ABS(ERR(MINERR))) THEN
	    MINERR=L
	    SSMIN=SS
	  ENDIF
        ENDIF
        S(J+1)=S(J)
        H(J+1)=0.25*H(J)
11    CONTINUE
      WRITE(0,*) 'QROMB: Too many steps, returning min. error.'
      SS=SSMIN
      END
