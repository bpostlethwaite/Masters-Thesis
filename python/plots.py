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
p1 = None # Comparing junk
p2 = None # Proterozoic vs Archean
p3 = None # Comparing some errors in Kanamori approach
p4 = plt # Compare values between bostock, kanamori and Mooney
p5 = None
p6 = None
p7 = None
######################

#######################################################################
# F1
if p1:
    arg1 = Args()
    arg1.stationList ="ACKN AP3N CLPO COWN DELO DSMN DVKN FRB GALN GIFN ILON LAIN MALO MLON ORIO PEMO PLVO SEDN SILO SNPN SRLN TYNO ULM WAGN WLVO YBKN YOSQ"
    arg2 = Args()

    fstns = os.environ['HOME'] + '/thesis/stations.json'
    fstnsold = os.environ['HOME'] + '/thesis/stations.json'
    hf = Params(fstns, arg2, ["mb::Vp","mb::H","mb::R"])
    mb = Params(fstnsold, arg1 , ["mb::Vp","mb::H","mb::R"])

#    hf.syncto(mb.stns)
    mb.sync(hf)

    p1.figure(num = 100, figsize = (10, 10) )
    #see http://matplotlib.org/examples/pylab_examples/subplots_demo.html
    ax1 = p1.subplot(311)
    p1.plot(mb.mb_H, mb.mb_R, 'ob', label = 'Vp/Vs MB')
    p1.plot(hf.mb_H, hf.mb_R, 'or', label = 'Vp/Vs 3hz MB')
    p1.title("3D Grid search Vp/Vs, Vp and Vs against crustal thickness H")
    p1.ylabel("Vp/Vs")
    p1.legend(loc=2)
    p1.setp( ax1.get_xticklabels(), visible=False)

    ax2 = p1.subplot(312, sharex = ax1)
    p1.plot(mb.mb_H, mb.mb_Vp, 'ob', label = 'Vp MB')
    p1.plot(hf.mb_H, hf.mb_Vp, 'or', label = 'Vp 3hz MB')
    p1.ylabel("Vp [km/s]")
    p1.legend(loc=2)
    p1.setp( ax1.get_xticklabels(), visible=False)


#######################################################################
# F2 ## Protozoic vs Archean Histograms
if p2:
    p2.figure()
    arg1 = Args()
    arg1.addQuery("usable", "eq", "1")
    arg2 = Args()
    # Load station params
    d = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["hk::H","hk::R"])
    # Load geochron data
    g = Params(os.environ["HOME"] + "/thesis/stnChrons.json", arg2, ["lower", "upper"] )
    # Sync up data
    d.sync(g)

    # Get some logical indexes for start ages within geological times of interest
    arch =  (g.lower <= 3800) & (g.lower > 2500)
    proto = (g.lower <= 2500) & (g.lower > 542)

    p2.subplot(211)
    p2.hist(d.hk_R[arch], histtype='stepfilled', bins = 20, normed = True, color='b', label="archean")
    p2.hist(d.hk_R[proto], histtype='stepfilled' , bins = 20, normed = True, color='r', alpha=0.5, label='Protozoic')
    p2.title("Archean/Protozoic Vp/Vs Histogram")
    p2.xlabel("Value")
    p2.ylabel("Distribution")
    p2.legend()

    p2.subplot(212)
    p2.hist(d.hk_H[arch], histtype='stepfilled', bins = 20, normed=True, color='b', label="archean")
    p2.hist(d.hk_H[proto], histtype='stepfilled' , bins = 20, normed=True, color='r', alpha=0.5, label='Protozoic')
    p2.title("Archean/Protozoic Crustal Thickness Histogram")
    p2.xlabel("Value")
    p2.ylabel("Distribution")
    p2.ylim((0,1))
    p2.legend()


#######################################################################
# F3 Standard Deviation histograms
if p3:
    p3.figure()
    arg1 = Args()
    arg1.addQuery("usable", "eq", "1")
    # Load station params
    d = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["hk::stdH","hk::stdR"])

    p3.subplot(211)
    p3.hist(d.hk_stdR, histtype='stepfilled', bins = 20, normed = True, color='b', label="Vp/Vs deviation")
    p3.title("Vp/Vs ")
    p3.xlabel("Value")
    p3.ylabel("Probability")
    p3.legend()

    p3.subplot(212)
    p3.hist(d.hk_stdH, histtype='stepfilled', normed= True, bins = 20, color='r', label="Thickness deviation")
    p3.title("Vp/Vs ")
    p3.xlabel("Value")
    p3.ylabel("Probability")
    p3.legend()


#######################################################################
# F4

if p4:
    p4.figure()
    arg1 = Args()
    arg1.addQuery("usable", "eq", "1")
    # Load station params
    k = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["hk::H","hk::R"])
    m = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["wm::H","wm::R","wm::Vp"])
    b = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["mb::H","mb::R","mb::Vp"])

    k.sync(m)
    m.sync(b)
    b.sync(k)

    t = np.arange(len(k.hk_H))

    ax1 = p4.subplot(311)
    p4.plot(t , k.hk_H, label = "Kanamori H")
    p4.plot(t , m.wm_H, label = "Mooney H")
    p4.title("mean H Kan = {:2.2f}. mean H Mooney = {:2.2f}".format(np.mean(k.hk_H), np.mean(m.wm_H)) )
    p4.ylabel("Thickness H")
    p4.legend()
    p4.setp( ax1.get_xticklabels(), visible=False)

    p4.subplot(312, sharex = ax1)
    p4.plot(t , k.hk_R, label = "Kanamori Vp/Vs")
    p4.plot(t , m.wm_R, label = "Mooney Vp/Vs")
    p4.title("mean Vp/Vs Kan = {:2.2f}. mean Vp/Vs Mooney = {:2.2f}".format(np.mean(k.hk_R),np.mean(m.wm_R) ))
    p4.ylabel("Vp/Vs")
    p4.legend()
    p4.setp( ax1.get_xticklabels(), visible = False)

    p4.subplot(313, sharex = ax1)
    p4.plot(t , b.mb_Vp , label = "Bostock Vp")
    p4.plot(t , m.wm_Vp , label = "Mooney Vp")
    p4.title("mean Vp MB = {:2.2f}. mean Vp Mooney = {:2.2f}".format(np.mean(b.mb_Vp), np.mean(m.wm_Vp) ))
    p4.xlabel("Station")
    p4.ylabel("Vp")
    p4.legend()


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

