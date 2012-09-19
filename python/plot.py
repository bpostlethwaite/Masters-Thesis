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
from dbfpy import dbf

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



def plot():

    #Load station database
    stndata =  open(os.environ['HOME'] + '/thesis/stations.json')
    stdict = json.loads( stndata.read() )
    # Load geological time data
    #db = dbf.Dbf(os.environ['HOME'] + "/thesis/mapping/BedrockGeology.dbf")
    #era = set()
    #period = set()
    #epoch = set()
    #for rec in db:
    #    era.add(rec["ERA"])
    #    period.add(rec["PERIOD"])
    #    epoch.add(rec["EPOCH"])
    #
    #d = {}
    #for e in epoch:
    #    d[e] = []
    #
    #epochdata = open(os.environ['HOME'] + '/thesis/python/epoch.json')
    #epochdict = json.loads( epochdata.read() )
    #print json.dumps(epochdict, sort_keys = True, indent = 2)

    args = Args()
    args.addQuery("status","eq","processed-ok")
    #args.addKeys()

    stdict = queryStats(stdict, args)

    #getStats(stdict, args, printer = True)

    data = [(key, value['R'], value['Vp'], value['H']) for key, value in stdict.items()]

    # sort by increasing  thickness H
    data = sorted(data, key = lambda x: x[3])

    H = np.array([x[3] for x in data])
    R = np.array([x[1] for x in data])
    Vp = np.array([x[2] for x in data])
    Vs = 1 / R * Vp

    f, axarr = plt.subplots(3, sharex = True)
    # see http://matplotlib.org/examples/pylab_examples/subplots_demo.html
    axarr[0].plot(H, R, '*', label = 'Vp/Vs')
    axarr[0].set_title("Vp/Vs, Vp and Vs against crustal thickness H")
    axarr[0].set_ylabel("Vp/Vs")
    axarr[0].legend(loc=2)
    axarr[1].plot(H, Vp, '*', label = 'Vp')
    axarr[1].set_ylabel("Vp [km/s]")
    axarr[1].legend(loc=2)
    axarr[2].plot(H, Vs, '*', label = 'Vs')
    axarr[2].set_xlabel("Crustal Thickness H [km]")
    axarr[2].set_ylabel("Vs [km/s]")
    axarr[2].legend(loc=2)

    plt.show()
    # plt.xticks(nn[::round(5/dt)],t[::round(5/dt)]) # Changed from 200
    # plt.title('{} \n P-trace, source depth = {}'.format( eventdir, depth) )
    # plt.axvline(x = t0, color = 'y', label = 'gett P')
    # plt.axvline(x = t4, color = 'g', label = 'gett pP')

    # if t7 < right:
    #     plt.axvline(x = t7, color = 'r', label = 'gett PP')

    # plt.xlim(left, right)
    # plt.xlabel('Time \n P arrival is zero seconds')
    # plt.legend()
    # x = plt.ginput(n = 2, timeout = 0, show_clicks = True)

    # try:
    #     T1 = x[0][0]*dt + b
    #     T3 = x[1][0]*dt + b

    # except IndexError:
    #     print "Not all picks made in", eventdir
    #     print "Please retry the picks"
    #     return 'r'

    # plt.close()


if __name__== '__main__' :

    plot()
