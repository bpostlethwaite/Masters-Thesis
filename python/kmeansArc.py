#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save

###########################################################################
# IMPORTS
###########################################################################
import os, re, time, shutil, sys
from loopApplyDRIVER import renameEvent, is_number
from collections import defaultdict
import numpy as np
import math
import matplotlib.pyplot as plt
from obspy.core import read
from scipy.cluster.vq import kmeans2 as kmeans
import scipy.io

if __name__== '__main__' :

    reg2 = re.compile(r'^stack_(\w)\.sac')
    stdir = "/media/TerraS/CN/ULM"
    datafile = os.path.join(stdir, "bazvect.mat")
    k = 2
    
    force = None
    if len(sys.argv) > 1:
        force = sys.argv[1]

    if os.path.exists( datafile ) and not force:
        ddict = scipy.io.loadmat( datafile ) 
        data = ddict['d']

    else:
        events = os.listdir(stdir)
        events = filter(is_number,events)

        data = np.zeros( (len(events), 2) )

        for ind, event in enumerate(events):
            files = os.listdir( os.path.join(stdir, event) )
            for fs in files:
                if reg2.match(fs):
                    st = read( os.path.join(stdir, event, fs) )
                    baz = float(st[0].stats.sac['baz']) * math.pi / 180
                    evla = float(st[0].stats.sac['evla'])
                    evlo = float(st[0].stats.sac['evlo'])
                    #data[ind] = [ math.sin(baz), math.cos(baz) ]
                    data[ind] = [ evlo, evla ]
                    continue

        scipy.io.savemat( datafile , {"d": data} )
    
    
    cs, label =  kmeans(data, k)

    # bazc = []
    # for c in cs:
    #     if c[0] < 0:
    #         bazc.append( 360 - 180 / math.pi * math.acos( ( c[1] ) / math.sqrt(c[0]**2 + c[1]**2) ) )
    #     else:
    #         bazc.append( 180 / math.pi * math.acos( ( c[1] ) / math.sqrt(c[0]**2 + c[1]**2) ) )

    print cs
    #print bazc
    print label
    
    plt.scatter(data[:,0],data[:,1])
    plt.show()
                
