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
import json, os, argparse
from preprocessor import is_number
from collections import defaultdict
import shapefile


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

def updateStats(stdict, netdir):
    ''' Walks through all the keys in the main json database
    and checks if there are stats for that station. If there is
    it updates the keys and values, otherwise it sets "status"
    to "not aquired" '''

    for station in stdict.keys():
        stndir = os.path.join(netdir, station)
        try:
            d = stationStats(stndir)
            for key in d.keys():
                stdict[station][key] = d[key]
        except OSError, KeyError:
            stdict[station]['status'] = "not aquired"
            continue
    return stdict

def compare(A, B, op):
    return {
        '==': lambda A, B: A == B,
        '>': lambda A, B: A > B,
        '>=': lambda A, B: A >= B,
        '<': lambda A, B: A < B,
        '<=': lambda A, B: A <= B,
        'True': True,
        'False': False
        }[op](A, B)

def queryStats(stdict, attrib = None, operator = None, value = None):
    ''' Queries the json dictionary structure containing stations for given
    queries, logical commands and arguments. This is meant to be coupled with
    a CLI interface'''

    qdict = ( { k:v for k, v in stdict.items() if (attrib in stdict[k] and compare(stdict[k][attrib], value, operator))  } )
    return qdict


if __name__== '__main__' :

    # Hard coded variables
    netdir = '/media/TerraS/CN'
    dbfile = os.environ['HOME']+'/thesis/stations.json'
    shpfile = '/home/bpostlet/thesis/mapping/stations'
    stationlist = '/home/bpostlet/thesis/shellscripts/cnsn_stn.list'

    # Setup option parser
    parser = argparse.ArgumentParser(description = "manage and query the station data json database")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("-u", "--update", help = "updates database with statistics from data files",
                        action = "store_true")
    group.add_argument("-q", "--query", nargs = 3, help = "--query <attribute> <operator> <value>")
    args = parser.parse_args()

    #Load station database
    dbf =  open(dbfile)
    stdict = json.loads( dbf.read() )
    if args.update:
        stdict = updateStats(stdict, netdir)
        open(dbfile,'w').write( json.dumps(stdict, sort_keys = True, indent = 4 ))

    if args.query:
        stdict = queryStats(stdict,args.query[0], args.query[1], args.query[2])
        print json.dumps(stdict, sort_keys = True, indent = 4)
