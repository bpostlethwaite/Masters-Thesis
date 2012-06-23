      function dot(x,y)
c
c  calculates the dot product of two vectors
c
      dimension x(1),y(1)
      z=0.
      do 1 i=1,3
    1    z=z + x(i)*y(i)
      dot=z
      return
      end
