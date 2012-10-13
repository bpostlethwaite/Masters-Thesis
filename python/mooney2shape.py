#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
#
# Program to build mooney Crust 2.0 shapefile over Canada
#
###########################################################################
# IMPORTS
###########################################################################
import shapefile, os
import fnmatch

def find(seq, pattern):
    pattern = pattern.lower()
    for i, n in enumerate(seq):
        if fnmatch.fnmatch(n.lower(), pattern):
            return i
    return -1

def index(seq, pattern):
    result = find(seq, pattern)
    if result == -1:
        raise ValueError
    return result


shpfile = os.environ['HOME'] + '/thesis/mapping/mooneyGrid'
crusttypes = os.environ['HOME'] + '/thesis/mapping/mooneyTypeGrid.txt'
typekeys = os.environ['HOME'] + '/thesis/mapping/mooneyTypeGrid_key.txt'




#### BUILD FIELDS
fields = []
params = ['Vp','Vs','R','H','Rho']
locs = ['UppCrust','MidCrust','LwrCrust','Mantle']
#fields.append('TypeCode','CrustName')
for param in params:
    for loc in locs:
        if param == 'H' and loc == 'Mantle':
            fields.append("H_Total")
        else:
            fields.append(param + "_" + loc)

# Break Canada into 2x2 blocks
# Go into typegrid and select
# out the type code corrisponding
# to that 2x2 cell.
# Output a tuple ( (lat,lon), typecode)
# Where (lat,lon) are locations of topleft
# or NW corner of 2x2 degree cell.
mtypes = []
with open(crusttypes) as f:
    f.readline() #Skip first row (header)
    for lat in range(90, 40, -2):
        ctypes = f.readline().split() #For each new 2deg lat move down a line
        for lon in range(-150, -50, 2):
            mtypes.append( ( (lon, lat), ctypes[ (lon + 182) / 2 ] ) )

### BUILD TYPE KEYS FROM FILE
# Each individual profile is a 7 layer 1D-model with
# 8 Columns of data storing:
# 1) ice, 2) water, 3) soft sediments, 4) hard sediments,
# 5) upper crust, 6) middle crust, 7) lower crust and 8) Mantle
# Each type key has these 8 columns for each of 4 rows:
# 1) P-wave, 2) S-wave, 3) Density and 4) Crustal Thickness
# Also included next to the TypeKeyname is geological region type
# and sediment and/or ice thickness
typedict = {}
tkey = "crust_code"
with open(typekeys) as f:
    for i in range(0,5):
        f.readline() # Skip headers
    for ind, line in enumerate(f.readlines()):
        if ind % 5 == 0: # Header Line
            info = line.rstrip().split()
            tkey = info[0]
            typedict[tkey] = {}
            typedict[tkey]["params"] = []
            ### First lets parse the info on the main header line in the
            # Type info and data. This is going to take a little AI
            ## Look For Seds at end of line
            ix = find(info, 'sed*')
            if ix == -1: # Don't find it
                nk = len(info); #Set marker to end of field array
                ice = 0.0
            # If so, see if we can extract some data
            elif "no" in info[ix - 1].lower():
                seds = 0.0
                nk = ix - 1

            # Sometimes its written 3km instead of 3 km
            # So strip out last two letters and hope for the best.
            elif "km" in info[ix - 1].lower() and len(info[ix - 1]) > 2:
                seds = float(info[ix - 1][:-2])
                nk = ix - 1
            else:
                seds = float(info[ix - 2])
                nk = ix - 2

            ## Look for ice somewhere near beginning of line
            iy = find(info, 'ice*')
            if iy == -1: # Don't find it
                mk = 1; #Set marker to beginning of array + 1
                ice = 0.0

            # If so, see if we can extract some data
            elif "no" in info[iy - 1].lower():
                ice = 0.0
                mk = iy - 1

            # Sometimes its written 3km instead of 3 km
            # So strip out last two letters and hope for the best.
            elif "km" in info[iy - 1].lower() and len(info[iy - 1]) > 2:
                ice = float(info[iy - 1][:-2])
                mk = iy - 1
            else:
                ice = float(info[iy - 2])
                mk = iy - 2

            # If no ice just join from after key to beginning of seds
            if iy == -1:
                typedict[tkey]['txt'] = " ".join(info[mk : nk]).rstrip(',')
            # If there IS ice then we want the fist part before Ice is mentioned, and
            # anything between Ice and Seds.
            else:
                # Was going to put the stuff between ice and seds... but this is primarly location information.
                # Not really useful to this application
                typedict[tkey]['txt'] = " ".join(info[1 : mk]).rstrip(',') #+ " " + " ".join(info[iy+1 : nk]).rstrip(',')

            typedict[tkey]['seds'] = seds
            typedict[tkey]['ice'] = ice

        else: # Parameter Lines: Just append as arrays
            typedict[tkey]["params"].append(line.rstrip().split())


# Now we have a big list of lon and lats for Canada
# Associated with Ctypes and a big dictionary of
# Ctype values. We need to link the two together.

# Here we create a list with a tuple at each entry
# The tuples first value is a tuple with lat/lon in it
# The second value is a dictionary with all the values in it.
mooney = []
for (lat,lon), key in mtypes:
    mooney.append( ((lat,lon), typedict[key]) )

# 45 characters in length! We will need to truncate this
# Before adding to attribute table in GIS
print max([len(d['txt']) for (_, d) in mooney])

## Build Shapefile

def json2shapefile(stdict):
    ''' Converts the stations.json data into a shapefile for usage with
    GIS programs such as QGIS'''
    w = shapefile.Writer( shapeType = 4 )
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
