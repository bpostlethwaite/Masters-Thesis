#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import sys, os, re, json
from collections import defaultdict
from dbutils import is_number
import matplotlib.pyplot as plt
import numpy as np

stationdir = "/media/TerraS/CN/"

class CrossEvent( object ):
    def __init__(self, station):
        self.stationSet = set()
        self.stationSet.add(station)

    def addStation(self, station):
        self.stationSet.add(station)

    def numStations(self):
        return len(self.stationSet)

def getdt(stns):
    from obspy.core import read
    dt = []
    for ind, stn in enumerate(stns):
        stdir = os.path.join(stationdir, stn)
        events = os.listdir(stdir)
        events = filter(is_number, events)
        st = read( os.path.join(stdir, events[0], "stack_P.sac") )
        dt.append(st[0].stats.delta)

    return dt

if __name__== '__main__' :

    # if not sys.stdin.isatty():
    #     stations =  re.findall(r'\w+', sys.stdin.read() )
    # else:
    #     print "You need to pipe in stations yo"
    #     exit()

    stations = ['EKTN','BOXN','COWN','GBLN','LUPN','MGTN','GLWN','DVKN','MLON','LGSN','ACKN','CAMN','YMBN','MCKN','COKN','RSNT','JERN','NODN','KNDN','HFRN','YNEN','YKW1','YKW3','YKW2','YKW4','SNPN','LDGN','DSMN','ILKN','ARTN','IHLN']

    deltas = getdt(stations)

#     for (stn, dt) in zip(stations, deltas):
#        if dt != 0.025:
#         print stn + ": " + str(dt)



    d = {}
    q = defaultdict(int)

    for station in stations:
        stdir = os.path.join(stationdir, station)
        events = os.listdir(stdir)
        events = filter(is_number, events)
        for event in events:
            if event in d:
                d[event].addStation(station)
            else:
                d[event] = CrossEvent(station)



    # singleEventStations = [list(d[event].stationSet)[0] for event in d.keys() if d[event].numStations() == 1]

    # for ses in singleEventStations:
    #     q[ses] += 1

    data = np.array([ float( d[event].numStations() ) for event in d.keys() ]) #/ float(len(stations))

    evs = [ ev for ev in d.keys() if d[ev].numStations() == 12]

    ev = sorted(evs)[-1]

    print "The following event is found in listed stations"
    sys.stdout.write(ev + ": ")
    sys.stdout.write("{")
    for stn in list(d[ev].stationSet):
        sys.stdout.write( "'" + stn + "'" + ",")
    sys.stdout.write("\b")
    sys.stdout.write("}\n")
    # plt.plot( sorted(data, reverse = True) )
    # plt.show()


## Save event: [station list] as JSON
    j = {}
    j = {"_"+key: list( d[key].stationSet ) for key in d.keys() if d[key].numStations() > 1}


#    fd = os.environ['HOME'] + '/thesis/data/eventSources.json'
#    open(fd, 'w').write( json.dumps(j, sort_keys = True, indent = 2 ))





    evs = os.listdir("/media/TerraS/SLAVE")

    # Re-sort data to get dictionary with station keys and listed multiple events
    s = {}
    for ev in evs:
        for stn in d[ev].stationSet:
            if stn not in s:
                s[stn] = []
            s[stn].append(ev)

    fd = os.environ["HOME"] + '/thesis/data/stationStackedEvents.json'
    open(fd, 'w').write( json.dumps(s, sort_keys = True, indent = 2) )
#    print json.dumps(s, sort_keys = True, indent = 2)
