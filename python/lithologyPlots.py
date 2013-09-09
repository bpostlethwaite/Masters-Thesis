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
            size = 'large',
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
        },
    "Diorite": {
        "Vp": 6.611,
        "Vs": 3.733,
        "R": 1.771,
        "poisson": 0.266
        },
    "Granodiorite": {
        "Vp": 6.327,
        "Vs": 3.706,
        "R": 1.707,
        "poisson": 0.239
        }

    }


if __name__  == "__main__":


    ## Figure Properties #######
    figwidth = 12
    figheight = figwidth / 1.4
    ratio = 1
    lw = 4 / ratio# line width
    ms = 12 / ratio# marker size
    caplen = 7 / ratio
    capwid = 2 / ratio
    elw = 2 / ratio
    ticks = 16 / ratio
    label = 16 / ratio
    title = 18 / ratio
    leg = 14 / ratio





    #############################################################################
    # FIG 1: Vp estimates against H
    ##############################################################################

    if 1:
        #f = Params(stnfile, ["fg::H","fg::Vp", "fg::stdVp", "hk::stdR"])
        fig = plt.figure( figsize = (figwidth, figheight) )
        ax = plt.subplot(111)

        vs = np.linspace(2.5, 5., 100)
        sigmas = [0.3, 0.25, 0.2]
        px = [3.7, 3.9, 4.1]

        rd = {}


        with open(regionf, 'r') as f:
            j = json.load(f)
            for k in j.keys():
                rd[k] = {}
                rd[k]['H'] = j[k]['kanamori']['H']
                rd[k]['Vp'] = j[k]['crust1']['Vp']
                rd[k]['R'] = j[k]['kanamori']['R']
                rd[k]['Vs'] = rd[k]['Vp'] / rd[k]['R']
                rd[k]['poisson'] = poisson(rd[k]['R'])

                #print '['+'"'+k+'"'+','+'np.array(['+str(rd[k]['Vp'])+','+str(rd[k]['poisson'])+'])],'


        for i in range(len(sigmas)):
            vp = lithVp(vs, sigmas[i])
            text = r'$\sigma$ = {}'.format(sigmas[i])
            plt.plot(vs, vp, ':k', lw = lw, ms = ms, label = "constant Poisson's Ratio" if i == 0 else None)
            addtext(ax, px[i], lithVp(px[i], sigmas[i]), text, 45 - 10)


        for k in rd:
            plt.plot(rd[k]['Vs'], rd[k]['Vp'], '^', label = k, markersize = 12)

        for l in liths:
            plt.plot(liths[l]['Vs'], liths[l]['Vp'], 'ok', markersize = 10)
            plt.text(liths[l]['Vs'], liths[l]['Vp'] + 0.05, l,
                     color = 'black',
                     horizontalalignment = 'center',
                     verticalalignment = 'center'
                    )



        plt.legend(loc= 2, prop={'size': leg}, numpoints=1)
        #plt.title(r'$\alpha=')#.format(sigmas[1]))
        plt.ylabel("Vp [km/s]", size = label)
        plt.xlabel("Vs [km/s]", size = label)
        plt.grid(True)
        #plt.grid(False)
        plt.xlim( (3.4, 4.2) )
        plt.ylim( (6, 7.5) )

    plt.show()
    #plt.savefig('myfig')
