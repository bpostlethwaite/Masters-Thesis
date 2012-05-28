      program ttimes
      save
      parameter (max=60)
      logical log,prnt(3)
      character*8 phcd(max),phlst(10)
      character*41 modnam
      dimension tt(max),dtdd(max),dtdh(max),dddp(max),mn(max),ts(max)
      dimension usrc(2)
CMGB      data modnam/'/ivana/Alex/Matlab/Creager/tau_p/iasp91'/
      data modnam/'/seis/hawk/Alex/Src/Get_tt'/
      data in/1/,phlst(1)/'query'/,prnt(3)/.true./
c
      write(6,*) 'This routine for calculating travel times for'
      write(6,*) 'specific distances uses a set of precalculated'
      write(6,*) 'tau-p tables for the iasp91 model stored as'
      write(6,*) ' iasp91.hed, iasp91.tbl'
      write(6,*)
      prnt(1) = .true.
      prnt(2) = .true.
      call assign(10,2,'ttim1.lis')
      call tabin(in,modnam)
      write(6,*) 'The source depth has to be specified and also'
      write(6,*) 'the phase codes or keywords for the required branches'
      write(6,*) 'ALL will give all available branches'
      write(6,*) 'P  gives P-up,P,Pdiff,PKP, and PKiKP'
      write(6,*) 'P+ gives P-up,P,Pdiff,PKP,PKiKP,PcP,pP,pPdiff,pPKP,' 
      write(6,*) '         pPKiKP,sP,sPdiff,sPKP, and sPKiKP'
      write(6,*) 'S  gives S-up,S,Sdiff, and SKS'
      write(6,*) 'S+ gives S-up,S,Sdiff,SKS,sS,sSdiff,sSKS,pS,pSdiff,'
      write(6,*) '         and pSKS '
      write(6,*) 'basic gives P+ and S+ as well as '
      write(6,*) '         ScP, SKP, PKKP, SKKP, PP, and PKPPKP '
      write(6,*)
      write(6,*) 'or give a generic phase name'
c     write(6,*)
c     write(6,*) 'You will have to enter a distance,'
c     write(6,*) 'if this is negative a new depth is calculated'
c     write(6,*) 'TO EXIT: give negative depth'
c     write(6,*)
 3    call brnset(1,phlst,prnt)
c                                    choose source depth
      call query('Enter source depth (km) (<0 to quit):',log)
      read(*,*)zs
      if(zs.lt.0.) go to 13
      call depset(zs,usrc)
c                                    loop on delta
 1    write(*,*)
      call query('Enter deltamin, max, step (<0 for new phase):',log)
      read(*,*)delta0,delta1,dlstep
      if(delta0.lt.0.) go to 3
c     write(6,*)
      write(6,*)
     %'  delta    # code       time(s)    (min s)    dT/dD',
     %'     dT/dh      d2T/dD2'
      do 123 delta=delta0,delta1,dlstep
         call trtm(delta,max,n,tt,dtdd,dtdh,dddp,phcd)
         if(n.le.0) write(*,101)delta 
         do 4 i=1,n
           mn(i)=int(tt(i)/60.)
           ts(i)=amod(tt(i),60.)
 4       continue
         write(*,100)(delta,i,phcd(i),tt(i),mn(i),ts(i),dtdd(i),dtdh(i),
     1    dddp(i),i=1,n)
 123  continue
 100  format(1x,f6.2,i5,2x,a,f9.2,i4,f7.2,SP,f11.4,S,2e11.3)
 101  format(/1x,'No arrivals for delta =',f7.2)
      go to 1
c                                    end delta loop
 13   call retrns(in)
      call retrns(10)
      call exit(0)
      end
