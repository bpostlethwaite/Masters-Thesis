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
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
from scipy.signal import detrend
from scipy.stats import pearsonr, norm
#from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.mlab as mlab

plotnum = [False for i in range(15)]

#####################
# PLOT CMD
#####################
plotnum[0] = False # Plot test. Should be perfect linear mapping + survive some asserts.
plotnum[1] = False # Proterozoic vs Archean
plotnum[2] = False # Comparing some errors in Kanamori approach and new vs old bostock data
plotnum[3] = False # Compare values between bostock, kanamori and Mooney
plotnum[4] = False # Investigation into effect of new auto processing
plotnum[5] = False # Plot Mooney Vp shot data against stations of close proximity
plotnum[6] = False # Canada Wide Histogram
plotnum[7] = True # Canadian Shield Histograms (Provinces)
plotnum[8] = False # Platforms
plotnum[9] = False # Orogens
######################



def poisson(R):
    ''' Function to go from Vp/Vs -> Poisson's ratio '''
    return  ( (R**2 - 2) / (2*(R**2 - 1)))


#######################################################################
# F0
if plotnum[0]:
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


    plt.figure()
    plt.subplot(131, aspect="equal")
    plt.plot(a.mb_H, b.mb_H, 'ob', label = 'test 1')
    plt.title("Test 1")

    plt.subplot(132, aspect="equal")
    plt.plot(c.hk_H, d.hk_H, 'ob', label = 'test 2')
    plt.title("Test 2")

    plt.subplot(133, aspect="equal")
    plt.plot(e.wm_H, f.wm_H, 'ob', label = 'test 3')
    plt.title("Test 3")

#######################################################################
# F1 ## Protozoic vs Archean Histograms
if plotnum[1]:
    plt.figure()
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

    plt.subplot(211)
    plt.hist(d.hk_R[arch], histtype='stepfilled', bins = 14, normed = True, color='b', label="archean")
    plt.hist(d.hk_R[proto], histtype='stepfilled' , bins = 14, normed = True, color='r', alpha=0.5, label='Protozoic')
    plt.title("Archean/Protozoic Vp/Vs Histogram")
    plt.xlabel("Value")
    plt.ylabel("Distribution")
    plt.legend()

    plt.subplot(212)
    plt.hist(d.hk_H[arch], histtype='stepfilled', bins = 14, normed=True, color='b', label="archean")
    plt.hist(d.hk_H[proto], histtype='stepfilled' , bins = 14, normed=True, color='r', alpha=0.5, label='Protozoic')
    plt.title("Archean/Protozoic Crustal Thickness Histogram")
    plt.xlabel("Value")
    plt.ylabel("Distribution")
    plt.ylim((0,0.3))
    plt.legend()


#######################################################################
# F2
if plotnum[2]:

    arg1 = Args()
    arg1.addQuery("usable", "eq", "1")
    arg2 = Args()
    # Load station params
    k = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["hk::stdH","hk::stdR","hk::R","hk::H"])
    b = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["mb::stdH","mb::stdR","mb::stdVp","mb::H","mb::R","mb::Vp"])
    ob = Params(os.environ['HOME'] + '/thesis/stations_old.json', arg2 , ["stdVp","stdR","stdH","Vp","R","H"])

    k.sync(b.sync(ob.sync(k.sync(b.sync(ob)))))

    plt.figure()
    plt.subplot(311)
    plt.hist(k.hk_stdR, histtype='stepfilled', bins = 20,  color='b', label="kan dev")
    plt.hist(b.mb_stdR, histtype='stepfilled', bins = 20,  color='r', label="mb dev")
    plt.hist(ob.stdR, histtype='stepfilled', bins = 20,  color='g', label="mb-old dev")
    plt.title("Vp/Vs std dev for kan, bostock and bostock-old ")
    plt.xlabel("Value")
    plt.ylabel("Probability")
    plt.legend()

    plt.subplot(312)
    plt.hist(k.hk_stdH, histtype='stepfilled',  bins = 20, color='b', label="kan dev")
    plt.hist(b.mb_stdH, histtype='stepfilled', bins = 20, color='r', alpha = 0.5, label="mb dev")
    plt.hist(ob.stdH, histtype='stepfilled', bins = 20, color='g', alpha = 0.5, label="mb-old dev")
    plt.title("H std dev for kan, bostock and bostock-old ")
    plt.xlabel("Value")
    plt.ylabel("Probability")
    plt.legend()

    plt.subplot(313)
    plt.hist(b.mb_stdVp, histtype='stepfilled', bins = 20, color='r', label="mb dev")
    plt.hist(ob.stdVp, histtype='stepfilled', bins = 20, color='g', alpha = 0.5, label="mb-old dev")
    plt.title("Vp std dev for mb vs mb-old ")
    plt.xlabel("Value")
    plt.ylabel("Probability")
    plt.legend()


    t = np.arange(len(k.hk_H))

    plt.figure()
    ax1 = plt.subplot(311)
    plt.plot(t, k.hk_stdR, color='b', label="kan std R")
    plt.plot(t, b.mb_stdR, color='r', label="mb std R")
    plt.plot(t, ob.stdR, color='g', label="mb-old std R")
    plt.title("Vp/Vs std- kan, bostock and bostock-old ")
    plt.ylabel("Error Vp/Vs")
    plt.setp( ax1.get_xticklabels(), visible=False)
    plt.legend()

    ax2 = plt.subplot(312)
    plt.plot(k.hk_stdH, color='b', label="kan std H")
    plt.plot(b.mb_stdH, color='r', label="mb std H")
    plt.plot(ob.stdH, color='g', label="mb-old std H")
    plt.title("H std - kan, bostock and bostock-old ")
    plt.ylabel("Error Thickness [km]")
    plt.setp( ax2.get_xticklabels(), visible=False)
    plt.legend()

    plt.subplot(313)
    plt.plot(b.mb_stdVp, color='r',  label="mb std Vp")
    plt.plot(ob.stdVp, color='g',  label="mb-old std Vp")
    plt.title("std Vp - mb vs mb-old ")
    plt.xlabel("Stations")
    plt.ylabel("Error Vp [km/s]")
    plt.legend()


    plt.figure()
    ax1 = plt.subplot(311)
    plt.plot(t, k.hk_R, color='b', label="kan R")
    plt.plot(t, b.mb_R, color='r', label="mb R")
    plt.plot(t, ob.R, color='g', label="mb-old R")
    plt.title("Vp/Vs - kan, bostock and bostock-old ")
    plt.ylabel("Vp/Vs")
    plt.setp( ax1.get_xticklabels(), visible=False)
    plt.legend()

    ax2 = plt.subplot(312)
    plt.plot(k.hk_H, color='b', label="kan H")
    plt.plot(b.mb_H, color='r', label="mb H")
    plt.plot(ob.H, color='g', label="mb-old H")
    plt.title("H - kan, bostock and bostock-old ")
    plt.ylabel("Thickness [km]")
    plt.setp( ax2.get_xticklabels(), visible=False)
    plt.legend()

    plt.subplot(313)
    plt.plot(b.mb_Vp, color='r',  label="mb dev")
    plt.plot(ob.Vp, color='g',  label="mb-old dev")
    plt.title("Vp - mb vs mb-old ")
    plt.xlabel("Stations")
    plt.ylabel("Vp [km/s]")
    plt.legend()


    plt.figure()
    plt.plot(t, (b.mb_stdR - ob.stdR) * 1 / np.max( np.abs( b.mb_stdR - ob.stdR )), color='b', label="mb std R. Mean = {}".format(np.mean(b.mb_stdR - ob.stdR)) )
    plt.plot(t, (b.mb_stdH - ob.stdH) * 1 / np.max( np.abs( b.mb_stdH - ob.stdH )), color='g', label="mb std H. Mean = {}".format(np.mean(b.mb_stdH - ob.stdH)) )
    plt.plot(t, (b.mb_stdVp - ob.stdVp) * 1 / np.max( np.abs(b.mb_stdVp - ob.stdVp)), color='r',  label="mb std Vp. Mean = {}".format(np.mean(b.mb_stdVp - ob.stdVp)) )
    plt.xticks(t, b.stns)
    plt.legend()



#######################################################################
# F3

if plotnum[3]:
    plt.figure()
    arg1 = Args()
    arg1.addQuery("usable", "eq", "1")
    # Load station params
    k = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["hk::H","hk::R"])
    m = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["wm::H","wm::R","wm::Vp"])
    b = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["mb::H","mb::R","mb::Vp"])

    m.sync(b.sync(k.sync(m.sync(b.sync(k)))))

    t = np.arange(len(k.hk_H))

    ax1 = plt.subplot(311)
    plt.plot(t , k.hk_H, label = "Kanamori H")
    plt.plot(t , m.wm_H, label = "Mooney H")
    plt.title("mean H Kan = {:2.2f}. mean H Mooney = {:2.2f}".format(np.mean(k.hk_H), np.mean(m.wm_H)) )
    plt.ylabel("Thickness H")
    plt.legend()
    plt.setp( ax1.get_xticklabels(), visible=False)

    ax2 = plt.subplot(312, sharex = ax1)
    plt.plot(t , k.hk_R, label = "Kanamori Vp/Vs")
    plt.plot(t , m.wm_R, label = "Mooney Vp/Vs")
    plt.title("mean Vp/Vs Kan = {:2.2f}. mean Vp/Vs Mooney = {:2.2f}".format(np.mean(k.hk_R),np.mean(m.wm_R) ))
    plt.ylabel("Vp/Vs")
    plt.legend()
    plt.setp( ax2.get_xticklabels(), visible = False)

    plt.subplot(313, sharex = ax1)
    plt.plot(t , b.mb_Vp , label = "Bostock Vp")
    plt.plot(t , m.wm_Vp , label = "Mooney Vp")
    plt.title("mean Vp MB = {:2.2f}. mean Vp Mooney = {:2.2f}".format(np.mean(b.mb_Vp), np.mean(m.wm_Vp) ))
    plt.xlabel("Station")
    plt.ylabel("Vp")
    plt.legend()

#######################################################################
# F4
if plotnum[4]:

    arg1 = Args()
    arg1.addQuery("usable", "eq", "1")
    # Load station params
    arg2 = Args()

    arg3 = Args()
    arg3.addQuery("hk::stdH", "lt", "100")

    # Load station params
    k = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["hk::stdH","hk::stdR","hk::R","hk::H"])
    ok = Params(os.environ['HOME'] + '/thesis/stations.old.json', arg2 ,["hk::stdH","hk::stdR","hk::R","hk::H"])
    kall = Params(os.environ['HOME'] + '/thesis/stations.json', arg3, ["hk::stdH","hk::stdR","hk::R","hk::H"])

    k.sync(ok.sync(k))
    t = np.arange(len(k.hk_H))

    plt.subplot(211)
    plt.plot(t , k.hk_H, label = "Kanamori H")
    plt.plot(t , ok.hk_H, label = "KanmoriOLD H")
    plt.title("mean H Kan = {:2.2f}. mean H OLDKAN = {:2.2f}".format(np.mean(k.hk_H), np.mean(ok.hk_H)) )
    plt.ylabel("Thickness H")
    plt.legend()

    plt.subplot(212)
    plt.plot(t , k.hk_R, label = "Kanamori Vp/Vs")
    plt.plot(t , ok.hk_R, label = "KanamorOLD Vp/Vs")
    plt.title("mean Vp/Vs Kan = {:2.2f}. mean Vp/Vs OLDKAN = {:2.2f}".format(np.mean(k.hk_R),np.mean(ok.hk_R) ))
    plt.ylabel("Vp/Vs")
    plt.legend()


    plt.figure()
    plt.subplot(2,1,1)
    plt.hist(kall.hk_R, bins = 40, color='r', label="mb dev")
    plt.title("Vp std dev for mb vs mb-old ")
    plt.xlabel("Value")
    plt.ylabel("Probability")
    plt.legend()

    plt.subplot(2,1,2)
    plt.hist(kall.hk_stdR,  bins = 40, color='g', label="mb-old dev")
    plt.title("Vp std dev for mb vs mb-old ")
    plt.xlabel("Value")
    plt.ylabel("Probability")
    plt.legend()



#######################################################################
# F5
if plotnum[5]:

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

    plt. figure()
    t = np.arange(len(b.mb_Vp))
    ax = plt.subplot(311)
    plt.plot(t, b.mb_Vp, label = "MB Vp")
    plt.plot(t, ob.Vp, label = "Old MB Vp")
    plt.plot(t, m.Vp, label = "Mooney Shots")
    for i, stn in enumerate(b.stns[mgap]):
        ax.annotate(stn, xy = (t[mgap][i], b.mb_Vp[mgap][i]),  xycoords='data',
                    xytext=(-30, -30), textcoords='offset points',
                    arrowprops=dict(arrowstyle="->",
                                    connectionstyle="arc3,rad=.2"))

    plt.legend()

    ax2 = plt.subplot(312)
    plt.plot(t, b.mb_stdVp, label = "MB stdVp")
    plt.plot(t, ob.stdVp, label = "Old MB stdVp")
    for i, stn in enumerate(b.stns[mgap]):
        ax2.annotate(stn, xy = (t[mgap][i], b.mb_stdVp[mgap][i]),  xycoords='data',
                    xytext=(-30, -30), textcoords='offset points',
                    arrowprops=dict(arrowstyle="->",
                                    connectionstyle="arc3,rad=.2"))

    plt.legend()


    ax3 = plt.subplot(313)
    plt.plot(t, b.mb_H, label = "MB H")
    plt.plot(t, ob.H, label = "Old MB H")
    plt.plot(t, m.H, label = "Mooney Shots H")
    plt.plot(t, b.wm_H, label = "Mooney C2 H")
    plt.plot(t, k.hk_H, label = "Kan H")
    for i, stn in enumerate(b.stns[mgap]):
        ax3.annotate(stn, xy = (t[mgap][i], b.mb_H[mgap][i]),  xycoords='data',
                    xytext=(-30, -30), textcoords='offset points',
                    arrowprops=dict(arrowstyle="->",
                                    connectionstyle="arc3,rad=.2"))
    plt.legend()



#######################################################################
# F6
if plotnum[6]:
    plt.figure()
    arg1 = Args()
    arg1.addQuery("hk::stdR", "lt", "0.041")
    # Load station params
    d = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["hk::H","hk::R"])

    d.hk_P = poisson(d.hk_R)
    d.avgvn = poisson(1.746516)
    d.avgpNik = 0.265


    ax1 = plt.subplot(111)
    # best fit of data
    (mu, sigma) = norm.fit(d.hk_P)
    # the histogram of the data
    n, bins, patches = plt.hist(d.hk_P, 30, normed = True,  facecolor='green', alpha=0.75, label='Poisson ratio')

    # add a 'best fit' line
    y = mlab.normpdf( bins, mu, sigma)
    plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
    plt.axvline(x = d.avgvn, linewidth = 4, color = 'r', label = "Voronoi Weighted Poisson Average")
    plt.axvline(x = d.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust N. Christensen ('96)")
    plt.title("Canada Wide Poisson Ratio Histogram", size = 22)
    plt.xlabel("Poisson Ratio", size = 16)
    plt.ylabel("Probability", size = 16)
    plt.legend(prop={'size':16})
    plt.grid(True)

    for tick in ax1.xaxis.get_major_ticks():
                tick.label.set_fontsize(14)

    for v in [d.avgvn, d.avgpNik]:
        txt = r'$\sigma=$'+"{:0.3f}".format(v)
        diffbin = bins[2] - bins[1]
        ax1.annotate(txt, xy = (v , 0.8 * max(n)),  xycoords='data', size = 16,
                     xytext=(30, 0), textcoords='offset points',
                     arrowprops=dict(arrowstyle="->",lw = 3,
                                     connectionstyle="arc3,rad=.2"))


    plt.figure()
    ax2 = plt.subplot(111)
    arg2 = Args()
    arg2.addQuery("Vp", "gt", "5.6")
    m = Params(os.environ['HOME'] + '/thesis/moonvpGeology.json', arg2, ["H","Vp"])
    #Voronoi average Vp/Vs = 6.289357
    #Voronoi average H = 34.700373
    m.avgvn = 6.289
    m.avgpNik = 6.454

    # best fit of data
    (mu, sigma) = norm.fit(m.Vp)
    # the histogram of the data
    n, bins, patches = plt.hist(m.Vp, 120, normed = True,  facecolor='green', alpha=0.75, label='Mooney Vp')

    # add a 'best fit' line
    y = mlab.normpdf( bins, mu, sigma)
    plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
    plt.axvline(x = m.avgvn, linewidth = 4, color = 'r', label = "Voronoi Weighted Mooney Vp")
    plt.axvline(x = m.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust N. Christensen ('96)")
    plt.title("Canada Wide Mooney Vp Data", size = 22)
    plt.xlabel("Mooney Vp", size = 16)
    plt.ylabel("Probability", size = 16)
    plt.legend(prop={'size':16})
    plt.grid(True)

    for tick in ax2.xaxis.get_major_ticks():
                tick.label.set_fontsize(14)

    for v in [m.avgvn, m.avgpNik]:
        txt = r'$\sigma=$'+"{:0.3f}".format(v)
        diffbin = bins[2] - bins[1]
        ax2.annotate(txt, xy = (v , 0.8 * max(n)),  xycoords='data', size = 16,
                     xytext=(30, 0), textcoords='offset points',
                     arrowprops=dict(arrowstyle="->",lw = 3,
                                     connectionstyle="arc3,rad=.2"))



#######################################################################
# F7
if plotnum[7]:

    fig = plt.figure()

    provinces = ["Churchill Province",
                 "Superior Province",
                 "Slave Province",
                 "Grenville Province"]

    color = ['b', 'g', 'm', 'y', 'k', 'c']
    bins = np.arange(0.22, 0.3, 0.002)
    handles = ()
    labels = ()

    plt.subplots_adjust(left= None, bottom=None, right = 0.8, top=None,
                        wspace=None, hspace=None)

    for (ii, province) in enumerate(provinces):

        arg1 = Args()
        arg1.addQuery("hk::stdR", "lt", "0.041")
        # Load station params
        d = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["hk::H","hk::R"])

        arg1 = Args()
        arg1.addQuery("geoprov", "in", province)
        d2 = Params(os.environ['HOME'] + '/thesis/stations.json', arg1, ["hk::H","hk::R"])

        d.sync(d2)


        d.hk_P = poisson(d.hk_R)
        d.avgvn = poisson(np.mean(d.hk_R))
        d.avgpNik = 0.265

        (mu, sigma) = norm.fit(d.hk_P)

        ax = ( plt.subplot(4,1,ii + 1) )

        n, bins, patches = plt.hist(d.hk_P, bins = bins, histtype = "bar", normed = True,
                 color = color[ii], rwidth = 1, alpha = 0.6,
                 label = province)
        handle, label = ax.get_legend_handles_labels()
        handles += (handle[0],)
        labels += (label[0],)


        y = mlab.normpdf( bins, mu, sigma)
        distc = plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        abgvn = plt.axvline(x = d.avgvn, linewidth = 4, color = 'r', label = "Voronoi Weighted Poisson Average")
        avgpNik = plt.axvline(x = d.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust N. Christensen ('96)")
        plt.setp( ax.get_xticklabels(), visible=False)


        for inc,v in enumerate([d.avgvn, d.avgpNik]):
            txt = r'$\sigma=$'+"{:0.3f}".format(v)
            diffbin = bins[2] - bins[1]
            ax.annotate(txt, xy = (v , (0.9 - 0.3*inc) * max(n)),  xycoords='data', size = 16,
                        xytext=(-100, 20) if inc else (-220, 0),
                        textcoords='offset points',
                        arrowprops=dict(arrowstyle="->", lw = 3,
                                        connectionstyle="arc,rad=.2"))


        plt.grid(True)

#    ax = plt.subplot(4,1,4)
    handles += (distc, abgvn, avgpNik)
    labels += ('Distribution curve', 'Area Weighted\nPoisson Average', "Avg Cont. Crust N.\nChristensen ('96)")
    fig.legend(handles, labels, 'right', prop={'size':16})
    plt.setp( ax.get_xticklabels(), visible= True)
    plt.suptitle('Poisson Ratio Histogram\n Major Canadian Shield Provinces', size = 22)

    for tick in ax.xaxis.get_major_ticks():
        tick.label.set_fontsize(14)


    fig = plt.figure()
    bins = np.arange(6.0, 7.2, 0.01)
    handles = ()
    labels = ()

    for (ii, province) in enumerate(provinces):


        arg2 = Args()
        arg2.addQuery("geoprov", "in", province)
        print province
        m = Params(os.environ['HOME'] + '/thesis/moonvpGeology.json', arg2, ["H","Vp"])
        arg3 = Args()
        arg3.addQuery("Vp", "gt", "5.6")
        m2 = Params(os.environ['HOME'] + '/thesis/moonvpGeology.json', arg3, ["H","Vp"])

        m.sync(m2)

        m.avgvn = np.mean(m.Vp)
        m.avgpNik = 6.454

        (mu, sigma) = norm.fit(m.Vp)

        ax = ( plt.subplot(4,1,ii + 1) )

        n, bins, patches = plt.hist(m.Vp, bins = bins, histtype = "bar", normed = True,
                 color = color[ii], rwidth = 1, alpha = 0.6,
                 label = province)
        handle, label = ax.get_legend_handles_labels()
        handles += (handle[0],)
        labels += (label[0],)

        y = mlab.normpdf( bins, mu, sigma)
        distc = plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        abgvn = plt.axvline(x = m.avgvn, linewidth = 4, color = 'r', label = "Voronoi Weighted Poisson Average")
        avgpNik = plt.axvline(x = m.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust N. Christensen ('96)")
        plt.setp( ax.get_xticklabels(), visible=False)


        for inc,v in enumerate([m.avgvn, m.avgpNik]):
            txt = r'$\sigma=$'+"{:0.3f}".format(v)
            diffbin = bins[2] - bins[1]
            ax.annotate(txt, xy = (v , (0.9 - 0.3*inc) * max(n)),  xycoords='data', size = 16,
                         xytext=(-80, 10), textcoords='offset points',
                         arrowprops=dict(arrowstyle="->", lw = 3,
                                         connectionstyle="arc3,rad=.2"))


        plt.grid(True)


#    ax = plt.subplot(4,1,4)
    handles += (distc, abgvn, avgpNik)
    labels += ('Distribution curve', 'Area Weighted\nPoisson Average', "Avg Cont. Crust N.\nChristensen ('96)")
    fig.legend(handles, labels, 'right', prop={'size':16})
    plt.setp( ax.get_xticklabels(), visible= True)
    plt.suptitle('Mooney Vp Histogram\n Major Canadian Shield Provinces', size = 22)

    for tick in ax.xaxis.get_major_ticks():
        tick.label.set_fontsize(14)


#######################################################################
# F8
if plotnum[8]:
    pass

#######################################################################
# F9
if plotnum[9]:
    pass

#######################################################################
# F10
if plotnum[10]:
    pass

#######################################################################
# F11
if plotnum[11]:
    pass



for p in plotnum:
    if p:
        plt.show()

