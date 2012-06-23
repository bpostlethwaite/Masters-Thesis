      subroutine asktxt(quest,answer)
c
c   interactive i-o for character strings
c      string returned may be a maximun of 64 characters
c
      character quest*(*)
      character*64 answer
      character*8 myformat
      integer ounit
      common /innout/ inunit,ounit
c
      ilen = len(quest)
      write(myformat,'(a2,i3.3,a3)')'(a',ilen,',$)'
c      
      write(ounit,myformat) quest
c
c     write(ounit,100) (quest(j:j),j=1,len(quest))
c
      read(inunit,200) answer
  100 format(80(a1,$))
  200 format(a64)
      return
      end
