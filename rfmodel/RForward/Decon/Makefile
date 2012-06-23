FFLAGS = -g -fbounds-check
#To optimize, use the next FFLAGS
#FFLAGS = -O4
TJOLIB = ../Subs/subs.a
BINDIR = ../../bin
TSLIB = /usr/local/lib/geophy/tslib.a
SACLIB= /usr/local/lib/geophy/sac.a

pwaveqn: pwaveqn.f	
	f77 $(FFLAGS) -o $(BINDIR)/pwaveqn pwaveqn.f $(TJOLIB) $(SACLIB)

deconeqn: deconeqn.o gcdist.o wigint.o
	f77 $(FFLAGS) -o deconeqn deconeqn.o gcdist.o wigint.o \
	    $(TJOLIB) $(TSLIB) $(SACLIB)

deconeqnew: deconeqnew.o gcdist.o four1.o realft.o kbtaper.o ttest.o
	f77 $(FFLAGS) -o deconeqnew deconeqnew.o gcdist.o ttest.o \
	    four1.o realft.o kbtaper.o $(TSLIB) $(SACLIB)
