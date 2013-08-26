#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
###########################################################################
# IMPORTS
###########################################################################
import os, json
import numpy as np
import matplotlib
#matplotlib.use('agg')
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection
import matplotlib.pyplot as plt
from plotTools import Args, Params
from histplots import poisson


stnfile = os.environ['HOME'] + '/thesis/data/stations.json'
regionf = os.environ['HOME'] + '/thesis/data/voronoi.json'

def lithVp(vs, poisson):
    return vs * np.sqrt( (2 - 2*poisson) / (1 - 2 * poisson)  )


left, width = .25, .5
bottom, height = .25, .5
right = left + width
top = bottom + height

def addtext(ax, x, y, text, rotation):
    ax.text(x-0.02, y, text,
            color = 'black',
            horizontalalignment = 'left',
            verticalalignment = 'bottom',
            rotation = rotation,
            zorder = 10)


liths = {
    "granite gneiss": {
        "Vp": 6.208,
        "Vs": 3.583,
        "R": 1.732,
        "poisson": 0.250
        },
    "tonalite gneiss": {
        "Vp": 6.302,
        "Vs": 3.606,
        "R": 1.747,
        "poisson": 0.257
        },
    "mafic granulite": {
        "Vp": 6.942,
        "Vs": 3.820,
        "R": 1.817,
        "poisson": 0.283
        },
    "mafic garnet granulite": {
        "Vp": 7.249,
        "Vs": 4.026,
        "R": 1.801,
        "poisson": 0.277
        },
    "amphibolite": {
        "Vp": 6.983,
        "Vs": 3.959,
        "R": 1.764,
        "poisson": 0.263
        },
    "hornblendite": {
        "Vp": 7.261,
        "Vs": 4.144,
        "R": 1.752,
        "poisson": 0.258
        }
    }


if __name__  == "__main__":


    ## Figure Properties #######
    figwidth = 12
    figheight = figwidth / 1.4
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

    if 1:
        #f = Params(stnfile, ["fg::H","fg::Vp", "fg::stdVp", "hk::stdR"])
        fig = plt.figure( figsize = (figwidth, figheight) )
        ax = plt.subplot(111)

        vs = np.linspace(2.5, 5., 100)
        sigmas = [0.35, 0.3, 0.25, 0.2, 0.15]
        px = [3.5, 3.75, 4.0, 4.25, 4.4, 4.6]

        rd = {}


        with open(regionf, 'r') as f:
            j = json.load(f)
            for k in j.keys():
                rd[k] = {}
                rd[k]['H'] = j[k]['kanamori']['H']
                rd[k]['Vp'] = j[k]['mooney']['Vp']
                rd[k]['R'] = j[k]['kanamori']['R']
                rd[k]['Vs'] = rd[k]['Vp'] / rd[k]['R']
                rd[k]['poisson'] = poisson(rd[k]['R'])
                #print '['+'"'+k+'"'+','+'np.array(['+str(rd[k]['Vp'])+','+str(rd[k]['poisson'])+'])],'


        for i in range(len(sigmas)):
            vp = lithVp(vs, sigmas[i])
            text = 'poisson={}'.format(sigmas[i])
            plt.plot(vs, vp, 'k', lw = lw, ms = ms)
            addtext(ax, px[i], lithVp(px[i], sigmas[i]), text, 45 - 2*i)


        for k in rd:
            plt.plot(rd[k]['Vs'], rd[k]['Vp'], '*', label = k, markersize = 12)

        for l in liths:
            plt.plot(liths[l]['Vs'], liths[l]['Vp'], 'o', label = l, markersize = 12)

        plt.legend(loc= 2, prop={'size': leg})
        #plt.title(r'$\alpha=')#.format(sigmas[1]))
        plt.ylabel("Vp [km/s]", size = label)
        plt.xlabel("Vs [km/s]", size = label)
        plt.grid(True)
        plt.grid(False)
        plt.xlim( (3, 4.5) )
        plt.ylim( (5.5, 8.0) )

    plt.show()
    #plt.savefig('myfig')
