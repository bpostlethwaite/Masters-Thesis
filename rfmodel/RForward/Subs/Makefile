FFLAGS = -O2
SUBS = ask.o asktxt.o blank.o coef8.o coefsh.o \
    coord.o daymo.o dfftr.o diffr.o dot.o doy.o \
    fft.o fsorce.o g1.o g2.o h12.o iask.o \
    iniocm.o juli.o locast.o lpyr.o max.o minmax.o \
    npowr2.o qrbd.o rdlyrs.o rotate.o sacio.o seisio.o \
    sinc.o sit2.o svdrs.o yesno.o zero.o 
subs.a: $(SUBS)
	ar cr subs.a $(SUBS)
	ranlib subs.a
clean:
	/bin/rm *.o

ask.o:  ask.f 
asktxt.o:  asktxt.f 
blank.o:  blank.f 
coef8.o:  coef8.f 
coefsh.o:  coefsh.f 
coord.o:  coord.f 
daymo.o:  daymo.f 
dfftr.o:  dfftr.f 
diffr.o:  diffr.f 
dot.o:  dot.f 
doy.o:  doy.f 
fft.o:  fft.f 
fsorce.o:  fsorce.f 
g1.o:  g1.f 
g2.o:  g2.f 
h12.o:  h12.f 
iask.o:  iask.f 
iniocm.o:  iniocm.f 
juli.o:  juli.f 
locast.o:  locast.f 
lpyr.o:  lpyr.f 
max.o:  max.f 
minmax.o:  minmax.f 
npowr2.o:  npowr2.f 
qrbd.o:  qrbd.f 
rdlyrs.o:  rdlyrs.f 
rotate.o:  rotate.f 
sacio.o:  sacio.f 
	f77 $(FFLAGS) -Nq300 -c sacio.f
seisio.o:  seisio.f 
sinc.o:  sinc.f 
sit2.o:  sit2.f 
svdrs.o:  svdrs.f 
yesno.o:  yesno.f 
zero.o:  zero.f 
