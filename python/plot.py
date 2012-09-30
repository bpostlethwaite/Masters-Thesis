#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import os, json
from dbutils import queryStats, getStats
import matplotlib.pyplot as plt
import numpy as np
from scipy.signal import detrend
from matplotlib.backends.backend_pdf import PdfPages


class Args(object):

    def __init__(self):
        self.stationList = False
        self.attribute = False
        self.query = False
        self.Keys = False

    def addQuery(self, attr, op, value):
        self.query = [attr, op, value]

    def addKeys(self):
        self.keys = True


## Setup pdf printer
pp = PdfPages('comparisonFigs.pdf')
### Load data
stndata =  open(os.environ['HOME'] + '/thesis/stations.json')
stdict = json.loads( stndata.read() )

stnc = open(os.environ['HOME'] + '/thesis/stnchrons.json')
stnchron = json.loads( stnc.read() )
#print json.dumps(epochdict, sort_keys = True, indent = 2)

kan = open(os.environ['HOME'] + '/thesis/kanStats.json')
kand = json.loads( kan.read() )


### Create Arg to programatically interact with dbutils functionality

for i in range(5, 0, -1):
    stdVp = str(0.1*i)
    args = Args()
    args.addQuery("stdVp","lte",stdVp)
    #args.addKeys()
    stdict = queryStats(stdict, args)
    #getStats(stdict, args, printer = True)

    ### Create data
    params = []
    for key, value in stdict.items():
        params.append( (key, value['R'], value['Vp'], value['H'], kand[key]['R'], kand[key]['H']) )

        # sort by increasing  thickness H
        #params = sorted(params, key = lambda x: x[3])


    ### Create Geo data. The reason to do this seperately is there might be
    ### less stns in the geochron dictionary then in the parameter dictionary.
    #geochron = [(key, value['R'], value['Vp'], value['H'], stnchron[key]) for key, value in stdict.items() if key in stnchron and stnchron[key]]

    plottype = ["param","geochron", "kanamori", "compare"][2]


    #### Kanamori data
    if "kanamori" in plottype:
        Rk = np.array([x[4] for x in params])
        Hk = np.array([x[5] for x in params])
        H = np.array([x[3] for x in params])
        R = np.array([x[1] for x in params])
        Vp = np.array([x[2] for x in params])
        Vs = 1.0 / R * Vp

        ### Regression Line Bostock
        A = np.vstack([H, np.ones(len(H))]).T
        m, c = np.linalg.lstsq(A, R)[0]
        regrB = m*H + c

        ### Regression Line Kanamori
        A = np.vstack([Hk, np.ones(len(Hk))]).T
        mk, ck = np.linalg.lstsq(A, Rk)[0]
        regrK = mk * Hk + ck

        ### RMS before Bostock detrending
        Rdiff = Rk - R
        RMS = np.sqrt(1.0 / len(Rdiff) * np.dot(Rdiff.T, Rdiff))

        # Detrend Vp/Vs Bostock data
        Rdtr = R - (regrB -  np.mean(regrB))

        plt.figure(num = 1 - i, figsize = (10,12) )
        # see http://matplotlib.org/examples/pylab_examples/subplots_demo.html
        ax1 = plt.subplot(211)
        plt.plot(Hk, Rk, 'ob', label = 'Vp/Vs Kanamori')
        plt.plot(Hk, regrK, 'b', label = "Kanamori fit")
        plt.plot(H, R, 'or', label = 'Bostock Vp/Vs')
        plt.plot(H, regrB, 'r', label = "Bostock fit" )
        plt.title("For Stations with Vp err < {}\nVp/Vs for Bostock and Kanamori as a function of crustal thickness H".format(stdVp))
        plt.ylabel("Vp/Vs")
        plt.ylim((1.6, 2.0))
        plt.xlim((25, 50))
        plt.setp( ax1.get_xticklabels(), visible=False)
        plt.legend(loc=2)

        ### New regression line for Bostock data (should have slope = 0)
        A = np.vstack([H, np.ones(len(H))]).T
        m, c = np.linalg.lstsq(A, Rdtr)[0]
        regrDtr = m*H + c

        ### RMS after Bostock detrending
        Rdiff = Rk - Rdtr
        RMSdtr = np.sqrt(1.0 / len(Rdiff) * np.dot(Rdiff.T, Rdiff))

        # see http://matplotlib.org/examples/pylab_examples/subplots_demo.html
        plt.subplot(212)
        plt.plot(Hk, Rk, 'ob', label = 'Vp/Vs Kanamori')
        plt.plot(Hk, regrK, 'b', label = "Kanamori fit" )
        plt.plot(H, Rdtr, 'or', label = 'Bostock Vp/Vs')
        plt.plot(H, regrDtr, 'r', label = "Bostock fit" )
        plt.title("Vp/Vs with Linear Trend removed in Bostock data as a function of crustal thickness H")
        plt.ylabel("Vp/Vs")
        plt.ylim((1.6, 2.0))
        plt.xlim((25, 50))
        plt.xlabel('Crustal Thickness [km]')
        plt.legend(loc=2)

        pp.savefig()


        ns = np.arange(len(Hk))

        plt.figure(num = 16 - i, figsize = (10, 12))
        ax1 = plt.subplot(211)
        plt.plot(ns, Rk, 'ob', label = 'R Kanamori')
        plt.plot(ns, R, 'or', label = 'R Bostock')
        plt.title("For Stations with Vp err < {}\nVp/Vs over stations. RMS = {}".format(stdVp,RMS))
        plt.ylabel("Vp/Vs")
        plt.ylim((1.6, 2.0))
        plt.setp( ax1.get_xticklabels(), visible=False)
        plt.legend(loc=2)

        ax1 = plt.subplot(212)
        plt.plot(ns, Rk, 'ob', label = 'R Kanamori')
        plt.plot(ns, Rdtr, 'or', label = 'R Bostock')
        plt.title("Vp/Vs over stations with LINEAR regression detrend. RMS = {}".format(RMSdtr))
        plt.ylabel("Vp/Vs")
        plt.ylim((1.6, 2.0))
        plt.xlabel("Station number")
        plt.legend(loc=2)

        pp.savefig()

        # plt.figure(4)
        # plt.subplot(211)
        # ns = np.arange(len(Hk))
        # # see http://matplotlib.org/examples/pylab_examples/subplots_demo.html
        # plt.plot(ns, Hk, label = 'H Kanamori')
        # plt.plot(ns, H, label = 'H', color = "red")
        # plt.title("H over stations")
        # plt.ylabel("H")
        # plt.legend(loc=2)

        # ax1 = plt.subplot(212)
        # plt.plot(ns, Rk, label = 'R Kanamori')
        # plt.plot(ns, R, label = 'R', color = "red")
        # plt.title("R over stations")
        # plt.ylabel("Vp/Vs")
        # plt.legend(loc=2)


        # plt.figure(5)

        # # see http://matplotlib.org/examples/pylab_examples/subplots_demo.html
        # ax1 = plt.subplot(311)
        # plt.plot(Hk, R, '*', label = 'Vp/Vs')
        # plt.title("Vp/Vs, Vp and Vs against KANAMORI crustal thickness H")
        # plt.ylabel("Vp/Vs")
        # plt.legend(loc=2)
        # plt.setp( ax1.get_xticklabels(), visible=False)

        # ax2 = plt.subplot(312, sharex = ax1)
        # plt.plot(Hk, Vp, '*', label = 'Vp')
        # plt.ylabel("Vp [km/s]")
        # plt.legend(loc=2)
        # plt.setp( ax1.get_xticklabels(), visible=False)

        # ax3 = plt.subplot(313, sharex = ax1)
        # plt.plot(Hk, Vs, '*', label = 'Vs')
        # plt.xlabel("KANAMORI Crustal Thickness H [km]")
        # plt.ylabel("Vs [km/s]")
        # plt.legend(loc=2)

pp.close()
#plt.show()

if "param" in plottype:

    ### Create vectors from raw data
    H = np.array([x[3] for x in prmdata])
    R = np.array([x[1] for x in prmdata])
    Vp = np.array([x[2] for x in prmdata])
    Vs = 1 / R * Vp

    plt.figure(1)

    # see http://matplotlib.org/examples/pylab_examples/subplots_demo.html
    ax1 = plt.subplot(311)
    plt.plot(H, R, '*', label = 'Vp/Vs')
    plt.title("Vp/Vs, Vp and Vs against crustal thickness H")
    plt.ylabel("Vp/Vs")
    plt.legend(loc=2)
    plt.setp( ax1.get_xticklabels(), visible=False)

    ax2 = plt.subplot(312, sharex = ax1)
    plt.plot(H, Vp, '*', label = 'Vp')
    plt.ylabel("Vp [km/s]")
    plt.legend(loc=2)
    plt.setp( ax1.get_xticklabels(), visible=False)

    ax3 = plt.subplot(313, sharex = ax1)
    plt.plot(H, Vs, '*', label = 'Vs')
    plt.xlabel("Crustal Thickness H [km]")
    plt.ylabel("Vs [km/s]")
    plt.legend(loc=2)

##### Geochronology Plots
if "geochron" in plottype:
    ### Create vectors from raw data
    H = np.array([x[3] for x in geodata])
    R = np.array([x[1] for x in geodata])
    Vp = np.array([x[2] for x in geodata])
    rng = np.array([x[4] for x in geodata])
    Vs = 1 / R * Vp

    plt.figure(2)
    ax1 = plt.subplot(111)
    plt.hlines(y = H, xmin = rng[:,1], xmax = rng[:,0])
    plt.title("Crustal Thickness H against Bedrock Age in Mya")
    plt.ylabel("Crustal Thickenss [km]")
    #plt.setp( ax1.get_xticklabels(), visible = False)
    ax1.set_xlim(ax1.get_xlim()[::-1])


    #ax2 = plt.subplot(212, sharex = ax1)
    #plt.hlines(y = Vs, xmin = rng[:,1], xmax = rng[:,0])
    plt.xlabel("Million Years Ago")
    #plt.ylabel("Shear Wave Velocity Vs [km/s]")
