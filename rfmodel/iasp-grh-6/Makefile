prefix= /usr/local
exec_prefix= ${prefix}
FC= gfortran
FFLAGS= -O
FFLAGS= -g -fbounds-check
FFLAGS=    
LIBLOC= /usr/local/lib/geophy
BINLOC= /usr/local/bin/geophy
BINDIR= ${exec_prefix}/bin
LIBDIR= ${exec_prefix}/lib
LIBLOC= $(LIBDIR)
BINLOC= $(BINDIR)
MANDIR= ${prefix}/share/man
MAN1DIR= $(MANDIR)/man1
MAN1EXT= .1

ID=iasp-grh

MODELS= \
	iasp91/emiasp91 \
	sp6/emsp6 \
	fakeprem/emfakeprem \
	kghj/emkghj \
	pemc/empemc \
	fakeprem20s/emfakeprem20s \
	ak135/emak135

OBJS=   remodl setbrn ttimes libsun.a libtau.a

DOC=	ttimes gtt91

all-models:
	for m in ${MODELS} ; do \
	   eval `echo $$m | \
		 awk -F/ '{printf "MODNAM=%s MODSUB=%s",$$1,$$2}'` ; \
	   /bin/rm -f modnam.inc $$MODSUB.o *.lis remodl.hed remodl.tbl ; \
	   sleep 1 ; : 'prevents change/mod time not being noticed' ; \
	   make model MODNAM=$$MODNAM MODSUB=$$MODSUB ; \
	done

all: ${OBJS}

model:	${OBJS}
	(./remodl ; ./setbrn) > /tmp/$(MODNAM).out

install-all-models:
	echo ; echo "Installing models in ${LIBLOC}"; echo
	[ -d ${LIBLOC} ] || ( \
	   mkdir ${LIBLOC} ; chmod u=rwx,g=rwxs,o=rx ${LIBLOC} \
	) ; \
	for m in ${MODELS} ; do \
	   eval `echo $$m | \
		 awk -F/ '{printf "MODNAM=%s MODSUB=%s",$$1,$$2}'` ; \
	   install -m 444 $${MODNAM}.tbl ${LIBLOC}/$${MODNAM}.tbl ; \
	   install -m 444 $${MODNAM}.hed ${LIBLOC}/$${MODNAM}.hed ; \
	done

ttimes.o remodl.o setbrn.o: limits.inc
ttimes.o: version.inc
libtau.a: libtau.f ttlim.inc limits.inc
	$(FC) ${FFLAGS} -c libtau.f
	/bin/rm -f libtau.a
	ar cq libtau.a libtau.o
	ranlib libtau.a

libsun.a: libsun.f
	$(FC) ${FFLAGS} -c libsun.f
	/bin/rm -f libsun.a
	ar cq libsun.a libsun.o
	ranlib libsun.a

install-code: ttimes-defmodel tpttsub.o
	-for i in ${LIBLOC} ${BINLOC} ; do \
	   if [ ! -d $$i ] ; then \
	      mkdir $$i ; chmod u=rwx,g=rwxs,o=rx $$i ; \
	   fi ; \
	done
	eval `echo ${MODELS} | \
		 awk '{n=split($$(NF),f,"/"); \
		         printf "MODNAM=%s MODSUB=%s",f[1],f[2] \
		      }'` ; \
	make model MODNAM=$$MODNAM MODSUB=$$MODSUB ; \
	install -m 444 $${MODNAM}.tbl ${LIBLOC}/$${MODNAM}.tbl ; \
	install -m 444 $${MODNAM}.hed ${LIBLOC}/$${MODNAM}.hed
	install ttimes ${BINLOC}/ttimes
	install tpttsub.o ${LIBLOC}/tpttsub.o
	-for i in ${MANDIR} ${MAN1DIR} ; do \
	   if [ ! -d $$i ] ; then \
	      mkdir -p $$i ; chmod u=rwx,g=rwxs,o=rx $$i ; \
	   fi ; \
	done
	-for i in ${DOC} ; do \
	   install -m 444 $$i.1 ${MAN1DIR}/$$i${MAN1EXT} ; \
	done

install: install-all
install-all:
	make install-all-models install-code

ttimes: ttimes.o libsun.a libtau.a
	$(FC) ${FFLAGS} -o ttimes ttimes.o libtau.a libsun.a

ttimes-defmodel:
	/bin/rm -f modnam.inc
	for m in ${MODELS} ; do \
	   eval `echo $$m | \
		 awk -F/ '{printf "MODNAM=%s MODSUB=%s",$$1,$$2}'` ; \
	   : MODNAM=$$MODNAM MODSUB=$$MODSUB ; \
	done ; \
	make ttimes MODNAM=$$MODNAM MODSUB=$$MODSUB

modnam.inc: Makefile
	echo "      data modnam/'"${LIBLOC}/${MODNAM}"'/" > modnam.inc

version.inc: utils/version
	echo '      character*(*) ver' > version.inc
	awk '{printf "      parameter (ver='"'"'${ID}-%d'"'"')\n",$$1}' utils/version >> version.inc

newversion utils/version:
	( test -f utils/version && cat utils/version || echo 0 ) | \
	   awk '{print $$1+1}' > utils/newversion
	mv -f utils/newversion utils/version

ttimes.o: ttimes.f modnam.inc

remodl: remodl.o ${MODSUB}.o libsun.a libtau.a Makefile
	$(FC) ${FFLAGS} -o remodl remodl.o ${MODSUB}.o libtau.a libsun.a

setbrn: setbrn.o libsun.a libtau.a
	$(FC) ${FFLAGS} -o setbrn setbrn.o libtau.a libsun.a

tpttsub.o: tptt.f tptt.com modnam.inc libtau.a libsun.a
	$(FC) ${FFLAGS} -c tptt.f
	ld -r -o tpttsub.o tptt.o libtau.a libsun.a

clean: ; /bin/rm -f *.o *.hed *.tbl *.lis ${OBJS}
	for m in ${MODELS} ; do \
	   eval `echo $$m | \
		 awk -F/ '{printf "MODNAM=%s MODSUB=%s",$$1,$$2}'` ; \
	   /bin/rm -f /tmp/$$MODNAM.out ; \
        done

uninstall:
	/bin/rm -f ${BINLOC}/ttimes
	/bin/rm -f ${LIBLOC}/tpttsub.o
	-for m in ${MODELS} ; do \
	   /bin/rm -f `echo $$m | \
	      awk -F/ '{printf "${LIBLOC}/%s.tbl ${LIBLOC}/%s.hed",$$1,$$1}'` ;\
	done
	-for i in ${DOC} ; do \
	   /bin/rm -f ${MAN1DIR}/$$i${MAN1EXT} ; \
	done

dist: utils/version
	make clean
	/bin/rm -rf autom4te.cache config.log config.status
	VER=${ID}-`cat utils/version` ; \
	/bin/rm -rf /tmp/$${VER}; mkdir /tmp/$${VER} ; \
	cp -r . /tmp/$${VER} ; /bin/rm /tmp/$${VER}/Makefile ; \
	tar cfz /tmp/$${VER}.tgz -C /tmp $$VER ; \
	echo "Distribution version in /tmp/$${VER}"
