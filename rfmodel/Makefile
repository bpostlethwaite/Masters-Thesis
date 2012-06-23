# Receiver function tools -- G. Helffrich/U Bristol
#    Last updated 30 July 2008
# 
# Configuration:
#  FC = your Fortran compiler
#  TPTT = location of the Buland-Kennett tau-P subroutine interface
#  SACLIB = location of the SAC I/O library

FC= f77

OPT= \
	brent.o \
	dcool.o \
	deconsubs.o \
	dilog.o \
	four1.o \
	four1d.o \
	gcdist.o \
	ludcmp.o \
	lubksb.o \
	medsq.o \
	meigen.o \
	minv.o \
	modps.o \
	mtrefps.o \
	mtaper.o \
	rayps.o \
	rkqc.o \
	rk4.o \
	sort2.o \
	sphcap.o \
	spline.o \
	savgol.o \
	tpray.o \
	tsenv.o \
	wigint.o \
	zbrent.o

SLINK= mtaper.f kbtaper.f sachdrinfo.f gnum.f realft.f four1.f rsach.f rsach.sachdr.com Pstimes.f sacslantstack.f

SPECS=
DEBUG=	-O2
DEBUG=	-g -fbounds-check
FFLAGS= ${DEBUG} ${SPECS}
PFLAGS= ${DEBUG}
CFLAGS= -g

TPTT= /usr/local/lib/geophy/tpttsub.o
TPTT= /usr/local/lib/tpttsub.o
SACLIB= /usr/local/lib/sac.a
SACLIB= /usr/local/lib/libsacio.a
SACLIB= /usr/local/lib/libg77-sacio.a

all: hk sacxymag setrfslow sacrfmigrate Pstimes sachdrinfo

${OPT}:
	$(FC) -O2 -c $*.f

rsach.o: rsach.sachdr.com

hk: hk.o wigint.o gnum.o tokens.o hilbert.o realft.o four1.o
	$(FC) ${FFLAGS} -o hk \
	   hk.o wigint.o gnum.o tokens.o hilbert.o realft.o four1.o ${SACLIB}

setrfslow: setrfslow.o gcdist.o tokens.o rsach.o ${SACLIB} ${TPTT}
	$(FC) ${FFLAGS} -o setrfslow setrfslow.o tokens.o gcdist.o rsach.o \
	   ${SACLIB} ${TPTT}

wintest: wintest.o realft.o four1.o kbtaper.o mtaper.o
	$(FC) ${FFLAGS} -o wintest wintest.o realft.o four1.o kbtaper.o \
	   mtaper.o ${SACLIB}

mtdecon: mtdecon.o realft.o four1.o mtaper.o gnum.o tokens.o
	$(FC) ${FFLAGS} -o mtdecon mtdecon.o realft.o four1.o mtaper.o gnum.o \
	   tokens.o ${SACLIB}

mttest: mttest.o realft.o four1.o mtaper.o gnum.o rsach.o
	$(FC) ${FFLAGS} -o mttest mttest.o realft.o four1.o mtaper.o gnum.o \
	   rsach.o ${SACLIB}

iascstimes: iascstimes.o viasp91.o brent.o ${TPTT}
	$(FC) ${FFLAGS} -o iascstimes iascstimes.o ${TPTT} viasp91.o brent.o

markttsac: markttsac.o gcdist.o rsach.o ${TPTT}
	$(FC) ${FFLAGS} -o markttsac markttsac.o gcdist.o rsach.o \
	   ${TPTT} ${SACLIB}

Pstimes: Pstimes.o tokens.o
	$(FC) ${FFLAGS} -o Pstimes Pstimes.o tokens.o ${TPTT} ${SACLIB}

recfunk: recfunk.o gcdist.o mtaper.o
	$(FC) ${FFLAGS} -o recfunk recfunk.o gcdist.o mtaper.o ${SACLIB}

recfunk.orig: recfunk.orig.o
	$(FC) ${FFLAGS} -o recfunk.orig recfunk.orig.o ${SACLIB}

sacrfmigrate: sacrfmigrate.o gnum.o wigint.o gcdist.o rsach.o \
	   hilbert.o realft.o four1.o geogmean.o
	$(FC) ${FFLAGS} -o sacrfmigrate sacrfmigrate.o wigint.o \
	   gnum.o gcdist.o rsach.o hilbert.o realft.o four1.o \
	   geogmean.o ${SACLIB} ${TPTT}

sacrfproject: sacrfproject.o gnum.o wigint.o gcdist.o rsach.o rayint.o bsint.o \
	   vprem.o vak135.o viasp91.o vsp6.o
	$(FC) ${FFLAGS} -o sacrfproject sacrfproject.o wigint.o rayint.o \
	   gnum.o gcdist.o rsach.o bsint.o \
	   vprem.o vak135.o viasp91.o vsp6.o ${SACLIB} ${TPTT}

sacxymag:  sacxymag.o rsach.o
	$(FC) ${FFLAGS} -o sacxymag sacxymag.o rsach.o ${SACLIB}

sachdrinfo: sachdrinfo.o tokens.o
	$(FC) ${FFLAGS} -o sachdrinfo sachdrinfo.o tokens.o ${SACLIB}

sacslantstack: sacslantstack.o tokens.o gnum.o four1.o tsenv.o wigint.o \
	   gcdist.o geogmean.o rsach.o hilbert.o
	$(FC) ${FFLAGS} -o sacslantstack sacslantstack.o tokens.o wigint.o \
	   gnum.o four1.o tsenv.o hilbert.o gcdist.o geogmean.o rsach.o \
	   ${SACLIB} ${TPTT}

$(SLINK): links
links:
	for f in $(SLINK) ; do \
	    [ -r $$f ] || ln -sf ~/seismo/src/$$f $$f ; \
	done

dist-rfmodel:
	/bin/rm -rf /tmp/rfmodel smp.mod_sp*
	mkdir /tmp/rfmodel
	cp README Makefile setrfslow.f sacxymag.f hk.f sacrfmigrate.f \
	   sacslantstack.f rfxsect Pstimes.f sachdrinfo.f \
	   gnum.f geogmean.f tokens.f hilbert.f wigint.f \
	   rsach.f rsach.sachdr.com gcdist.f rfxsect vsfromrfamp \
	   mtdecon.f mtaper.f mtrf \
	   /tmp/rfmodel
	-cp -r ~/seismo/sources/Rftn.Codes/{RForward,RInversion} /tmp/rfmodel
	cp ~/seismo/sacmacro/ss-stack{,.sh} /tmp/rfmodel
	find /tmp/rfmodel -type f \
	   \( -name '*.o' -o -name '.DS_Store' -o -name '.sachist' -o \
	      -name '.gdb_history' \
	   \) \
	   -exec /bin/rm -f {} \;

	tar cfz /tmp/rfmodel.tgz -C /tmp rfmodel
