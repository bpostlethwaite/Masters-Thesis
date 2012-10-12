#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import os, json
#from dbutils import queryStats, getStats
from plotTools import Args, Params
import matplotlib.pyplot as plt
import numpy as np
from scipy.signal import detrend
from scipy.stats import pearsonr
from matplotlib.backends.backend_pdf import PdfPages

#####################
# PLOT CMD
#####################
p1 = None
p2 = plt
p3 = None
p4 = None
p5 = None
p6 = None
p7 = None
######################

#######################################################################
# F1
if p1:
    p1.args = Args()
    p1.args.stationList ="ACKN AP3N CLPO COWN DELO DSMN DVKN FRB GALN GIFN ILON LAIN MALO MLON ORIO PEMO PLVO SEDN SILO SNPN SRLN TYNO ULM WAGN WLVO YBKN YOSQ"
    p1.args.addQuery("status","in", "processed")

    hf = Params(os.environ['HOME'] + '/thesis/stations.json', ["Vp","H","R"])
    mb = Params( os.environ['HOME'] + '/thesis/stations_old.json', ["Vp","H","R"])

    mb.filterParams(p1.args)
    hf.matchStns(mb.stns)

    p1.figure(num = 100, figsize = (10, 10) )
    #see http://matplotlib.org/examples/pylab_examples/subplots_demo.html
    ax1 = p1.subplot(311)
    p1.plot(mb.H, mb.R, 'ob', label = 'Vp/Vs MB')
    p1.plot(hf.H, hf.R, 'or', label = 'Vp/Vs 3hz MB')
    p1.title("3D Grid search Vp/Vs, Vp and Vs against crustal thickness H")
    p1.ylabel("Vp/Vs")
    p1.legend(loc=2)
    p1.setp( ax1.get_xticklabels(), visible=False)

    ax2 = p1.subplot(312, sharex = ax1)
    p1.plot(mb.H, mb.Vp, 'ob', label = 'Vp MB')
    p1.plot(hf.H, hf.Vp, 'or', label = 'Vp 3hz MB')
    p1.ylabel("Vp [km/s]")
    p1.legend(loc=2)
    p1.setp( ax1.get_xticklabels(), visible=False)

    ax3 = p1.subplot(313, sharex = ax1)
    p1.plot(mb.H, mb.Vs, 'ob', label = 'Vs MB')
    p1.plot(hf.H, hf.Vs, 'or', label = 'Vs 3hz MB')
    p1.xlabel("Crustal Thickness H [km]")
    p1.ylabel("Vs [km/s]")
    p1.legend(loc=2)

#######################################################################
# F2
if p2:
    p2.args = Args()
    p2.args.addQuery("stdVp", "lt", "0.6")
    # Load station params
    mb = Params(os.environ['HOME'] + '/thesis/stations.json', ["Vp","H","R"])
    mb.filterParams(p2.args)
    # Load geochron data
    gd = json.loads( open(os.environ["HOME"] + "/thesis/stnchrons.json").read() )
    mb.gc = np.zeros( (len(mb.H), 2))
    # Append geochron data onto mb object
    for i, stn in enumerate(mb.stns):
        if stn in gd:
            if not gd[stn]:
                mb.gc[i] = [np.nan, np.nan]
            else:
                mb.gc[i,:] = gd[stn]

    # Get some logical indexes for start ages within geological times of interest
    arch =  (mb.gc[:,0] <= 3800) & (mb.gc[:,0] > 2500)
    proto = (mb.gc[:,0] <= 2500) & (mb.gc[:,0] > 542)

    p2.hist(mb.R[arch], histtype='stepfilled', bins = 10, color='b', label="archean")
    p2.hist(mb.R[proto], histtype='stepfilled' , bins = 10, color='r', alpha=0.5, label='Protozoic')
    p2.title("Archean/Protozoic Vp/Vs Histogram")
    p2.xlabel("Value")
    p2.ylabel("Probability")
    p2.legend()


#######################################################################
# F3

#######################################################################
# F4

#######################################################################
# F5

#######################################################################
# F6

#######################################################################
# F7

#######################################################################


if p1:
    p1.show()
if p2:
    p2.show()
if p3:
    p3.show()
if p4:
    p4.show()
if p5:
    p5.show()
if p6:
    p6.show()
if p7:
    p7.show()

