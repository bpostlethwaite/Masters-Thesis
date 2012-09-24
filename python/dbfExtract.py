#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import os, json
from dbfpy import dbf

datafile = os.environ['HOME'] + "/thesis/stationChrons.json"
epochdata = open(os.environ['HOME'] + '/thesis/epoch.json')
epochdict = json.loads( epochdata.read() )

    #Load geological time data
db = dbf.Dbf(os.environ['HOME'] + "/thesis/mapping/stationGeology.dbf")

stnChrons = {}
for rec in db:
    stnChrons[rec["STATION"]] = epochdict[rec["EPOCH"]]



open(datafile,'w').write( json.dumps(stnChrons, sort_keys = True, indent = 2 ))
#print json.dumps(stnChrons, sort_keys = True, indent = 2 )
