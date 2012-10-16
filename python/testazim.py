#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save
#
# This program takes piped in station list input (space or newline seperated)
# and an event.list arguement.
#
###########################################################################
# IMPORTS
###########################################################################
#import matplotlib
#matplotlib.__version__ = "1.1.0"
from obspy.core import read
import subprocess, sys, os, re, shutil
import numpy as np
import os.path
from math import degrees, radians, cos, sin, asin, sqrt, pi
sh = subprocess.Popen
pipe = subprocess.PIPE
earthradius = 6371
deg2rkm = 180/(pi * earthradius)

sdir = "/media/TerraS/CN/WBHL"


def haversine(lon1, lat1, lon2, lat2):
    """
    Calculate the great circle distance between two points
    on the earth (specified in decimal degrees)
    """
    # convert decimal degrees to radians
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    # haversine formula
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    km = 6367 * c
    return c, km







for ev in os.listdir(sdir):
    event = os.path.join(sdir, ev)
    for comp in os.listdir(event):
        if "stack_P.sac" in comp:
            st = read(os.path.join(event, comp))
            stla = st[0].stats.sac['stla']
            stlo = st[0].stats.sac['stlo']
            evla = st[0].stats.sac['evla']
            evlo = st[0].stats.sac['evlo']
            gcarc = st[0].stats.sac['gcarc']
            dt = st[0].stats.delta
            oldP = st[0].stats.sac['t0']
            pP = st[0].stats.sac['t1']
            evdp = st[0].stats.sac['evdp']
            beginOLD = st[0].stats.sac['b']

            process = sh(os.environ["HOME"] + "/bin/Get_tt/get_tt -z {} -d {} -p P".format(evdp, gcarc),
                         shell=True, executable = "/bin/bash", stdout = pipe )
            results =  process.communicate()[0].rstrip().split('\n')
            for result in results:
                result = result.split()
                if result[1] == 'P':
                    slowness = float(result[3])
                    P = float(result[2])
                    break
                else:
                    raise SeisDataError('noPslow')

            print "gcarc:", gcarc
            rg, km = haversine(evlo, evla, stlo, stla)
            print  "gcarc II: ", degrees(rg)

            process = sh(os.environ["HOME"] + "/bin/Get_tt/get_tt -z {} -d {} -p P".format(evdp, gcarc),
                         shell=True, executable = "/bin/bash", stdout = pipe )
            results =  process.communicate()[0].rstrip().split('\n')
            for result in results:
                result = result.split()
                if result[1] == 'P':
                    slowness = float(result[3])
                    P = float(result[2])
                    break
                else:
                    raise SeisDataError('noPslow')
