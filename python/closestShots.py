#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save

# Perform some basic calcs on distance from stations to Mooney
# database raw shots. Select mooney shots based on dist and output
# a json station file with weighted averaged Vp's


###########################################################################
# IMPORTS
###########################################################################
import os, json, sys
import itertools as it






if __name__  == "__main__":


    distf = os.environ['HOME']+'/thesis/mapping/mooney/distance_stations2shots.csv'
    #Dictionary of all of Mooney's canadian data which
    #passed through the parser mooneyraw2shape.py
    #It has keynumber, lat lon and Vp and H averages for the crust.
    csstns = os.environ['HOME'] + '/thesis/data/csStations.json'
    moonf = os.environ['HOME'] + '/thesis/data/cshots.json'
    cshots = json.loads( open(moonf).read() )

    distd = {}
    # This reads in the distance matrix as outputted from QGIS distance
    # function. The D matrix is between n (10) closest of mooney's shot data and
    # All stations in the database.
    with open(distf) as f:
        f.readline() # Get rid of header ID
        for line in f.readlines():
            field = line.rstrip().split(',')
            stn = field.pop(0)
            if stn not in distd:
                distd[stn] = []
            distd[stn].append( [field[0], float(field[1])] )

# Filter dictionary to stations of this dist or less
# And also provide a wieghted average Vp and H

    ddeg = 0.5
    mdict = {}

    for stn in distd:
        data = [ [ d[0], d[1] ] for d in distd[stn] if d[1] <= ddeg]
        if not data:
            continue
        data = [[d[0], d[1], 1 - d[1]/ddeg + 0.3] for d in data]
        total = sum( d[2] for d in data )
        data = [[d[0], d[1], d[2] / total]  for d in data]
        mdict[stn] = {}
        mdict[stn]["Vp"] = sum( cshots[d[0]]['Vp'] * d[2] for d in data)
        mdict[stn]["H"] = sum( cshots[d[0]]['H'] * d[2] for d in data)
        mdict[stn]["mcodes"] = {d[0]:d[1] for d in data}


# Write json
#print json.dumps(mdict, sort_keys = True, indent = 2 )
open(csstns,'w').write( json.dumps(mdict, sort_keys = True, indent = 2 ))
