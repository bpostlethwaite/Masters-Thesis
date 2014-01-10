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


def project(ax, ay, bx, by, cx, cy):
    m = (by - ay) / (bx - ax)
    y = m * (vs - ax) + ay
    y2 = -m * (vs - cx) + cy

    ix = 0.5 * ( (cy - ay)/m + ax + cx)
    iy = m * (ix - ax) + ay

    lengthA = np.sqrt((bx - ax)**2 + (by - ay)**2 )
    lengthD = np.sqrt((bx - cx)**2 + (by - cy)**2 )

    distp = 1 - lengthD / lengthA

    return (ix, iy, distp)


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
        "poisson": 0.250,
        "x": -0.08,
        "y": 0.0
        },
    "tonalite gneiss": {
        "Vp": 6.302,
        "Vs": 3.606,
        "R": 1.747,
        "poisson": 0.257,
        "x": 0.11,
        "y": 0.
        },
    "mafic granulite": {
        "Vp": 6.942,
        "Vs": 3.820,
        "R": 1.817,
        "poisson": 0.283,
        "x": -0.08,
        "y": 0.05
        },
    "mafic garnet granulite": {
        "Vp": 7.249,
        "Vs": 4.026,
        "R": 1.801,
        "poisson": 0.277,
        "x": -0.15,
        "y": 0.0
        },
    "amphibolite": {
        "Vp": 6.983,
        "Vs": 3.959,
        "R": 1.764,
        "poisson": 0.263,
        "x": 0.,
        "y": 0.05
        },
    "hornblendite": {
        "Vp": 7.261,
        "Vs": 4.144,
        "R": 1.752,
        "poisson": 0.258,
        "x": 0.,
        "y": 0.05
        },
    "diorite": {
        "Vp": 6.611,
        "Vs": 3.733,
        "R": 1.771,
        "poisson": 0.266,
        "x": 0.,
        "y": 0.05
        }

    }


def RMSDifference(x, y):
    assert (len(x) == len(y))
    n = len(x)
    md = 0
    for i in range(n):
        md += (x[i] - y[i])**2

    return np.sqrt(md/(n))


def minimizeRatio(lith1, lith2, CS, CM, RG, Sm, PR):
    # compounds = ["SiO2", "TiO2", "Al2O3", "Fe2O3", "FeO", "MnO",
    #              "MgO", "CaO", "Na2O", "K2O", "H2O", "P2O5", "CO2"]


    index = [0, 2, 4, 6, 7, 8, 9]
    feratio = 0.8998
    cs = CS[index]
    cs[2] += feratio * CS[3]
    cm = CM[index]
    cm[2] += feratio * CM[3]
    rg = RG[index]
    sm = Sm[index]
    sm[2] += feratio * Sm[3]
    pr = PR[index]
    pr[2] += feratio * PR[3]



    dists = np.linspace(0.5, 1, 100)
    for q in range(len(dists)):
        rms = 0
        dist = dists[q]
    #plt.plot(pvs, pvp, 'xr', markersize = 16)
        PB = dist * lith2 + (1 - dist) * lith1  # Canada
        pb = PB[index]
        pb[2] += feratio * PB[3]

        A = np.vstack((cs, pr, cm, rg, sm, pb))



        for i in range(5):
            rms += RMSDifference(A[5,:], A[i,:])

        print dist, rms / 5


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






    fig = plt.figure( figsize = (figwidth, figheight) )
    ax = plt.subplot(111)

    vs = np.linspace(2.5, 5., 100)
    vpvs = [1.81, 1.73, 1.65]
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

    legc = {"Canada": ["o","b"],
            "Slave Province": ["^","b"],
            "Grenville Province": ["^","g"],
            "Churchill Province": ["^","r"],
            "Superior Province": ["^","c"],
            "Canadian Shield":["o","g"],
            "Platforms": ["o","r"],
            "Orogens": ["o","c"],
            "Proterozoic": ["D","b"],
            "Archean": ["D","g"]}

    order = ["Canada", "Slave Province", "Grenville Province",
             "Churchill Province", "Superior Province", "Canadian Shield",
             "Platforms" , "Orogens" ]#,"Proterozoic", "Archean" ]


    for i in range(len(vpvs)):
        vp = vpvs[i] * vs
        text = 'Vp/Vs = {}'.format(vpvs[i])
        plt.plot(vs, vp, ':k', lw = lw, ms = ms, label = "constant Vp/Vs" if i == 0 else None)
        addtext(ax, px[i], vpvs[i] * px[i], text, 45 - 10)


    for k in order:
        plt.plot(rd[k]['Vs'], rd[k]['Vp'], legc[k][0], color=legc[k][1]
                 , label = k, markersize = 16, markeredgecolor = 'black', mew = 1.6)

    for l in liths:
        plt.plot(liths[l]['Vs'], liths[l]['Vp'], 'ok', markersize = 10)
        plt.text(liths[l]['Vs'] + liths[l]["x"],
                 liths[l]['Vp'] + liths[l]["y"],
                 l,
                 color = 'black',
                 horizontalalignment = "center",
                 verticalalignment = "center",
                 fontsize = 14
                 )


    plt.legend(loc= 2, prop={'size': leg}, numpoints=1)
    #plt.title(r'$\alpha=')#.format(sigmas[1]))
    plt.ylabel("Vp [km/s]", size = label)
    plt.xlabel("Vs [km/s]", size = label)
    plt.grid(True)
    #plt.grid(False)
    plt.xlim( (3.4, 4.2) )
    plt.ylim( (6, 7.5) )


    #plt.savefig('myfig')

########################################################################
#                       COMPOSITION                                    #
########################################################################

        # Project regions onto lithological line
    (pvs, pvp, dist) = project(liths["granite gneiss"]['Vs']
                               , liths["granite gneiss"]['Vp']
                               , liths["diorite"]['Vs']
                               , liths["diorite"]['Vp']
                               , rd["Canada"]["Vs"]
                               , rd["Canada"]["Vp"])


    (pvs, pvp, dist2) = project(liths["granite gneiss"]['Vs']
                               , liths["granite gneiss"]['Vp']
                               , liths["diorite"]['Vs']
                               , liths["diorite"]['Vp']
                               , rd["Canadian Shield"]["Vs"]
                               , rd["Canadian Shield"]["Vp"])


    #plt.plot(pvs, pvp, 'xr', markersize = 16)

    print "Canada is", round(dist*100), "% diorite"
    print "Canadian Shield is", round(dist2*100), "% diorite"


    compounds = ["$SiO_2$", "$TiO_2$", "$Al_2O_3$", "$Fe_2O_3$", "$FeO$", "$MnO$",
                 "$MgO$", "$CaO$", "$Na_2O$", "$K_2O$", "$H_2O$", "$P_2O_5$", "$CO_2$"]

    granite = np.array([71.3, 0.31, 14.32, 1.21, 1.64, 0.05,
               0.71, 1.84, 3.68, 4.07, 0.77, 0.12, 0.05])
    diorite = np.array([57.48, 0.95, 16.67, 2.5, 4.92, 0.12,
               3.71, 6.58, 3.54, 1.76, 1.36, 0.29, 0.1])

    PB = dist * diorite + (1 - dist) * granite  # Canada

    CS = dist2 * diorite + (1 - dist2) * granite  # Canadian Shield

    # RF = np.array([52.6, 0.8, 16.6, np.nan, 6.6, 0.11,
    #                4.4, 6.4, 3.2, 1.88, np.nan, 0.2, np.nan])
    CM = np.array([61.7, 0.9, 14.7, 1.9, 5.1, 0.1, 3.1,
                   5.7, 3.6, 2.1, 0.8, 0.2, np.nan])
    RG = np.array([60.6, 0.7, 15.9, np.nan, 6.7, 0.1,
                   4.7, 6.4, 3.1, 1.8, np.nan, 0.1, np.nan])
    Sm = np.array([63.0, 0.7, 15.8, 2.0, 3.4, 0.1, 2.8, 4.6,
                   4.0, 2.7, np.nan, np.nan, np.nan])
    PR = np.array([57.9, 1.2, 15.2, 2.3, 5.5, 0.2, 5.3, 7.1,
                   3.0, 2.1, np.nan, 0.3, np.nan])

    minimizeRatio(granite, diorite, CS, CM, RG, Sm, PR)

    for i in range(len(PB)):
        print "{} & {:2.1f} & {:2.1f} & {:2.1f} & {:2.1f} & {:2.1f} & {:2.1f} \\\\".format(compounds[i],
                                                                               PR[i], Sm[i],
                                                                               CM[i], RG[i],
                                                                               PB[i], CS[i])


    ########################################################
    # Rudnick and Gao figure                               #
    ########################################################

    labels = [r'$SiO_2$', r'$Al_2O_3$', r'$FeO$', r'$MgO$', r'$CaO$', r"$Na_2O$", r"$K_2O$"]
    index = [0, 2, 4, 6, 7, 8, 9]
    feratio = 0.8998
    # rf = RF[index]
    cs = CS[index]
    cs[2] += feratio * CS[3]
    cm = CM[index]
    cm[2] += feratio * CM[3]
    rg = RG[index]
    sm = Sm[index]
    sm[2] += feratio * Sm[3]
    pr = PR[index]
    pr[2] += feratio * PR[3]
    pb = PB[index]
    pb[2] += feratio * PB[3]

    x = np.arange(1,8)

    plt.figure()

    # plt.plot(x, rf/pb, "-o", ms = 12, c = "gray", mfc = "black", label = "Rudnick and Fountain")
    plt.plot(x, pr/pb, "-o", ms = 12, c = "gray", mfc = "black", label = "Pakiser and Robinson")
    plt.plot(x, sm/pb, "-^", ms = 12, c = "gray", mfc = "white", label = "Smithson")
    plt.plot(x, cm/pb, "-o", ms = 12, c = "gray", mfc = "white", label = "Christensen and Mooney")
    plt.plot(x, rg/pb, "-D", ms = 12, c = "gray", mfc = "gray", label = "Rudnick and Gao")
    plt.plot(x, cs/pb, "-s", ms = 12, c = "gray", mfc = "gray", label = "This study, Can. Shield")

    plt.xticks(x, labels, size = 14)
    plt.tick_params(
        axis='x',          # changes apply to the x-axis
        which='both',      # both major and minor ticks are affected
        top='off')         # ticks along the top edge are off

    plt.plot(np.arange(0,9), np.ones(9), "k", lw = 2)
    plt.axhspan(0.7, 1.3, xmin=0, xmax=8, zorder=-1, color="lightgray")
    plt.xlim( (0, 8) )
    plt.ylim( (0.4, 2.5) )

    plt.legend(loc = 2, prop={'size': 12}, frameon= False, numpoints=1)


    plt.show()
