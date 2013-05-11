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
import os, json
import shapefile

MCODE = 0
GEOTYPE = 1
VP = 2
VS = 3
H = 4
R = 5
GEOPROV = 6

def shape2json(shapeRecs):

    m = {}
    for i, shapeRec in enumerate(shapeRecs):
        ix = "block_"+ str(i)
        m[ix] = {}
        m[ix]["Vp"] = shapeRec.record[VP]
        m[ix]["Vs"] = shapeRec.record[VS]
        m[ix]["R"] = shapeRec.record[R]
        m[ix]["H"] = shapeRec.record[H]
        m[ix]["geoprov"] = shapeRec.record[GEOPROV]
        (lon, lat) = lonlatbbox(shapeRec.shape.bbox)
        m[ix]["lat"] = lat
        m[ix]["lon"] = lon

    return m

def lonlatbbox(bbox):
    return ( (bbox[0] + bbox[2]) / 2, (bbox[1] + bbox[3]) / 2 )

if __name__== '__main__' :

    c2jfile = os.environ['HOME'] + '/thesis/data/crust2.json'
    sf = shapefile.Reader(os.environ['HOME'] + '/thesis/mapping/mooney/crust2geology')
    shapeRecs = sf.shapeRecords()

    jdict = shape2json(shapeRecs)

    open(c2jfile,'w').write( json.dumps(jdict, indent = 2 ))
