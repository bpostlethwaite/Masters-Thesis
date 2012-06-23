FFLAGS = -O2
FFLAGS = -g
CFLAGS = -g
FC=gfortran
#To optimize, use the next FFLAGS
#FFLAGS = -O4
SACLIBRARY = /usr/local/lib/sac.a
BINDIR = .

OBJ = kntfun.o rcvrfn.o ifmat.o abm.o rdlyr.o

all:  rfksyn rfmisfit rfreformat

respknt: respknt.o $(OBJ)
	$(FC) $(FFLAGS) -o $(BINDIR)/respknt respknt.o \
	   $(OBJ) $(SACLIBRARY)

rfksyn: rfksyn.o $(OBJ)
	$(FC) $(FFLAGS) -o $(BINDIR)/rfksyn rfksyn.o \
	   $(OBJ) $(SACLIBRARY)

rfmisfit: rfmisfit.o
	$(FC) $(FFLAGS) rfmisfit.o -o $(BINDIR)/rfmisfit $(SACLIBRARY)

runtest: runtest.o runcmd.o
	$(FC) $(FFLAGS) runtest.o runcmd.o -o $(BINDIR)/runtest

rfreformat: rfreformat.o
	$(CC) $(CFLAGS) rfreformat.o -o $(BINDIR)/rfreformat

rfksyn.o: rfksyn.f kennett.inc
respknt.o: respknt.f kennett.inc
rcvrfn.o: rcvrfn.f kennett.inc
ifmat.o:  ifmat.f kennett.inc
kntfun.o: kntfun.f 
abm.o: abm.f

tlag.o: tlag.f tlag.com
tlag: tlag.o rdlyr.o qromb.o polint.o kntfun.o
	$(FC) $(FFLAGS) -o tlag tlag.o rdlyr.o qromb.o polint.o kntfun.o

clean:
	/bin/rm -f *.o smp.mod_sp*

distclean: clean
	/bin/rm -f rfksyn rfmisfit rfreformat runtest testint

testint: testint.o realft.o four1.o
	$(FC) $(FFLAGS) -o testint testint.o realft.o four1.o $(SACLIBRARY)

src-dist: distclean
	/bin/rm -rf /tmp/rfksyn ; mkdir /tmp/rfksyn
	cp -R . /tmp/rfksyn 
	/bin/rm -rf /tmp/rfksyn/{CVersion,.dpar,.sachist,.DS_store}
	tar cfz /tmp/rfksyn.tgz -C /tmp rfksyn
