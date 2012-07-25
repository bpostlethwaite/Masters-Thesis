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
import json, os, argparse, sys
from preprocessor import is_number
from collections import defaultdict
import shapefile

# CONFIGS
netdir = '/media/TerraS/CN'
dbfile = os.environ['HOME']+'/thesis/stations.json'
shpfile = '/home/bpostlet/thesis/mapping/stations'
stationlist = '/home/bpostlet/thesis/shellscripts/cnsn_stn.list'


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
    if statdict['badCompEvents'] > 99:
        status = "data corruption"
    statdict['status'] = status
    return statdict

def updateStats(stdict, pipedStations = False):
    ''' Walks through all the keys in the main json database
    and checks if there are stats for that station. If there is
    it updates the keys and values, otherwise it sets "status"
    to "not aquired" '''

    # Get list of downloaded stations
    stns = os.listdir(netdir)

    for station in stdict.keys():
        if station in stns:
            # Get stats on downloaded stations and add to dictionary
            stndir = os.path.join(netdir, station)
            d = stationStats(stndir)
            for key in d.keys():
                stdict[station][key] = d[key]
        else:
            # If not downloaded set appropriate status
            stdict[station]['status'] = "not aquired"

    open(dbfile,'w').write( json.dumps(stdict, sort_keys = True, indent = 4 ))


def compare(A, B, op):
    return {
        '==': lambda A, B: A == B,
        '>': lambda A, B: A > B,
        '>=': lambda A, B: A >= B,
        '<': lambda A, B: A < B,
        '<=': lambda A, B: A <= B,
        }[op](A, B)

def queryStats(stdict, args):
    ''' Queries the json dictionary structure containing stations for given
    queries, logical commands and arguments. This is meant to be coupled with
    a CLI interface'''

    attrib = args.query[0]
    operator = args.query[1]
    value = args.query[2] if not is_number(args.query[2]) else float(args.query[2])

    qdict = ( { k:v for k, v in stdict.items() if (attrib in stdict[k] and compare(stdict[k][attrib], value, operator))  } )

    qdict = filterStats(qdict, args)



def printStats(stdict, args):
    ''' Just prints the passed in dictionary running filters. No query actions'''
    qdict = filterStats(stdict, args)



def filterStats(qdict, args):
    ''' Filters the dictionary by a station list (pipedStations)
    and by an attribute list (attrs)'''
    if args.pipedData:
        qdict = ( { k:v for k, v in qdict.items() if k in args.pipedData } )

    if args.attribute:
        for k in qdict.keys():
            for attr in qdict[k].keys():
                if attr not in args.attribute:
                    del qdict[k][attr]

    if args.keys:
        for key in qdict.keys():
            print key
    else:
        print json.dumps(qdict, sort_keys = True, indent = 4)



if __name__== '__main__' :

    #Load station database
    dbf =  open(dbfile)
    stdict = json.loads( dbf.read() )


    # Create top-level parser
    parser = argparse.ArgumentParser(description = "manage and query the station data json database")
    group = parser.add_mutually_exclusive_group()
    # Create query parser
    group.add_argument('-q','--query', nargs = 3,
                        help = "<attribute> '<operator>' <value>")

    group.add_argument('-u','--update', action = 'store_true',
                        help = "updates database with statistics from data files")

    group.add_argument('-p','--printer', action = 'store_true',
                       help = "prints out all stations or stations piped in." +
                       "Use with -a flag to print only certain attributes")

    parser.add_argument('-a','--attribute', nargs = '+',
                        help = '<attrib1> <attrib2> ... Add the attributes to be printed out')

    parser.add_argument('-k','--keys', action = 'store_true',
                        help = 'Prints only the keys (station name) of the database')


    # Parse arg list
    args = parser.parse_args()

    # Append piped data if there is any
    # If we pipe a bunch of stations to program, query only these stations
    if not sys.stdin.isatty():
        args.pipedData = sys.stdin.read().split('\n')
    else:
        args.pipedData = None

    if args.update:
        updateStats(stdict, args)

    if args.query:
        queryStats(stdict, args)

    if args.printer:
        printStats(stdict, args)
