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
import numpy as np
from plotTools import find

shpfile = os.environ['HOME'] + '/thesis/mapping/mooney/crust2layer'
crusttypes = os.environ['HOME'] + '/thesis/mapping/mooney/TypeGrid.txt'
typekeys = os.environ['HOME'] + '/thesis/mapping/mooney/TypeGrid_key.txt'



#### BUILD FIELDS

#fields.append('TypeCode','CrustName')
#for param in params:
#    for loc in locs:
#        if param == 'H' and loc == 'Mantle':
#            fields.append("H_Total")
#        else:
#            fields.append(param + "_" + loc)



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
# 0) ice, 1) water, 2) soft sediments, 3) hard sediments,
# 4) upper crust, 5) middle crust, 6) lower crust and 7) Mantle
# Each type key has these 8 columns for each of 4 rows:
# 0) P-wave, 1) S-wave, 2) Density and 3) Crustal Thickness
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

            #typedict[tkey]['seds'] = seds
            #typedict[tkey]['ice'] = ice

        else: # Parameter Lines: Just append as arrays
            # Strip trailing characters and turn into floats and assign to a numpy array
            typedict[tkey]["params"].append(np.array( map(float, [x.strip('.\n') for x in line.split()]) ) )


#['0', '0', '1.5', '18.', '3', '6.5', '6', 'inf.', '35']

# Now we have a dictionary full of the type information
# such as Vp for the different layers. What we want is
# an estimate for Vp for the crust as a whole
# So we need to average parameters over layer thickness's
# and include effects of ice and sedimentation.
# Mooney, Laske and Masters, Crust 5.1: a global crustal model at 5x5 degrees, JGR, 103, 727-747, 1998.
# Typedict[key][params] is:
# 8 Columns of data storing:
# 0) ice, 1) water, 2) soft sediments, 3) hard sediments,
# 4) upper crust, 5) middle crust, 6) lower crust and 7) Mantle
# Each type key has these 8 columns for each of 4 rows:
# 0) P-wave, 1) S-wave, 2) Density and 3) Crustal Thickness
# With the Crustal Thickness row 3) containing and 9th column
# 8) Total Thickness
# EXAMPLE:
# ice   h20     ss      hs      uc      mc      lc      mnt    total
# 3.81	1.5	3.8	4.3	6.1	6.6	7.2	7.9           Pwave
# 1.94	0	2.1	2.5	3.5	3.8	4	4.5           Swave
# 0.92	1.02	2.3	2.5	2.75	2.9	3.1	3.3           Density
# 1.5	0	0.5	0	19	12	6	inf.	39    Thickness

mooney = []
for coords, key in mtypes:
    vp = typedict[key]['params'][0][0:7] # Vp Ice -> lower crust
    vs = typedict[key]['params'][1][0:7] # Vs Ice -> lower crust
    h = typedict[key]['params'][3][0:7] # H Ice -> lower crust
    ht = typedict[key]['params'][3][8] # Total thickness
    ratio = h / ht
    #print vp
    mooney.append( (
            coords,
            key,
            typedict[key]['txt'],
            ( np.dot(vp, ratio),
              np.dot(vs, ratio),
              ht)) )





# 45 characters in length! We will need to truncate this
# Before adding to attribute table in GIS
#print max([len(d['txt']) for (_, d) in mooney])


## Build Shapefile

def crust2shape(mooney):
    """ transfer mooney data into a shapefile + attribute table """
    w = shapefile.Writer( shapefile.POLYGON )
    # Set fields for attribute table

    w.field("mcode", 'C', '3')
    w.field("Geotype", 'C', '45')
    w.field("mVp", 'N', 7, 4)
    w.field("mVs", 'N', 7, 4)
    w.field("mH", 'N', 7, 4)

    for (lon, lat), key, txt, (vp, vs, ht) in mooney:
        # Set lon & lat


        w.poly( parts = [ [[lon, lat],
                          [lon - 2, lat ],
                          [lon - 2, lat - 2],
                          [lon, lat - 2 ],
                          [lon, lat]] ] )

        w.record( key,
                  txt,
                  "{0:2.4f}".format(vp),
                  "{0:2.4f}".format(vs),
                  "{0:2.4f}".format(ht))


    w.save(shpfile)


crust2shape(mooney)
