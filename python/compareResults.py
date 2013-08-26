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
from scipy.stats import ttest_ind as ttest


data = ['/thesis/data/thompsonPaper.json',
        '/thesis/data/thompsonProcessed.json',
        '/thesis/data/eatonPaper.json',
        '/thesis/data/eatonProcessed.json',
        '/thesis/data/darbyshirePaper.json',
        '/thesis/data/darbyshireProcessed.json']

leglabel = ["Thompson et. al.",
            "Eaton et. al.",
            "Darbyshire et. al."]

Vp = [6.5, 6.39, 6.39]

stnfile = os.environ['HOME'] + '/thesis/data/stations.json'
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


def rmsDifference(x, y):
    assert (len(x) == len(y))
    n = len(x)
    md = 0
    for i in range(n):
        md += (x[i] - y[i])**2

    return np.sqrt(md/(n))


for i in range(0,3):

    pro = os.environ['HOME'] + data[2*i + 1]
    pub = os.environ['HOME'] + data[2*i]

    arg = Args().addQuery("stdR", "lt", 0.06)

    p0 = Params(pro, ["H", "R", "stdR", "stdH"], arg)
    p2 = Params(pub, ["H", "R", "stdR", "stdH"], arg)

    p1 = Params(stnfile, ["hk::H","hk::R", "hk::stdR", "hk::stdH"])

    p0.sync(p2)

    stns = p0.stns

    R1 = p0.R
    R2 = p2.R

    H1 = p0.H
    H2 = p2.H

    R1std = p0.stdR
    R2std = p2.stdR

    H1std = p0.stdH
    H2std = p2.stdH


    Rcorr = pearsonr(R1, R2)

    Hcorr = pearsonr(H1, H2)

#    print "Correlation between", leglabel[i], "H datasets is {0:.2f}".format(Hcorr[0]), "using", len(p2.stns), "stations"
#    print "Correlation between", leglabel[i], "Vp/Vs datasets is {0:.2f}".format(Rcorr[0]), "using", len(p2.stns), "stations"

    print "RMS Difference between", leglabel[i], "H datasets is {0:.2f}".format(rmsDifference(H1,H2)), "using", len(p2.stns), "stations"
    print "RMS Difference between", leglabel[i], "Vp/Vs datasets is {0:.3f}".format(rmsDifference(R1,R2)), "using", len(p2.stns), "stations"

    t = np.arange(len(R1))

    plt.figure(figsize = (width, height))
    ax = plt.subplot(111)
    plt.plot(t, R1, '-ob', lw = lw, ms = ms, label = "Vp/Vs estimate -  current data set")
    plt.plot(t, R2, '-og', lw = lw, ms = ms, label = "Vp/Vs estimate " + leglabel[i])
    plt.errorbar(t, R1, yerr = R1std, xerr=None, fmt=None, ecolor = 'blue',
                 elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std error")
    plt.errorbar(t, R2, yerr = R2std, xerr=None, fmt=None, ecolor = 'green',
                 elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std error")
    plt.legend(prop={'size': leg})
    plt.xticks(t, stns, size = ticks)
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

    plt.plot(t, H1, '-ob', lw = lw, ms = ms, label = "H estimate -  current data set")
    plt.plot(t, H2, '-og', lw = lw, ms = ms, label = "H estimate " + leglabel[i])
    plt.errorbar(t, H1, yerr = H1std, xerr=None, fmt=None, ecolor = 'blue',
                 elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std error")
    plt.errorbar(t, H2, yerr = H2std, xerr=None, fmt=None, ecolor = 'green',
                 elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std error")
    plt.legend(prop={'size': leg})
    plt.xticks(t, stns, size = ticks)
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



