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

def shape2json(shapeRecs):

    m = {}
    for i, shapeRec in enumerate(shapeRecs):
        ix = "block_"+ str(i)
        m[ix] = {}
        m[ix]["Vp"] = shapeRec.record[0]
        #m[ix]["Vs"] = shapeRec.record[VS]
        m[ix]["R"] = shapeRec.record[1]
        m[ix]["H"] = shapeRec.record[2]
        m[ix]["geoprov"] = shapeRec.record[3]
        m[ix]["era"] = shapeRec.record[4].lower()
        m[ix]["period"] = shapeRec.record[5].lower()
        (lon, lat) = lonlatbbox(shapeRec.shape.bbox)
        m[ix]["lat"] = lat
        m[ix]["lon"] = lon

    return m

def lonlatbbox(bbox):
    return ( (bbox[0] + bbox[2]) / 2, (bbox[1] + bbox[3]) / 2 )

if __name__== '__main__' :

    c2jfile = os.environ['HOME'] + '/thesis/data/crust1.json'
    sf = shapefile.Reader(os.environ['HOME'] + '/thesis/mapping/crust1GeoChron')
    shapeRecs = sf.shapeRecords()

    jdict = shape2json(shapeRecs)

    open(c2jfile,'w').write( json.dumps(jdict, indent = 2 ))
