.SUFFIXES: .r
.r.f:
	ratfor -C $< > $@
FFLAGS = -g -xl
FFLAGS = -g
#To optimize, use the next FFLAGS
#FFLAGS = -O4
TJOLIB = ../Subs/subs.a
BINDIR = .
SACLIB= /usr/local/src/geophy/sac-linux/lib/sac.a

ray3d: ray3d.o	$(TJOLIB)
	f77 $(FFLAGS) -o $(BINDIR)/ray3d ray3d.o $(TJOLIB) $(SACLIB)

ray3d.o: ray3d.f
