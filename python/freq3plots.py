#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import os, json
from dbutils import queryStats, getStats
from plot import Args, Params
import matplotlib.pyplot as plt
import numpy as np
from scipy.signal import detrend
from scipy.stats import pearsonr
from matplotlib.backends.backend_pdf import PdfPages


args = Args()
args.stationList ="ACKN AP3N CLPO COWN DELO DSMN DVKN FRB GALN GIFN ILON LAIN MALO MLON ORIO PEMO PLVO SEDN SILO SNPN SRLN TYNO ULM WAGN WLVO YBKN YOSQ"
args.addQuery("status","in", "processed")

hf = Params(os.environ['HOME'] + '/thesis/stations.json', ["Vp","H","R"])
mb = Params( os.environ['HOME'] + '/thesis/stations_old.json', ["Vp","H","R"])

mb.filterParams(args)
hf.matchStns(mb.stns)

plt.figure(num = 100, figsize = (10, 10) )
#see http://matplotlib.org/examples/pylab_examples/subplots_demo.html
ax1 = plt.subplot(311)
plt.plot(mb.H, mb.R, 'ob', label = 'Vp/Vs MB')
plt.plot(hf.H, hf.R, 'or', label = 'Vp/Vs 3hz MB')
plt.title("3D Grid search Vp/Vs, Vp and Vs against crustal thickness H")
plt.ylabel("Vp/Vs")
plt.legend(loc=2)
plt.setp( ax1.get_xticklabels(), visible=False)

ax2 = plt.subplot(312, sharex = ax1)
plt.plot(mb.H, mb.Vp, 'ob', label = 'Vp MB')
plt.plot(hf.H, hf.Vp, 'or', label = 'Vp 3hz MB')
plt.ylabel("Vp [km/s]")
plt.legend(loc=2)
plt.setp( ax1.get_xticklabels(), visible=False)

ax3 = plt.subplot(313, sharex = ax1)
plt.plot(mb.H, mb.Vs, 'ob', label = 'Vs MB')
plt.plot(hf.H, hf.Vs, 'or', label = 'Vs 3hz MB')
plt.xlabel("Crustal Thickness H [km]")
plt.ylabel("Vs [km/s]")
plt.legend(loc=2)

plt.show()
