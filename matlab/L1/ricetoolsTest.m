% Rice toolbox practise

addpath /home/bpostlet/programming/matlab/rwt



      x = makesig('LinChirp',8);
      h = daubcqf(4,'min');
      L = 2;
      [y,L] = mdwt(x,h,L);