#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
###########################################################################
# IMPORTS
###########################################################################
import os, json
import numpy as np
import matplotlib.pyplot as plt
from plotTools import Args, Params


stnfile = os.environ['HOME'] + '/thesis/data/stations.json'

def extract(d, key):
    a = []
    for k in d.keys():
        if key in d[k]:
            a.extend(d[k][key])
    return np.array(a)

if __name__  == "__main__":


    ## Figure Properties #######
    figwidth = 12
    figheight = figwidth / 1.618
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

    #############################################################################
    # FIG 1: Vp estimates against H
    ##############################################################################

    data = json.loads( open(stnfile).read() )
    c = { stn:data[stn]["conrad"] for stn in data.keys() if "conrad" in data[stn] }
    h = extract(c, "hdisc")
    hmin = 10
    hmax = 35
    nbins = 30
    h = h[(h >= hmin) & (h <= hmax)]

    bins = np.linspace(hmin, hmax, nbins)
    n, bins, patches = plt.hist(h, bins = bins, facecolor='green', alpha=0.75, label = "asdfads")
    plt.axis('tight')

    plt.show()
    # fig = plt.figure( figsize = (figwidth, figheight) )
    # plt.plot(M[0], M[1], 'ob', lw = lw, ms = ms, label = "normalized Vp vs H")
    # plt.plot(x1, y1,'--r', lw = lw, label="Primary PCA")
    # plt.plot(x2, y2,'--g', lw = lw, label="Secondary PCA")

    # plt.legend(loc= 2, prop={'size': leg})
    # plt.ylabel("normalized Vp", size = label)
    # plt.xlabel("normalized H", size = label)
    # plt.grid(True)
    # plt.axis("equal")
