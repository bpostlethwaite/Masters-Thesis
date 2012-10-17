#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import os, json
import dbf


# Extracting Mooney Crust 2.0 Data
stnjson = os.environ['HOME'] + "/thesis/stations.json"
stnd = json.loads( open(stnjson).read() )
#Load geological time data

db = dbf.Table(os.environ['HOME'] + "/thesis/mapping/stationMooney.dbf")


for rec in db:
    stnd[rec["station"]]["wm"] = {}
    stnd[rec["station"]]["wm"]["Vp"] = float(rec["mvp"])
    stnd[rec["station"]]["wm"]["R"] = float(rec["mvp"]) / float(rec["mvs"])
    stnd[rec["station"]]["wm"]["H"] = float(rec["mh"])


#print json.dumps(stnd, sort_keys = True, indent = 2 )
open(stnjson,'w').write( json.dumps(stnd, sort_keys = True, indent = 2 ))


# Extracting Station Chrons
# datafile = os.environ['HOME'] + "/thesis/stnChrons.json"
# epochdata = open(os.environ['HOME'] + '/thesis/epoch.json')
# epochdict = json.loads( epochdata.read() )

#     #Load geological time data
# db = dbf.Dbf(os.environ['HOME'] + "/thesis/mapping/stationGeology.dbf")

# stnChrons = {}
# for rec in db:
#     stnChrons[rec["STATION"]] = epochdict[rec["EPOCH"]]



# open(datafile,'w').write( json.dumps(stnChrons, sort_keys = True, indent = 2 ))
# #print json.dumps(stnChrons, sort_keys = True, indent = 2 )
