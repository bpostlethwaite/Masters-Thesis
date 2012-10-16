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
import shapefile
import scipy.io as sio

# CONFIGS
databasedir = '/media/TerraS/database'
netdir = '/media/TerraS/CN'
dbfile = os.environ['HOME'] + '/thesis/stations.json'
shpfile = os.environ['HOME'] + '/thesis/mapping/stations'
stationlist = os.environ['HOME'] + '/thesis/shellscripts/cnsn_stn.list'
updtime = os.environ['HOME'] + '/thesis/updtime.data'


def flattenlist(a, result=None):
    """Flattens a nested list.

        >>> flattenlist([ [1, 2, [3, 4] ], [5, 6], 7])
        [1, 2, 3, 4, 5, 6, 7]
    """
    if result is None:
        result = []

    for x in a:
        if isinstance(x, list):
            flattenlist(x, result)
        else:
            result.append(x)

    return result

def flattendict(a, sep, pfx = '', result = None):
    """Flattens a nested dictionary.

        >>> flattendict( {'a' : 3, 'b' : {'a' : 1, 'b' : 2} })
        {'a' : 3, 'b::a' : 1, 'b::b' : 2}
    """
    if result is None:
        result = {}

    for k, v in a.items():
        if isinstance(v, dict):
            flattendict(v, sep, pfx = pfx + k + sep, result = result)
        else:
            result[pfx + k] = v

    return result

class Scoper(object):

    def __init__(self, sep):
        self.sep = sep

    def flattendict(self, a):
        return flattendict(a, self.sep)

    def unscopekey(self, keys):
        """ Removes scope operator from keys."""
        if isinstance(keys, list):
            return [ k[ k.rfind(self.sep) + 1 :] for k in keys ]
        else:
            return keys[ keys.rfind(self.sep) + 1 :]

    def normscope(self, keys, reuslt = None):
        """Replaces scope operator with python acceptable underscore _."""
        if isinstance(keys, list):
            return [ str.replace(k, self.sep, "_") for k in keys ]
        else:
            return str.replace(keys, self.sep, "_")



def buildStations(stdict, cnsnlist):
    ''' Builds station database from a list of stations taken
    from the website:
    http://www.earthquakescanada.nrcan.gc.ca/stndon/data_avail-eng.php'''

    reg = re.compile(r'^[BH][H].$')
    d = {}
    q = defaultdict(int)

    with open(cnsnlist) as stations:
        for s in stations:
            field = s.rstrip().split()
            station = field[0]
            if station not in stdict and reg.match(field[1]):
                d[ station ] = {'network': field[-1],
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

    stdict = dict(stdict.items() + d.items()) # Merge the old dict with new items

    open(dbfile,'w').write( json.dumps(stdict, sort_keys = True, indent = 2 ))

def json2shapefile(stdict):
    ''' Converts the stations.json data into a shapefile for usage with
    GIS programs such as QGIS'''
    w = shapefile.Writer( shapeType = 1 )
    # Set fields for attribute table

    fields = ["Vp","R","H","stdVp","stdR","stdH"]
    w.field("station", 'C', '6')
    w.field("network", 'C', '10')
    w.field("status", 'C', '16')
    #w.field("Vp", "C", "5")
    for field in fields:
        w.field(field, 'C', '5')

    for key in stdict.keys():
        # Set lon & lat
        w.point( stdict[key]["lon"], stdict[key]["lat"] )
        values = []
        for f in fields:
            values.append( '{0:5.2f}'.format(stdict[key][f]) if f in stdict[key] else "None ")
        w.record( key,
                  stdict[key]["network"],
                  stdict[key]["status"],
                  values[0],
                  values[1],
                  values[2],
                  values[3],
                  values[4],
                  values[5] )

    w.save(shpfile)

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
            # Shared data
            statdict[station]['processnotes'] = ''.join([''.join(c) for c in db['processnotes']])
            # Specific Processing Data
            try:
                statdict[station]['mb'] = {}
                statdict[station]['mb']['Vp'] = float(db['mb']['vbest'])
                statdict[station]['mb']['R'] = float(db['mb']['rbest'])
                statdict[station]['mb']['H'] = float(db['mb']['hbest'])
                statdict[station]['mb']['stdVp'] = float(db['mb']['stdVp'])
                statdict[station]['mb']['stdR'] = float(db['mb']['stdR'])
                statdict[station]['mb']['stdH'] = float(db['mb']['stdH'])
            except IndexError:
                pass

            try:
                statdict[station]['km'] = {}
                statdict[station]['km']['R'] = float(db['km']['rbest'])
                statdict[station]['km']['H'] = float(db['km']['hbest'])
                statdict[station]['km']['stdR'] = float(db['km']['stdR'])
                statdict[station]['km']['stdH'] = float(db['km']['stdH'])
            except IndexError:
                pass

    return statdict

def setStatus(s, stdict):
    '''Sets the status of the station depending on various criteria.
    Note the default is aquired, since for this function to run the data
    must have been scanned'''
    for k in s.keys():
        status = "aquired"
        if 'poorEvents' in s[k] and s[k]['poorEvents'] >= 1:
            status = "picked"
        # CHANGE THIS BELOW TO A KANAMORI STATISTIC
        if 'mb' in s[k]: # Set processing status by MB algo's Vp result
            if 'stdVp' in s[k]['mb']:
                if s[k]['mb']['stdVp'] <= 0.5:
                    status = "processed-ok"
                else:
                    status = 'processed-notok'
        if 'usableEvents' in s[k] and s[k]['usableEvents'] < 15:
            status = "data corruption"
        if 'badCompEvents' in s[k] and s[k]['badCompEvents'] > 99:
            status = "data corruption"
        # If user has selected bad station, don't change it.
        if k in stdict and stdict[k]['status'] == 'bad station':
            status = "bad station"
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
    # Loop through file statistics and .mat files
    # and if modify time is later, collect data
    # If force flag, collect regardless of the modification time
    statdict = fileStats(statdict, modtime, args.force)
    statdict = matStats(statdict, modtime, args.force)
    statdict = setStatus(statdict, stdict)
    # Set the station.json stats to the collected stats
    for station in statdict.keys():
        for attribute in statdict[station].keys():
            stdict[station][attribute] = statdict[station][attribute]

    open(dbfile,'w').write( json.dumps(stdict, sort_keys = True, indent = 2 ))
    # Update the modification time of last station.json update
    open(updtime,'w').write( str(time.time()) )

def compare(A, B, op):
    return {
        'eq': lambda A, B: A == B,
        'gt': lambda A, B: A > B,
        'gte': lambda A, B: A >= B,
        'lt': lambda A, B: A < B,
        'lte': lambda A, B: A <= B,
        'ne': lambda A, B: A != B,
        'in': lambda A, B: B in A
        }[op](A, B)

def queryStats(stdict, args, sep):
    ''' Queries the json dictionary structure containing stations for given
    queries, logical commands and arguments. This is meant to be coupled with
    a CLI interface'''

    value = args.query[2] if not is_number(args.query[2]) else float(args.query[2])
    operator = args.query[1]
    attrib = args.query[0]
    if sep in attrib:
        method, attrib = attrib.split(sep)
        return ({ k:v for k, v in stdict.items()
                  if (method in stdict[k]
                      and attrib in stdict[k][method]
                      and compare(stdict[k][method][attrib], value, operator))  } )
    else:
        return ({ k:v for k, v in stdict.items()
                  if (attrib in stdict[k]
                      and compare(stdict[k][attrib], value, operator))  } )

def getStats(qdict, args, sep, printer):
    ''' Filters the dictionary by a station list (pipedStations | command line list)
    and by an attribute list (attrs). Then returns &| prints out data'''

    if args.stationList: #check for piped data or station list or ALL stations
        qdict = ( { k:v for k, v in qdict.items() if k in args.stationList } )

    if args.attribute:
        # Further trim the list by selecting only
        # the stations that have the particular attribute
        # and get rid of all other attributes.
        adict = {}
        attrib = args.attribute[0]
        if sep in attrib:
            method, attrib = attrib.split(sep)
            for k in qdict.keys():
                if method in qdict[k]:
                    if attrib in qdict[k][method]:
                        adict[k] = {}
                        adict[k][method] = {}
                        adict[k][method][attrib] = qdict[k][method][attrib]
        else:
            for k in qdict.keys():
                print attrib
                if attrib in qdict[k]:
                    adict[k] = {}
                    adict[k][attrib] = qdict[k][attrib]
        qdict = adict

    if printer:
        if args.keys:
            for key in qdict.keys():
                print key
        else:
            print json.dumps(qdict, sort_keys = True, indent = 2)

    return qdict

def modifyData(stdict, args):
    ''' modifies database using <station> <attribute> <value>
    or if <station> <remove> then removes selected station'''
    # Note, only remove functionality coded.
    if args.stationList:
        stations = args.stationList
    else:
        # Pop off station argument of arg list
        stations =  [ args.modify.pop(0) ]
    for station in stations:
        if args.modify[0] == "remove":
            del stdict[station]
        elif args.modify[1] == "remove":
            attr = args.modify[0]
            del stdict[station][attr]
        else:
            attr = args.modify[0]
            value = args.modify[1]
            stdict[station][attr] = value

    open(dbfile,'w').write( json.dumps(stdict, sort_keys = True, indent = 2 ))




if __name__== '__main__' :

    #Load station database
    dbf =  open(dbfile)
    stdict = json.loads( dbf.read() )


    # Create top-level parser
    parser = argparse.ArgumentParser(description = "manage and query the station data json database")
    group = parser.add_mutually_exclusive_group()

    # Create query parser
    parser.add_argument('-p', '--printer', nargs = '*',
                       help = "<stationA> <stationB> or pipe stations in. Default without arg is ALL stations")

    group.add_argument('-q','--query', nargs = 3,
                        help = "<attribute> < eq | ne | gt | gte | lt | lte | in > <value>, <attrib> can be a nested key like <attrib.attrib>")

    group.add_argument('-m','--modify', nargs = '+',
                       help = "Either <station> <attribute> <value> or <station> <attribute> 'remove' or <station> 'remove'." +
                       "If you pipe data into program then it operates on all stations piped in and you leave <station> out." )

    parser.add_argument('-a','--attribute', nargs = '+',
                        help = 'Only the given attributes will be printed out')

    parser.add_argument('-k','--keys', action = 'store_true',
                        help = 'Prints only the keys (station name) of the database')

    parser.add_argument('-f', '--force', action = 'store_true',
                        help = 'Forces updating even if files and folders are older than the stations.json file')

    group.add_argument('-u','--update', action = 'store_true',
                        help = "updates database with statistics from data files")

    group.add_argument('-s',"--shape", action = "store_true",
                       help = "creates shapefile from stations.json")

    group.add_argument('-b',"--build", action = "store_true",
                       help = "Builds stations from CNSN station list. Won't overwrite existing database stations")

    # Parse arg list
    args = parser.parse_args()

    # Append piped data if there is any
    # If we pipe a bunch of stations to program, query only these stations
    if not sys.stdin.isatty():
        # trick to seperate a newline or space seperated list. Always returns list.
        args.stationList =  re.findall(r'\w+', sys.stdin.read() )
    else:
        args.stationList = False

    sep = "::"

    if args.update:
        updateStats(stdict, args)

    if args.query:
        stdict = queryStats(stdict, args, sep)
        getStats(stdict, args, sep, printer = True)

    if args.printer != None:
        # if it has command line options assume stations
        if args.printer:
            args.stationList = args.printer
        getStats(stdict, args, sep, printer = True)

    if args.modify:
        modifyData(stdict, args)

    if args.shape:
        json2shapefile(stdict)

    if args.build:
        buildStations(stdict, stationlist)
