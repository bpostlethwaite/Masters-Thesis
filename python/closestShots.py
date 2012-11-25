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
import os, json
import numpy as np


distf = os.environ['HOME']+'/thesis/mapping/mooney/distance_stations2shots.csv'
# Dictionary of all of Mooney's canadian data which
# passed through the parser mooneyraw2shape.py
# It has keynumber, lat lon and Vp and H averages for the crust.
moonstns = os.environ['HOME'] + '/thesis/data/moonStations.json'
moonf = os.environ['HOME'] + '/thesis/data/moonShots.json'
mshots = json.loads( open(moonf).read() )

stns = []
data = []
# This reads in the big distance matrix as outputted from QGIS distance
# function. The D matrix is between all of mooney's shot data and
# All stations in the database.
with open(distf) as f:
    mid = f.readline().split(',')
    mid.pop(0) # Get rid of header ID
    for line in f.readlines():
        field = line.rstrip().split(',')
        stns.append(field.pop(0))
        data.append( map(float, field) )

stns = set(stns)
mid = np.array(mid)
A = np.array(data)

assert A.shape[0] == len(stns)
assert A.shape[1] == len(mid)


# Find stations and associated shots which have
# a seperation less than ddeg apart
ddeg = 0.5
L = A < ddeg

# Loop through all our stations from distance Matrix
# and create a new dictionary that combines mooney shot
# data with station keys for further processing using
# the Param class.
# We don't want multiple Vp values, we want one. So there
# are a few options. Do a simple average of the VP and H shot
# estimates, or do a distance weighted average.
mdict = {}
for ind, stn in enumerate(stns):
# Goes down the rows of the A distance matrix
# ind = row number
    # This selects from mid (array of mooney data identifiers)
    # those ID's corrisponding to data within ddeg range.
    mcodes = mid[L[ind]]
    # This selects the corrisponding actual distances associated with
    # The ID's above and station = stn. Then turns distances into weights
    # by dividing by distance limit plus a param = 0.3 which ensures we don't
    # have zero contribution at dist = distance limit (we subtract each from 1 to
    # make sure closer distance are weighted more heavily
    dists = A[ind, L[ind]]
    weights = 1 - dists / ddeg + 0.3
    weights = weights / np.sum(weights)
    if len(mcodes) > 0:
        Vp = 0
        H = 0
        mcodedict = {}
        for i, m in enumerate(mcodes):
            Vp += mshots[m]['Vp'] * weights[i]
            H += mshots[m]['H'] * weights[i]
            mcodedict[m] = [mshots[m]['Vp'],mshots[m]['H']]
        # Print information for visual inspection
        # print "--------"
        # print "station:", stn
        # print "MooneyCodes:", mcodes
        # print "Radius limit [degrees]:", ddeg
        # print "Vp:", Vp, "H:", H

        # Build dictionary
        mdict[stn] = {}
        mdict[stn]["Vp"] = Vp
        mdict[stn]["H"] = H
        mdict[stn]["mcodes"] = mcodedict

    else:
        continue

# Write json
#print json.dumps(mdict, sort_keys = True, indent = 2 )
open(moonstns,'w').write( json.dumps(mdict, sort_keys = True, indent = 2 ))
