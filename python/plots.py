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
# F0 PLOT CMD
#####################
p1 = None # Plot test. Should be perfect linear mapping + survive some asserts.
p2 = None # Proterozoic vs Archean
p3 = None # Comparing some errors in Kanamori approach and new vs old bostock data
p4 = None # Compare values between bostock, kanamori and Mooney
p5 = None # Investigation into effect of much higher freq limit on MB data
p6 = None # Plot Mooney Vp shot data against stations of close proximity
p7 = None # Histograms of kanamori data
######################

#######################################################################
# F1
if p1:
    arg1 = Args()
    arg1.addQuery("hk::H", "lt", "45")
    arg2 = Args()
    arg2.addQuery("hk::H", "lt", "40")
    arg3 = Args()
    arg3.addQuery("hk::H", "lt", "35")
    arg4 = Args()

    fstns = os.environ['HOME'] + '/thesis/stations.json'

    a = Params(fstns, arg1, ["mb::H"])
    b = Params(fstns, arg2, ["mb::H"])
    c = Params(fstns, arg2, ["hk::H"])
    d = Params(fstns, arg3, ["hk::H"])
    e = Params(fstns, arg3, ["wm::H"])
    f = Params(fstns, arg4, ["wm::H"])


    lena = len(a.mb_H)
    a.sync(b)
    assert len(a.reset().mb_H) == lena

    assert np.equal(a.sync(b).mb_H, b.sync(a).mb_H).all()

    c.sync(d.sync(e.sync(f)))

    for ii in range(len(f.stns)):
        assert c.stns[ii] == f.stns[ii]
        assert c.hk_H[ii] == d.hk_H[ii]

    assert f.sync(d) == f.reset().sync(e)

    c.reset()
    d.reset()
    e.reset()
    f.reset()

    d.sync(c)
    e.sync(d)
    f.sync(e)

    for ii in range(len(f.stns)):
        assert c.stns[ii] == f.stns[ii]
        assert c.hk_H[ii] == d.hk_H[ii]


    p1.figure()
    p1.subplot(131, aspect="equal")
    p1.plot(a.mb_H, b.mb_H, 'ob', label = 'test 1')
    p1.title("Test 1")

    p1.subplot(132, aspect="equal")
    p1.plot(c.hk_H, d.hk_H, 'ob', label = 'test 2')
    p1.title("Test 2")

    p1.subplot(133, aspect="equal")
    p1.plot(e.wm_H, f.wm_H, 'ob', label = 'test 3')
    p1.title("Test 3")

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
    arch =  (g.lower <= 3801) & (g.lower > 2500)
    proto = (g.lower <= 2500) & (g.lower > 540)

    p2.subplot(211)
    p2.hist(d.hk_R[arch], histtype='stepfilled', bins = 14, normed = True, color='b', label="archean")
    p2.hist(d.hk_R[proto], histtype='stepfilled' , bins = 14, normed = True, color='r', alpha=0.5, label='Protozoic')
    p2.title("Archean/Protozoic Vp/Vs Histogram")
    p2.xlabel("Value")
    p2.ylabel("Distribution")
    p2.legend()

    p2.subplot(212)
    p2.hist(d.hk_H[arch], histtype='stepfilled', bins = 14, normed=True, color='b', label="archean")
    p2.hist(d.hk_H[proto], histtype='stepfilled' , bins = 14, normed=True, color='r', alpha=0.5, label='Protozoic')
    p2.title("Archean/Protozoic Crustal Thickness Histogram")
    p2.xlabel("Value")
    p2.ylabel("Distribution")
    p2.ylim((0,0.3))
    p2.legend()


#######################################################################
# F3
if p3:

    arg1 = Args()
    arg1.addQuery("usable", "eq", "1")
    arg2 = Args()
    # Load station params
    k = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["hk::stdH","hk::stdR","hk::R","hk::H"])
    b = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["mb::stdH","mb::stdR","mb::stdVp","mb::H","mb::R","mb::Vp"])
    ob = Params(os.environ['HOME'] + '/thesis/stations_old.json', arg2 , ["stdVp","stdR","stdH","Vp","R","H"])

    k.sync(b.sync(ob.sync(k.sync(b.sync(ob)))))

    p3.figure()
    p3.subplot(311)
    p3.hist(k.hk_stdR, histtype='stepfilled', bins = 20,  color='b', label="kan dev")
    p3.hist(b.mb_stdR, histtype='stepfilled', bins = 20,  color='r', label="mb dev")
    p3.hist(ob.stdR, histtype='stepfilled', bins = 20,  color='g', label="mb-old dev")
    p3.title("Vp/Vs std dev for kan, bostock and bostock-old ")
    p3.xlabel("Value")
    p3.ylabel("Probability")
    p3.legend()

    p3.subplot(312)
    p3.hist(k.hk_stdH, histtype='stepfilled',  bins = 20, color='b', label="kan dev")
    p3.hist(b.mb_stdH, histtype='stepfilled', bins = 20, color='r', alpha = 0.5, label="mb dev")
    p3.hist(ob.stdH, histtype='stepfilled', bins = 20, color='g', alpha = 0.5, label="mb-old dev")
    p3.title("H std dev for kan, bostock and bostock-old ")
    p3.xlabel("Value")
    p3.ylabel("Probability")
    p3.legend()

    p3.subplot(313)
    p3.hist(b.mb_stdVp, histtype='stepfilled', bins = 20, color='r', label="mb dev")
    p3.hist(ob.stdVp, histtype='stepfilled', bins = 20, color='g', alpha = 0.5, label="mb-old dev")
    p3.title("Vp std dev for mb vs mb-old ")
    p3.xlabel("Value")
    p3.ylabel("Probability")
    p3.legend()


    t = np.arange(len(k.hk_H))

    p3.figure()
    ax1 = p3.subplot(311)
    p3.plot(t, k.hk_stdR, color='b', label="kan std R")
    p3.plot(t, b.mb_stdR, color='r', label="mb std R")
    p3.plot(t, ob.stdR, color='g', label="mb-old std R")
    p3.title("Vp/Vs std- kan, bostock and bostock-old ")
    p3.ylabel("Error Vp/Vs")
    p3.setp( ax1.get_xticklabels(), visible=False)
    p3.legend()

    ax2 = p3.subplot(312)
    p3.plot(k.hk_stdH, color='b', label="kan std H")
    p3.plot(b.mb_stdH, color='r', label="mb std H")
    p3.plot(ob.stdH, color='g', label="mb-old std H")
    p3.title("H std - kan, bostock and bostock-old ")
    p3.ylabel("Error Thickness [km]")
    p3.setp( ax2.get_xticklabels(), visible=False)
    p3.legend()

    p3.subplot(313)
    p3.plot(b.mb_stdVp, color='r',  label="mb std Vp")
    p3.plot(ob.stdVp, color='g',  label="mb-old std Vp")
    p3.title("std Vp - mb vs mb-old ")
    p3.xlabel("Stations")
    p3.ylabel("Error Vp [km/s]")
    p3.legend()


    p3.figure()
    ax1 = p3.subplot(311)
    p3.plot(t, k.hk_R, color='b', label="kan R")
    p3.plot(t, b.mb_R, color='r', label="mb R")
    p3.plot(t, ob.R, color='g', label="mb-old R")
    p3.title("Vp/Vs - kan, bostock and bostock-old ")
    p3.ylabel("Vp/Vs")
    p3.setp( ax1.get_xticklabels(), visible=False)
    p3.legend()

    ax2 = p3.subplot(312)
    p3.plot(k.hk_H, color='b', label="kan H")
    p3.plot(b.mb_H, color='r', label="mb H")
    p3.plot(ob.H, color='g', label="mb-old H")
    p3.title("H - kan, bostock and bostock-old ")
    p3.ylabel("Thickness [km]")
    p3.setp( ax2.get_xticklabels(), visible=False)
    p3.legend()

    p3.subplot(313)
    p3.plot(b.mb_Vp, color='r',  label="mb dev")
    p3.plot(ob.Vp, color='g',  label="mb-old dev")
    p3.title("Vp - mb vs mb-old ")
    p3.xlabel("Stations")
    p3.ylabel("Vp [km/s]")
    p3.legend()


    p3.figure()
    p3.plot(t, (b.mb_stdR - ob.stdR) * 1 / np.max( np.abs( b.mb_stdR - ob.stdR )), color='b', label="mb std R. Mean = {}".format(np.mean(b.mb_stdR - ob.stdR)) )
    p3.plot(t, (b.mb_stdH - ob.stdH) * 1 / np.max( np.abs( b.mb_stdH - ob.stdH )), color='g', label="mb std H. Mean = {}".format(np.mean(b.mb_stdH - ob.stdH)) )
    p3.plot(t, (b.mb_stdVp - ob.stdVp) * 1 / np.max( np.abs(b.mb_stdVp - ob.stdVp)), color='r',  label="mb std Vp. Mean = {}".format(np.mean(b.mb_stdVp - ob.stdVp)) )
    p3.xticks(t, b.stns)
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

    m.sync(b.sync(k.sync(m.sync(b.sync(k)))))

    t = np.arange(len(k.hk_H))

    ax1 = p4.subplot(311)
    p4.plot(t , k.hk_H, label = "Kanamori H")
    p4.plot(t , m.wm_H, label = "Mooney H")
    p4.title("mean H Kan = {:2.2f}. mean H Mooney = {:2.2f}".format(np.mean(k.hk_H), np.mean(m.wm_H)) )
    p4.ylabel("Thickness H")
    p4.legend()
    p4.setp( ax1.get_xticklabels(), visible=False)

    ax2 = p4.subplot(312, sharex = ax1)
    p4.plot(t , k.hk_R, label = "Kanamori Vp/Vs")
    p4.plot(t , m.wm_R, label = "Mooney Vp/Vs")
    p4.title("mean Vp/Vs Kan = {:2.2f}. mean Vp/Vs Mooney = {:2.2f}".format(np.mean(k.hk_R),np.mean(m.wm_R) ))
    p4.ylabel("Vp/Vs")
    p4.legend()
    p4.setp( ax2.get_xticklabels(), visible = False)

    p4.subplot(313, sharex = ax1)
    p4.plot(t , b.mb_Vp , label = "Bostock Vp")
    p4.plot(t , m.wm_Vp , label = "Mooney Vp")
    p4.title("mean Vp MB = {:2.2f}. mean Vp Mooney = {:2.2f}".format(np.mean(b.mb_Vp), np.mean(m.wm_Vp) ))
    p4.xlabel("Station")
    p4.ylabel("Vp")
    p4.legend()

#######################################################################
# F5

    arg1 = Args()
    arg1.addQuery("usable", "eq", "1")
    # Load station params
    arg1 = Args()
    arg1.addQuery("usable", "eq", "1")
    arg2 = Args()
    # Load station params
    k = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["hk::stdH","hk::stdR","hk::R","hk::H"])
    b = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["mb::stdH","mb::stdR","mb::stdVp","mb::H","mb::R","mb::Vp"])
    ob = Params(os.environ['HOME'] + '/thesis/stations_old.json', arg2 , ["stdVp","stdR","stdH","Vp","R","H"])

    k.sync(b.sync(ob))



#######################################################################
# F6
if p6:

    arg1 = Args()
    arg1.addQuery("usable", "eq", "1")
    arg2 = Args()
    arg2.addQuery("Vp", "gt", "4")
    b = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["wm::H","mb::stdVp","mb::H","mb::R","mb::Vp"])
    k = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["hk::H","hk::R"])
    ob = Params(os.environ['HOME'] + '/thesis/stations_old.json', Args() , ["stdVp","stdR","stdH","Vp","R","H"])
    m = Params(os.environ['HOME'] + '/thesis/moonStations.json', arg2 , ["Vp","H"])



    b.sync(ob.sync(m.sync(k.sync(b.sync(ob.sync(m.sync(k.sync(b))))))))
    mgap = np.abs(b.mb_Vp - m.Vp) > 0.5
    print b.stns[mgap]

    p6. figure()
    t = np.arange(len(b.mb_Vp))
    ax = p6.subplot(311)
    p6.plot(t, b.mb_Vp, label = "MB Vp")
    p6.plot(t, ob.Vp, label = "Old MB Vp")
    p6.plot(t, m.Vp, label = "Mooney Shots")
    for i, stn in enumerate(b.stns[mgap]):
        ax.annotate(stn, xy = (t[mgap][i], b.mb_Vp[mgap][i]),  xycoords='data',
                    xytext=(-30, -30), textcoords='offset points',
                    arrowprops=dict(arrowstyle="->",
                                    connectionstyle="arc3,rad=.2"))

    p6.legend()

    ax2 = p6.subplot(312)
    p6.plot(t, b.mb_stdVp, label = "MB stdVp")
    p6.plot(t, ob.stdVp, label = "Old MB stdVp")
    for i, stn in enumerate(b.stns[mgap]):
        ax2.annotate(stn, xy = (t[mgap][i], b.mb_stdVp[mgap][i]),  xycoords='data',
                    xytext=(-30, -30), textcoords='offset points',
                    arrowprops=dict(arrowstyle="->",
                                    connectionstyle="arc3,rad=.2"))

    p6.legend()


    ax3 = p6.subplot(313)
    p6.plot(t, b.mb_H, label = "MB H")
    p6.plot(t, ob.H, label = "Old MB H")
    p6.plot(t, m.H, label = "Mooney Shots H")
    p6.plot(t, b.wm_H, label = "Mooney C2 H")
    p6.plot(t, k.hk_H, label = "Kan H")
    for i, stn in enumerate(b.stns[mgap]):
        ax3.annotate(stn, xy = (t[mgap][i], b.mb_H[mgap][i]),  xycoords='data',
                    xytext=(-30, -30), textcoords='offset points',
                    arrowprops=dict(arrowstyle="->",
                                    connectionstyle="arc3,rad=.2"))
    p6.legend()



#######################################################################
# F7
# F2 ## Protozoic vs Archean Histograms
if p7:
    p7.figure()
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
    arch =  (g.lower <= 3801) & (g.lower > 2500)
    proto = (g.lower <= 2500) & (g.lower > 540)

    p7.subplot(211)
    p7.hist(d.hk_R[arch], histtype='stepfilled', bins = 14, normed = True, color='b', label="archean")
    p7.hist(d.hk_R[proto], histtype='stepfilled' , bins = 14, normed = True, color='r', alpha=0.5, label='Protozoic')
    p7.title("Archean/Protozoic Vp/Vs Histogram")
    p7.xlabel("Value")
    p7.ylabel("Distribution")
    p7.legend()

    p7.subplot(212)
    p7.hist(d.hk_H[arch], histtype='stepfilled', bins = 14, normed=True, color='b', label="archean")
    p7.hist(d.hk_H[proto], histtype='stepfilled' , bins = 14, normed=True, color='r', alpha=0.5, label='Protozoic')
    p7.title("Archean/Protozoic Crustal Thickness Histogram")
    p7.xlabel("Value")
    p7.ylabel("Distribution")
    p7.ylim((0,0.3))
    p7.legend()

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
