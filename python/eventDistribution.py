#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import sys, os, re
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


if __name__== '__main__' :

    if not sys.stdin.isatty():
        stations =  re.findall(r'\w+', sys.stdin.read() )
    else:
        print "You need to pipe in stations yo"
        exit()

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
