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
import json, os, argparse, sys, time
from preprocessor import is_number
from collections import defaultdict
import shapefile
import scipy.io as sio

# CONFIGS
databasedir = '/media/TerraS/database'
netdir = '/media/TerraS/CN'
dbfile = os.environ['HOME'] + '/thesis/stations.json'
shpfile = os.environ['HOME'] + '/thesis/mapping/stations'
stationlist = os.environ['HOME'] + '/thesis/shellscripts/cnsn_stn.list'
updtime = os.environ['HOME'] + '/thesis/updtime.data'

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
                             'stop': 0 if not is_number( field[6] ) else field[6],
                             'status': "not aquired"
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


def fileStats(statdict, modtime, force = False):
    ''' Runs through station directory and collects
    stats into a dictionary for merging into main database'''

    for station in os.listdir(netdir):
        if force or (os.stat( os.path.join(netdir,station) ).st_mtime > modtime):
            events = os.listdir( os.path.join(netdir,station) )
            if station not in statdict:
                statdict[station] = {}
            statdict[station]['numEvents'] = len(events)
            statdict[station]['poorEvents'] = len( filter(isPoor,events) )
            statdict[station]['usableEvents'] = len( filter(is_number,events) )
            statdict[station]['badCompEvents'] = len( filter(missingComps,events) )
    return statdict

def matStats(statdict, modtime, force = False):
    ''' Run through matlab generated mat files and pull out pertinent information
    and put into the json station.json database'''

    for matfile in os.listdir(databasedir):
        if '.mat' in matfile and (force or os.stat(databasedir + '/' + matfile).st_mtime > modtime):
            mat = sio.loadmat(databasedir + '/' + matfile)
            station = os.path.splitext(matfile)[0]
            db = mat['db'][0,0]
            if station not in statdict:
                statdict[station] = {}
            statdict[station]['processnotes'] = ''.join([''.join(c) for c in db['processnotes']])
            statdict[station]['Vp'] = float(db['vbest'])
            statdict[station]['R'] = float(db['rbest'])
            statdict[station]['H'] = float(db['hbest'])
            statdict[station]['stdVp'] = float(db['stdVp'])
            statdict[station]['stdR'] = float(db['stdR'])
            statdict[station]['stdH'] = float(db['stdH'])
    return statdict

def setStatus(s):
    '''Sets the status of the station depending on various criteria.
    Note the default is aquired, since for this function to run the data
    must have been scanned'''
    for k in s.keys():
        status = "aquired"
        if 'poorEvents' in s[k] and s[k]['poorEvents'] > 5:
            status = "picked"
        if 'badCompEvents' in s[k] and s[k]['badCompEvents'] > 99:
            status = "data corruption"
        if 'Vp' in s[k]:
            status = "processed"
        s[k]['status'] = status
    return s

def updateStats(stdict, args):
    ''' Sets file stats (which event folders are good which are labeled poor etc)
    as well as .mat file statistics from processing. It then runs the setStatus function
    to go over these and determine a suitable status. These new info are added to the database
    dictionary and saved. The updtime file which monitors the last time the database was updated
    is updated to the new time.'''

    # Get list of downloaded stations
    modtime = float( open(updtime, 'r').read() )
    statdict = {}
    statdict = fileStats(statdict, modtime, args.force)
    statdict = matStats(statdict, modtime, args.force)
    statdict = setStatus(statdict)
    stdict.update(statdict)

    open(dbfile,'w').write( json.dumps(stdict, sort_keys = True, indent = 4 ))
    open(updtime,'w').write( str(time.time()) )

def compare(A, B, op):
    return {
        '==': lambda A, B: A == B,
        '>': lambda A, B: A > B,
        '>=': lambda A, B: A >= B,
        '<': lambda A, B: A < B,
        '<=': lambda A, B: A <= B,
        '!=': lambda A, B: A != B
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
                        help = 'Only the given attributes will be printed out')

    parser.add_argument('-k','--keys', action = 'store_true',
                        help = 'Prints only the keys (station name) of the database')

    parser.add_argument('-f', '--force', action = 'store_true',
                        help = 'Forces updating even if files and folders are older than the stations.json file')

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
