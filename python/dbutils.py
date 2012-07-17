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
import json, os
from preprocessor import is_number
from collections import defaultdict
import shapefile

def json2shapefile(dbf, shpf):
    ''' Converts the station data into a shapefile for usage with
    GIS programs such as QGIS'''
    stdict = json.loads( open(dbf).read() )
    w = shapefile.Writer( shapeType = 1 )
    # Set fields for attribute table
    w.field('network', 'C', '10')
    w.field('status', 'C', '16')
    for key in stdict.keys():
        # Set lon & lat
        w.point( stdict[key]["lon"], stdict[key]["lat"] )
        w.record( stdict[key]["network"],
                  stdict[key]["status"] )

    w.save(shpf)

def missingComps(s):
    if "MissingComponents" in s:
        return True
    else:
        return False

def isPoor(s):
    if "poorData" in s:
        return True
    else:
        return False

def stationStats(stationDir):
    ''' Runs through station directory and collects
    stats outputting to STDOUT as JSON '''
    statdict = {}
    events = os.listdir(stationDir)
    statdict['numEvents'] = len(events)
    statdict['poorEvents'] = len( filter(isPoor,events) )
    statdict['usableEvents'] = len( filter(is_number,events) )
    statdict['badCompEvents'] = len( filter(missingComps,events) )
    status = "aquired"
    if statdict['poorEvents'] > 5:
        status = "picked"
    if statdict['badCompEvents'] > 50:
        status = "data corruption"
    statdict['status'] = status
    return statdict


def updateStats(stdict, netdir, dbf):
    ''' Walks through all the keys in the main json database
    and checks if there are stats for that station. If there is
    it updates the keys and values, otherwise it sets "status"
    to "not aquired" '''
    db = json.loads( open(dbf).read() )
    for station in stdict.keys():
        stndir = os.path.join(netdir, station)
        try:
            d = stationStats(stndir)
            for key in d.keys():
                stdict[station][key] = d[key]
        except OSError, KeyError:
            stdict[station]['status'] = "not aquired"
            continue

    jstr = json.dumps(stdict, sort_keys = True, indent = 4)
    dbfd = open(dbfile, 'w')
    dbfd.write(jstr)


def buildStationDBfromList(stnf, dbf):
    ''' Builds station database from a list of stations taken
    from the website:
    http://www.earthquakescanada.nrcan.gc.ca/stndon/data_avail-eng.php'''

    d = {}
    q = defaultdict(int)
    with open(stnf) as stations:
        for s in stations:
            field = s.rstrip().split()
            d[ field[0] ] = {'network': field[-1],
                             'lat' : float(field[2]),
                             'lon' : float(field[3]),
                             'start': float(field[5]),
                             'stop': 0 if not is_number( field[6] ) else field[6]
                             }
            q[ field[0] ] += 1

    # Remove Stations that don't offer 3 components
    for key in q:
        if q[key] < 3:
            del d[key]

    f = open(dbf,'w')
    jstr = json.dumps(d, sort_keys = True, indent = 4)

    f.write(jstr)


if __name__== '__main__' :

    netdir = '/media/TerraS/CN'
    dbfile = os.environ['HOME']+'/thesis/stations.json'
    shpfile = '/home/bpostlet/thesis/mapping/stations'
    stationlist = '/home/bpostlet/thesis/shellscripts/cnsn_stn.list'
    json2shapefile(dbfile, shpfile)
