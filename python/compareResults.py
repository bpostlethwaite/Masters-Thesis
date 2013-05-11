#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

# Program to build station objects from state stored
# in JSON format.
# Functions to build station database from files
# and functions to add stats, add matlab data etc.

###########################################################################
# IMPORTS
###########################################################################
import os, math
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import pearsonr
from plotTools import Args, Params

data = ['/thesis/data/thompsonPaper.json',
        '/thesis/data/thompsonProcessed.json',
        '/thesis/data/eatonPaper.json',
        '/thesis/data/eatonProcessed.json',
        '/thesis/data/darbyshirePaper.json',
        '/thesis/data/darbyshireProcessed.json']

leglabel = ["Thompson et. al.",
            "Eaton et. al.",
            "Darbyshire et. al."]

#######################
# Plotting formatter
#######################
width = 10
height = width / 1.9
ratio = 1.5
lw = 4 / ratio# line width
ms = 12 / ratio# marker size
caplen = 7 / ratio
capwid = 2 / ratio
elw = 2 / ratio
ticks = 16 / ratio
label = 16 / ratio
title = 18 / ratio
leg = 16 / ratio


for i in range(3):

    pro = os.environ['HOME'] + data[2*i + 1]
    pub = os.environ['HOME'] + data[2*i]

    arg = Args().addQuery("stdR", "lt", 0.06)

    p0 = Params(pro,["H", "R", "stdR", "stdH"])
    p1 = Params(pro,["H", "R", "stdR", "stdH"], arg)
    p2 = Params(pub,["H", "R", "stdR", "stdH"])

    # processedFULL = set(p0.stns)
    # processed = set(p1.stns)
    # published = set(p2.stns)

    # print "station symmetric difference for", leglabel[i]
    # sd =  published - processed
    # for s in sd:
    #     print "processed:", s, "stdR:", p0.stdR[list(p0.stns).index(s)]

    p1.sync(p2)

    Rcorr = pearsonr(p1.R, p2.R)
    print "Correlation between", leglabel[i], "Vp/Vs datasets is {0:.2f}".format(Rcorr[0]), "using", len(p1.stns), "stations"
    Hcorr = pearsonr(p1.H, p2.H)
    print "Correlation between", leglabel[i], "H datasets is {0:.2f}".format(Hcorr[0]), "using", len(p1.stns), "stations"


    t = np.arange(len(p1.R))

    plt.figure(figsize = (width, height))
    ax = plt.subplot(111)
    plt.plot(t, p1.R, '-ob', lw = lw, ms = ms, label = "Vp/Vs estimate -  current data set")
    plt.plot(t, p2.R, '-og', lw = lw, ms = ms, label = "Vp/Vs estimate " + leglabel[i])
    plt.errorbar(t, p1.R, yerr = p1.stdR, xerr=None, fmt=None, ecolor = 'blue',
                 elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std error")
    plt.errorbar(t, p2.R, yerr = p2.stdR, xerr=None, fmt=None, ecolor = 'green',
                 elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std error")
    plt.legend(prop={'size': leg})
    plt.xticks(t, p1.stns, size = ticks)
    for tick in ax.xaxis.get_major_ticks():
                    tick.label.set_fontsize( ticks )
                    # specify integer or one of preset strings, e.g.
                    #tick.label.set_fontsize('x-small')
                    tick.label.set_rotation('vertical')
    plt.yticks(size = ticks)
    plt.ylabel('Vp/Vs', size = label)
    plt.grid(True)
    plt.axis("tight")



    plt.figure(figsize = (width, height))
    ax = plt.subplot(111)

    plt.plot(t, p1.H, '-ob', lw = lw, ms = ms, label = "H estimate -  current data set")
    plt.plot(t, p2.H, '-og', lw = lw, ms = ms, label = "H estimate " + leglabel[i])
    plt.errorbar(t, p1.H, yerr = p1.stdH, xerr=None, fmt=None, ecolor = 'blue',
                 elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std error")
    plt.errorbar(t, p2.H, yerr = p2.stdH, xerr=None, fmt=None, ecolor = 'green',
                 elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std error")
    plt.legend(prop={'size': leg})
    plt.xticks(t, p1.stns, size = ticks)
    for tick in ax.xaxis.get_major_ticks():
                    tick.label.set_fontsize( ticks )
                    # specify integer or one of preset strings, e.g.
                    #tick.label.set_fontsize('x-small')
                    tick.label.set_rotation('vertical')
    plt.yticks(size = ticks)
    plt.ylabel('H [km]', size = label)
    plt.grid(True)
    plt.axis("tight")


#plt.show()
