.SUFFIXES: .r
.r.f:
	ratfor -C $< > $@
#
#
BINDIR = ../bin
BINDIR = .
#
SACLIBRARY = $(SACLIB)
SACLIBRARY = /usr/local/lib/sac.a
#
TJOLIB = ../RForward/Subs/subs.a
#
# For debugging runs use the next FFLAGS
#
FFLAGS = -g
FFLAGS = -O2
# For optimum runs use the next FFLAGS
#
# FFLAGS = -O4
#
INV =  jinv.o getmodl.o getseis.o jsoln.o wrtsoln.o \
       putsyn.o putpartl.o sacin.o sacout.o rftn_partials.o \
       putseis.o bufilter.o putsvalues.o pratio_utils.o
#
MINV = manyinv.o $(INV)
SNV =  snglinv.o $(INV)
SMTHL = smthinv.o $(INV)
#
all: manyinv snglinv smthinv
#
manyinv: $(MINV)
	f77 $(FFLAGS) $(MINV) -o $(BINDIR)/manyinv $(TJOLIB) $(SACLIBRARY)
#
snglinv: $(SNV)
	f77 $(FFLAGS) $(SNV) -o $(BINDIR)/snglinv $(TJOLIB) $(SACLIBRARY)
#
smthinv: $(SMTHL)
	f77 $(FFLAGS) $(SMTHL) -o $(BINDIR)/smthinv $(TJOLIB) $(SACLIBRARY)

manyinvwhat: manyinvwhat.o
	f77 $(FFLAGS) manyinvwhat.o -o $(BINDIR)/manyinvwhat $(TJOLIB)

rfmisfit: rfmisfit.o
	f77 $(FFLAGS) rfmisfit.o -o $(BINDIR)/rfmisfit $(SACLIBRARY)
#
clean:
	/bin/rm *.o  
#
purge_fortran:
	/bin/rm sacin.f jsoln.f wrtsoln.f putsyn.f sacout.f putpartl.f putsvalues.f 
	/bin/rm manyinv.f snglinv.f smthinv.f jinv.f getmodl.f getseis.f 
#
#
# Dependencies
#
#  ratfor:
#
manyinv.f: manyinv.r
snglinv.f: snglinv.r
smthinv.f: smthinv.r
jinv.f: jinv.r
getmodl.f: getmodl.r
getseis.f: getseis.r
sacin.f: sacin.r
jsoln.f: jsoln.r
wrtsoln.f: wrtsoln.r
putsyn.f: putsyn.r
sacout.f: sacout.r
putpartl.f: putpartl.r
putseis.f: putseis.r
bufilter.f: bufilter.r
putsvalues.f: putsvalues.r
jinvs.f: jinvs.r
ssnglinv.f: ssnglinv.r
#
manyinv.o: manyinv.f
snglinv.o: snglinv.f
smthinv.o: smthinv.f
jinv.o: jinv.f
getmodl.o: getmodl.f
getseis.o: getseis.f
sacin.o: sacin.f
jsoln.o: jsoln.f
wrtsoln.o: wrtsoln.f
putsyn.o: putsyn.f
sacout.o: sacout.f
putpartl.o: putpartl.f
putseis.o: putseis.f
bufilter.o: bufilter.f
putsvalues.o: putsvalues.f
jinvs.o: jinvs.f
ssnglinv.o: ssnglinv.f
#
# this is straight fortran, not ratfor
#
rftn_partials.o: rftn_partials.f
pratio_utils.o: pratio_utils.f
