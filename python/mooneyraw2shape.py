#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import shapefile, os
import numpy as np
from plotTools import find
import json

shpfile = os.environ['HOME'] + '/thesis/mapping/mooney/mooneyShots'
dat = os.environ['HOME'] + '/thesis/mapping/mooney/Canada.dat'
moonf = os.environ['HOME'] + '/thesis/data/moonShots.json'
readings = []

    # ratio = h / ht
    # #print vp
    # mooney.append( (
    #         coords,
    #         key,
    #         typedict[key]['txt'],
    #         ( np.dot(vp, ratio),
    #           np.dot(vs, ratio),
    #           ht)) )

def process(r):
# Run through each record set and compile Vp averages
# Make sure we don't add mantle data and check to make
# Sure the thickness add up to correct total.
# Note we are computing total distance to moho, meaning
# crust + seds + ice ...
    vp = []
    h = []
    htotal = None
    end = 0
    # Make sure we sum up to the mantle by going through and
    # looking for m or mg symbols. Keep track of line number.
    for ind, fs in enumerate(r):
        if len(fs) >= 5:
            if "m" in fs[4]:
                htotal = float(fs[3])
                end = ind
                break
        if len(fs) >= 6:
            if "m" in fs[5]:
                htotal = float(fs[4])
                end = ind
                break

    if htotal:
        for ind in range(end):
            fs = r[ind]
            if ind == 0:
                code = fs[0]
                lat = fs[1]
                vp.append(float(fs[2]))
                h.append(float(fs[4]))

            elif ind == 1:
                lon = fs[0]
                vp.append(float(fs[1]))
                h.append(float(fs[3]))

            else:
                vp.append(float(fs[0]))
                h.append(float(fs[2]))

        if end == 1:
            lon = r[1][0]
            # Now we are done loop, process record and output
        h = np.array(h)
        vp = np.array(vp)
        assert (np.sum(h) - htotal) < 0.001
        # If Vp == 0 cast out, probably means it's a Vs reading
        vpsum = np.dot(vp, h / htotal)
        if vpsum == 0:
            return None
        else:
            return code, -float(lon[:-1]), float(lat[:-1]) , vpsum, htotal

    else:
        return None


def mooney2shapefile(moon):
    """ transfer mooney data into a shapefile + attribute table """
    w = shapefile.Writer( shapeType = 1 )
    # Set fields for attribute table

    w.field("mcode", 'C', '5')
    w.field("mVp", 'N', 7, 3)
    w.field("mH", 'N', 7, 3)

    for k in moon.keys():
        # Set lon & lat
        w.point( moon[k]["lon"], moon[k]["lat"] )
        w.record( k,
                  "{0:3.3f}".format(moon[k]["Vp"]),
                  "{0:3.3f}".format(moon[k]["H"]))

    w.save(shpfile)



### Main loop
data = {}


with open(dat) as f:
    for i in range(0,2):
        f.readline() # Skip headers
    for line in f.readlines():
        # If zero we are at a new record:
        # process data and reset counters
        if len(line.split()) == 0:
            p = process(readings)
            readings = []
            if p:
                key, lon, lat, vp, h = p
                data[key] = {}
                data[key]["lon"] = lon
                data[key]["lat"] = lat
                data[key]["Vp"] = vp
                data[key]["H"] = h
        else:
            readings.append( line.split() )

#for d in data:
#    print d[1]

mooney2shapefile(data)
#print json.dumps(data, sort_keys = True, indent = 2 )
open(moonf,'w').write( json.dumps(data, sort_keys = True, indent = 2 ))
