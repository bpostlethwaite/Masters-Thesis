#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import os, json
import dbf


# Extracting Geological Province Data
# stnjson = os.environ['HOME'] + "/thesis/data/stations.json"
# stnd = json.loads( open(stnjson).read() )
# #Load geological time data

# db = dbf.Table(os.environ['HOME'] + "/thesis/mapping/stationGeology.dbf")

# for rec in db:
#     stnd[rec["station"]]["geoprov"] = (rec["geolprov"])


#print json.dumps(stnd, sort_keys = True, indent = 2 )
##open(stnjson,'w').write( json.dumps(stnd, sort_keys = True, indent = 2 ))


# # Extracting Mooney Crust 2.0 Data
# stnjson = os.environ['HOME'] + "/thesis/data/stations.json"
# stnd = json.loads( open(stnjson).read() )
# #Load geological time data

# db = dbf.Table(os.environ['HOME'] + "/thesis/mapping/stationMooney.dbf")

# for rec in db:
#     stnd[rec["station"]]["wm"] = {}
#     stnd[rec["station"]]["wm"]["Vp"] = float(rec["mvp"])
#     stnd[rec["station"]]["wm"]["R"] = float(rec["mvp"]) / float(rec["mvs"])
#     stnd[rec["station"]]["wm"]["H"] = float(rec["mh"])
#     stnd[rec["station"]]["wm"]["type"] = (rec["geotype"])


# #print json.dumps(stnd, sort_keys = True, indent = 2 )
# open(stnjson,'w').write( json.dumps(stnd, sort_keys = True, indent = 2 ))


##Extracting Station Chrons
# datafile = os.environ['HOME'] + "/thesis/data/stnChrons.json"
# epochdata = open(datafile)
# stndict = json.loads( open(os.environ['HOME'] + "/thesis/data/stations.json").read() )

# ##     #Load geological time data
# db = dbf.Table(os.environ['HOME'] + "/thesis/mapping/stationGeoChron.dbf")

# stnChrons = {}
# for rec in db:
#     stnChrons[rec[0]] = {}
#     stnChrons[rec[0]]["era"] = rec[11].lower()
#     stnChrons[rec[0]]["period"] = rec[12].lower()
#     stnChrons[rec[0]]["epoch"] = rec[13].lower()

# # open(datafile,'w').write( json.dumps(stnChrons, sort_keys = True, indent = 2 ))
# print json.dumps(stnChrons, sort_keys = True, indent = 2 )


# Extracting VpmoonGeology data -> VpmoonShots.json
moonvpGeology = os.environ['HOME'] + "/thesis/data/moonvpGeology.json"
moonvpGeoChron = os.environ['HOME'] + "/thesis/data/moonvpGeoChron.json"

#Load geological time data

db = dbf.Table(os.environ['HOME'] + "/thesis/mapping/moonVpGeoChron.dbf")
m = {}
for rec in db:
    mc = rec["mcode"]
    m[mc] = {}
    m[mc]["Vp"] = rec["mvp"]
    m[mc]["H"] = rec["mh"]
    m[mc]["geoprov"] = rec["geolprov"]
    m[mc]["era"] = rec["era"].lower()
    m[mc]["period"] = rec["period"].lower()
    m[mc]["epoch"] = rec["epoch"].lower()

#print json.dumps(m, sort_keys = True, indent = 2 )
open(moonvpGeoChron,'w').write( json.dumps(m, sort_keys = True, indent = 2 ))
