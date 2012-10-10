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
import json, os, argparse, sys, time, re
from preprocessor import is_number
from collections import defaultdict
import scipy.io as sio
from obspy.core import read

davedir = '/media/TerraS/BEN/'
dbfile = os.environ['HOME'] + '/thesis/stations.json'
events = os.listdir(davedir)
reg = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w{2})\.(\w*)\.\.(\w{3}).*')

date = 1
net = 2
stn = 3
comp = 4
d = {}

ss = set(['SHWN', 'NOTN', 'ELEF', 'CTSN', 'HOWN', 'VTIN', 'MNGN', 'PNGN', 'SHMN', 'KIMN', 'DORN', 'EA06', 'CRLN', 'MANN', 'ARTN'])

for event in events:
    m = reg.match(event)
    if m.group(stn) in ss:
        s = read(os.path.join(davedir, event))
        d[ m.group(stn) ] = {
            "network" : s[0].stats.network,
            "lat" : s[0].stats.sac['stla'],
            "lon" : s[0].stats.sac['stlo'],
            "start" : 0.,
            "stop" : 0.,
            "status": "not aquired"
            }

        ss.remove(m.group(stn))

stdict = json.loads( open(dbfile).read() )
stdict.update(d)
open(dbfile,'w').write( json.dumps(stdict, sort_keys = True, indent = 4 ))
print stdict['SHWN']
