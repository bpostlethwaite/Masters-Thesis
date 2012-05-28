FFLAGS=	-C 
FC=/usr/local/gfortran/bin/gfortran

CFLAGS=	-O
#HOME=/ivana/bostock/Bin
HOME=.
OBJS= libsun.o libtau.o emiasp91.o iargc.o getarg.o

get_tt:	get_tt.o $(OBJS)
	gfortran get_tt.o $(OBJS) -o $(HOME)/get_tt

remodl: remodl.o $(OBJS)
	gfortran remodl.o $(OBJS) -o $(HOME)/remodl

setbrn: setbrn.o $(OBJS)
	gfortran setbrn.o $(OBJS) -o $(HOME)/setbrn

ttimes: ttimes.o $(OBJS)
	gfortran ttimes.o $(OBJS) -o $(HOME)/ttimes
