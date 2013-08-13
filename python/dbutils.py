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
databasedir = '/media/bpostlet/TerraS/database'
netdir = '/media/bpostlet/TerraS/CN'
dbfile = os.environ['HOME'] + '/thesis/data/stations.json'
stationlist = os.environ['HOME'] + '/thesis/shellscripts/cnsn_stn.list'
updtime = os.environ['HOME'] + '/thesis/data/updtime.data'

fixerregex = re.compile('(?:[0-9\.]+)')
fixer = lambda x: [float(item) for item in fixerregex.findall(repr(x))]

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

def json2shapefile(stdict, fout, sc):
    ''' Converts the stations.json data into a shapefile for usage with
    GIS programs such as QGIS'''
    if fout == None:
        fout = os.environ['HOME'] + '/thesis/mapping/stations'
    else:
        fout = os.environ['HOME'] + '/thesis/mapping/' + fout
    w = shapefile.Writer( shapeType = 1 )
    # Set fields for attribute table

    fields = ["wm::Vp","wm::R", "hk::R", "hk::H", "hk::stdR", "hk::stdH"]
    w.field("station", 'C', '6')
    w.field("network", 'C', '10')
    w.field("status", 'C', '16')
    #w.field("Vp", "C", "5")
    for field in fields:
        w.field(field, 'N', 7, 4)

    conradfields = ["hdisc","hdiscp"]
    for f in conradfields:
        w.field(f, 'N', 7, 4)

    for key in stdict.keys():
        # Set lon & lat
        w.point( stdict[key]["lon"], stdict[key]["lat"] )
        values = []
        for f in fields:
            values.append( '{0:2.4f}'.format(sc.flattendict(stdict[key])[f]) if f in sc.flattendict(stdict[key]) else "None   ")

        # add conrad
        conradfields = ["conrad::hdisc","conrad::hdiscp"]
        for f in conradfields:
            d = None
            if f in sc.flattendict(stdict[key]) and sc.flattendict(stdict[key])[f]:
                disc = [disc for disc in sc.flattendict(stdict[key])[f] if (13.0 < disc < 21.0)]
                if disc:
                    d = disc[0]
            values.append('{0:2.4f}'.format(d) if d else 0.0)

        w.record( key,
                  stdict[key]["network"],
                  stdict[key]["status"],
                  values[0],
                  values[1],
                  values[2],
                  values[3],
                  values[4],
                  values[5],
                  values[6],
                  values[7])



    w.save(fout)

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
            try:
                statdict[station]['usable'] = int(db['usable'])
            except IndexError:
                pass

            # Specific Processing Data
            # try:
            #     statdict[station]['mb'] = {}
            #     statdict[station]['mb']['Vp'] = float(db['mb']['vbest'])
            #     statdict[station]['mb']['R'] = float(db['mb']['rbest'])
            #     statdict[station]['mb']['H'] = float(db['mb']['hbest'])
            #     statdict[station]['mb']['stdVp'] = float(db['mb']['stdVp'])
            #     statdict[station]['mb']['stdR'] = float(db['mb']['stdR'])
            #     statdict[station]['mb']['stdH'] = float(db['mb']['stdH'])
            # except IndexError:
            #     pass

            try:
                statdict[station]['hk'] = {}
                statdict[station]['hk']['R'] = float(db['hk']['rbest'])
                statdict[station]['hk']['H'] = float(db['hk']['hbest'])
                statdict[station]['hk']['stdR'] = float(db['hk']['stdR'])
                statdict[station]['hk']['stdH'] = float(db['hk']['stdH'])
                try:
                    statdict[station]['hk']['c0R'] = float(db['hk']['c0R'])
                    statdict[station]['hk']['c1R'] = float(db['hk']['c1R'])
                except ValueError:
                    pass
            except IndexError:
                pass

            try:
                statdict[station]['fg'] = {}
                statdict[station]['fg']['Vp'] = float(db['fg']['vbest'])
                statdict[station]['fg']['R'] = float(db['fg']['rbest'])
                statdict[station]['fg']['H'] = float(db['fg']['hbest'])
                statdict[station]['fg']['stdVp'] = float(db['fg']['stdVp'])
                statdict[station]['fg']['stdR'] = float(db['fg']['stdR'])
                statdict[station]['fg']['stdH'] = float(db['fg']['stdH'])
                statdict[station]['fg']['stdS'] = float(db['fg']['stdS'])
            except IndexError:
                pass

            try:
                statdict[station]['conrad'] = {}
                hfixed = fixer(db['conrad']['hdisc'])
                if hfixed:
                    statdict[station]['conrad']['hdisc'] = hfixed
                hpfixed = fixer(db['conrad']['hdiscp'])
                if hpfixed:
                    statdict[station]['conrad']['hdiscp'] = hpfixed
            except (IndexError, ValueError):
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
        if 'hk' in s[k]: # Set processing status by Kan R result
            if (s[k]['hk']['stdR'] < 0.08):
                status = "processed-ok"
            else:
                status = "processed-notok"
        if 'usableEvents' in s[k] and s[k]['usableEvents'] < 5:
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
        'in': lambda A, B: B in A,
        'not in': lambda A, B: B not in A
        }[op](A, B)

def queryStns(stdict, args, scp):
    ''' Queries the json dictionary structure containing stations for given
    queries, logical commands and arguments. This is meant to be coupled with
    a CLI interface'''

    qdict = stdict

    # Reduce station list if piped station data was present
    if args.stationList: #check for piped data or station list or ALL stations
        qdict = ( { k:v for k, v in stdict.items() if k in args.stationList } )

    # Run Query
    if args.query:
        value = args.query[2] if not is_number(args.query[2]) else float(args.query[2])
        operator = args.query[1]
        attrib = args.query[0]
        qdict = ({ k:v for k, v in qdict.items()
                   if (attrib in scp.flattendict(qdict[k])
                       and compare(scp.flattendict(qdict[k])[attrib], value, operator))  } )

    # Filter by attribute if required
    if args.attribute:
        # Further trim the list by selecting only
        # the stations that have the particular attribute
        # and get rid of all other attributes.
        adict = {}
        attrib = args.attribute[0]
        for k in qdict.keys():
            if attrib in scp.flattendict(qdict[k]):
                adict[k] = {}
                adict[k][attrib] = scp.flattendict(qdict[k])[attrib]

        qdict = adict

    return qdict

def printStns(stdict, qdict, args, scp):

    ndict = {}
    # Reverse: Print stations not listed in qdict
    if args.reverse:
        for stn in stdict:
            if stn not in qdict:
                ndict[stn] = stdict[stn]
        qdict = ndict

    # If both keys and attribute flags supplied
    # Print only attribute, no station name etc.
    if args.keys and args.attribute and not args.reverse:
        for key in qdict.keys():
            a = qdict[key].keys()[0]
            print qdict[key][a]

    # Print only station names
    elif args.keys:
        for key in qdict.keys():
            print key

    # Print the works
    else:
        print json.dumps(qdict, sort_keys = True, indent = 2)


def modifyData(stdict, args):
    ''' modifies database using <station> <attribute> <value>
    or if <station> <remove> then removes selected station'''
    # Note, need to implement scoping for remove capability.
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

    # Create top-level parser
    parser = argparse.ArgumentParser(description = "manage and query the station data json database")
    group = parser.add_mutually_exclusive_group()
    group2 = parser.add_mutually_exclusive_group()

    # Create query parser
    group.add_argument('-p', '--printer', nargs = '*',
                       help = "<stationA> <stationB> or pipe stations in. Default without arg is ALL stations")

    group.add_argument('-q','--query', nargs = 3,
                        help = "<attribute> < eq | ne | gt | gte | lt | lte | in > <value>, <attrib> can be a nested key like <attrib.attrib>")

    group.add_argument('-m','--modify', nargs = '+',
                       help = "Either <station> <attribute> <value> or <station> <attribute> 'remove' or <station> 'remove'." +
                       "If you pipe data into program then it operates on all stations piped in and you leave <station> out." )

    parser.add_argument('-a','--attribute', nargs = '+',
                        help = 'Print out the given attribute and supress all other attribues.' +
                        ' Works with the keys option, though the -k flag will just print out the attribute')

    parser.add_argument('-k','--keys', action = 'store_true',
                        help = 'Prints only the keys (station name) of the database')

    parser.add_argument('-r','--reverse', action = 'store_true',
                        help = 'Prints the stations NOT fitting the query or piped in stations.')

    parser.add_argument('-f', '--force', action = 'store_true',
                        help = 'Forces updating even if files and folders are older than the stations.json file')

    parser.add_argument('-d', '--data', nargs = 1,
                        help = 'Use the input file as source json instead of default stations.json')

    group.add_argument('-u','--update', action = 'store_true',
                        help = "updates database with statistics from data files")

    parser.add_argument('-s',"--shape", nargs = "*",
                       help = "Creates shapefile from stations.json. Use with query to filter before converting. Note this will overwrite stations.shp unless you provide a filename.")

    group.add_argument('-b',"--build", action = "store_true",
                       help = "Builds stations from CNSN station list. Won't overwrite existing database stations")

    # Parse arg list
    args = parser.parse_args()

    #Load station database
    if args.data:
        dbf = open(args.data[0])
    else:
        dbf =  open(dbfile)

    stdict = json.loads( dbf.read() )
    qdict = {}

    # Append piped data if there is any
    # If we pipe a bunch of stations to program, query only these stations
    if not sys.stdin.isatty():
        # trick to seperate a newline or space seperated list. Always returns list.
        args.stationList =  re.findall(r'\w+', sys.stdin.read() )
    else:
        args.stationList = False

    scp = Scoper("::")

    if args.update:
        updateStats(stdict, args)

    if args.query:
        qdict = queryStns(stdict, args, scp)
        printStns(stdict, qdict, args, scp)

    if args.printer != None:
        # if it has command line options (meaning its not an empty list)
        # assume there are stations after it, though piped stations should take
        # precedence.
        if args.printer and not args.stationList:
            args.stationList = args.printer
        printStns(stdict, queryStns(stdict, args, scp), args, scp)

    if args.modify:
        modifyData(stdict, args)

    if args.shape != None:
        fout = None
        if args.shape:
            fout = args.shape
        if qdict:
            json2shapefile(qdict, fout, scp)
        else:
            json2shapefile(stdict, fout, scp)

    if args.build:
        buildStations(stdict, stationlist)
