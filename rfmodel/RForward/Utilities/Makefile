.SUFFIXES: .r
.r.f:
	ratfor -C $< > $@
FFLAGS = -g
#To optimize, use the next FFLAGS
#FFLAGS = -O4
SACLIBRARY = $(SACLIB)
SACLIBRARY = /usr/local/lib/geophy/sac.a
SACLIBRARY = /usr/local/src/geophy/sac-linux/lib/sac.a
TJOLIB = ../Subs/subs.a
BINDIR = ../../bin
BINDIR = ../../RInversion

mostcommon: icmod stacksac ppstime modtable manyvplot vplot

gradmod: gradmod.o
	f77 $(FFLAGS) -o $(BINDIR)/gradmod gradmod.f \
	$(TJOLIB)  $(SACLIBRARY)

rstack: rstack.o
	f77 $(FFLAGS) -o $(BINDIR)/rstack rstack.f \
	$(TJOLIB)  $(SACLIBRARY)

icmod: icmod.o
	f77 $(FFLAGS) -o $(BINDIR)/icmod icmod.f \
	$(TJOLIB)  $(SACLIBRARY)

stacksac: stacksac.f
	f77 $(FFLAGS) -o $(BINDIR)/stacksac stacksac.f $(SACLIBRARY)

ppstime: ppstime.f
	f77 $(FFLAGS) -o $(BINDIR)/ppstime ppstime.f $(TJOLIB) $(SACLIBRARY)

ptime: ptime.f
	f77 $(FFLAGS) -o $(BINDIR)/ptime ptime.f $(TJOLIB) $(SACLIBRARY)

rlowpass: rlowpass.o	
	f77 $(FFLAGS) -o $(BINDIR)/rlowpass rlowpass.o $(TJOLIB) $(SACLIBRARY)
rlowpass.o: rlowpass.f

modtable: modtable.o
	f77 $(FFLAGS) -o $(BINDIR)/modtable modtable.f

manyvplot: manyvplot.f	
	f77 $(FFLAGS) -o $(BINDIR)/manyvplot manyvplot.f \
	$(TJOLIB) $(SACLIBRARY)

manyvsmpl: manyvsmpl.f	
	f77 $(FFLAGS) -o $(BINDIR)/manyvsmpl manyvsmpl.f $(TJOLIB) $(SACLIBRARY)

modelgen: modelgen.f	
	f77 $(FFLAGS) -o $(BINDIR)/modelgen modelgen.f  $(SACLIBRARY)

modstat: modstat.f	
	f77 $(FFLAGS) -o $(BINDIR)/modstat modstat.f

mgentjo: mgentjo.f 
	f77 $(FFLAGS) -o $(BINDIR)/mgentjo mgentjo.f $(SACLIBRARY)

vsmpl: vsmpl.f	
	f77 $(FFLAGS) -o $(BINDIR)/vsmpl vsmpl.f $(TJOLIB) $(SACLIBRARY)

vplot: vplot.f
	f77 $(FFLAGS) -o $(BINDIR)/vplot vplot.f $(TJOLIB) $(SACLIBRARY)
