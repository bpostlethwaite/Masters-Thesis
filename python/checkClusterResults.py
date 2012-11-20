#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
###########################################################################
# IMPORTS
###########################################################################
import os, json
import numpy as np
from plotTools import Args, Params


stnfile = os.environ['HOME'] + '/thesis/data/stations.json'
#stdict = json.loads( dbfile.read() )

lim = 0.055

arg = Args()
arg.addQuery("hk::stdR", "lt", "0.055")
# Load station params
d = Params(stnfile, ["hk::H","hk::R", "hk::stdR", "hk::c0R", "hk::c1R"], arg)
d.filter(arg.addQuery("usable", "eq", "1"))

ix1 = np.abs(d.hk_c0R - d.hk_R) < 2*d.hk_stdR
ix2 = np.abs(d.hk_c1R - d.hk_R) < 2*d.hk_stdR
ix3 = np.abs(d.hk_c1R - d.hk_c0R) < lim

ixfail3 = ( np.logical_not(ix1) | np.logical_not(ix2) ) & np.logical_not(ix3)
ixfail2 = ( np.logical_not(ix1) | np.logical_not(ix2) ) & ix3
ixpass3 = (ix1 & ix2) & ix3
ixpass2 = (ix1 & ix2) & np.logical_not(ix3)


msg = [
    "For stations failing (1) or (2) and (3) there is a likely significant lateral heterogeneity or some processing flaw and the station may be marked as unused.",
    "For stations failing (1) or (2) but passing (3) the data may be reasonable but my bootstrap error estimate is much too kind. Readjustment of error required.",
    "For station passing (1) and (2) and (3), Great.",
    "For stations passing (1) and (2) but failing (3) the cluster Vp/Vs difference may be above the arbitrary cut-off of +\- 0.05 but could be included provided the std Vp/Vs error is not above some other arbitrarily chosen cap."
    ]
ixs = [ixfail3, ixfail2, ixpass3, ixpass2]

def printinfo(msg, ixs, d, details):
    print "total stations examined:", len(d.stns)
    for jj in range(0,4):
        print msg[jj]
        ix = ixs[jj]
        for ii, stn in enumerate(d.stns[ix]):
            if details:
                print stn, d.hk_c0R[ix][ii], d.hk_c1R[ix][ii]
            else:
                pass
        print "number of stations:", len(d.stns[ix])


details = False
printinfo(msg, ixs, d, details)
# for stn in d.stns[ixs[0]]:
#     print stn
