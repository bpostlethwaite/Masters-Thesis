      integer function blank(file)
c
c   routine to find the position of the first blank (' ')
c   character in a character variable called file
c
c   len is a UNIX Ridge function to find the length of a character variable
c   then leng defines the maximum value of blank
c
      character*(*) file
      integer ounit
      common /innout/ inunit,ounit
      leng=len(file)
      do 1 i=1,leng
         if(file(i:i).ne.' ') go to 1
            blank=i-1
            return
    1 continue
c  
c   if no ' ' is found, set blank = leng   
c 
      blank=leng
      return
      end
