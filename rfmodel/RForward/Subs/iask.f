      function iask(quest)
c
c      interactive i-o for integers
c
      integer answer,ounit
      character quest*(*)
      common /innout/ inunit,ounit
      write(ounit,100) (quest(j:j),j=1,len(quest))
      read(inunit,*) answer
      iask=answer
      return
  100 format(80(a1,$))
      end
