#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import os, json
import dbf


# # Extracting Geological Province Data
# stnjson = os.environ['HOME'] + "/thesis/stations.json"
# stnd = json.loads( open(stnjson).read() )
# #Load geological time data

# db = dbf.Table(os.environ['HOME'] + "/thesis/mapping/stationGeology.dbf")

# for rec in db:
#     stnd[rec["station"]]["geoprov"] = (rec["geolprov"])


# #print json.dumps(stnd, sort_keys = True, indent = 2 )
# open(stnjson,'w').write( json.dumps(stnd, sort_keys = True, indent = 2 ))


# # Extracting Mooney Crust 2.0 Data
# stnjson = os.environ['HOME'] + "/thesis/stations.json"
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
# datafile = os.environ['HOME'] + "/thesis/stnChrons.json"
#epochdata = open(os.environ['HOME'] + '/thesis/epoch.json')
#epochdict = json.loads( epochdata.read() )

##     #Load geological time data
# db = dbf.Table(os.environ['HOME'] + "/thesis/mapping/stationGeology.dbf")

# stnChrons = {}
# for rec in db:
#     stnChrons[rec["station"]] = {}
#     stnChrons[rec["station"]]["lower"] = epochdict[rec["epoch"]][0]
#     stnChrons[rec["station"]]["upper"] = epochdict[rec["epoch"]][1]
#     stnChrons[rec["station"]]["era"] = rec["era"].lower()

# open(datafile,'w').write( json.dumps(stnChrons, sort_keys = True, indent = 2 ))
#print json.dumps(stnChrons, sort_keys = True, indent = 2 )


# # Extracting VpmoonGeology data -> VpmoonShots.json
# moonvpGeology = os.environ['HOME'] + "/thesis/moonvpGeology.json"
# moonjson = os.environ['HOME'] + "/thesis/moonShots.json"
# d = json.loads( open(moonjson).read() )

# #Load geological time data

# db = dbf.Table(os.environ['HOME'] + "/thesis/mapping/moonVpGeology.dbf")
# m = {}
# for rec in db:
#     m[rec['mcode']] = d[rec['mcode']]
#     m[rec['mcode']]['geoprov'] = rec['geolprov']
#     m[rec["mcode"]]["lower"] = epochdict[rec["epoch"]][0]
#     m[rec["mcode"]]["upper"] = epochdict[rec["epoch"]][1]
#     m[rec["mcode"]]["era"] = rec["era"].lower()

# #print json.dumps(m, sort_keys = True, indent = 2 )
# open(moonvpGeology,'w').write( json.dumps(m, sort_keys = True, indent = 2 ))
