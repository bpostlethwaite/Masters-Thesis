      function ask(quest)
c
c   interactive i-o for real numbers
c
      character quest*(*)
      integer ounit
      character*8 myformat
      common /innout/ inunit,ounit
c
      ilen = len(quest)
      write(myformat,'(a2,i3.3,a3)')'(a',ilen,',$)'
c      
      write(ounit,myformat) quest
c     write(ounit,100) (quest(j:j),j=1,len(quest))
      read(inunit,*) anser
      ask=anser
      return
  100 format(80(a1,$))
      end
