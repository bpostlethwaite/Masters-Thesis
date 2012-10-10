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
shpfile = os.environ['HOME'] + '/thesis/mapping/mooneyGrid'
crusttypes = os.environ['HOME'] + '/thesis/mapping/mooneyTypeGrid.txt'
typekeys = os.environ['HOME'] + '/thesis/mapping/mooneyTypeGrid_key.txt'

#### BUILD FIELDS
fields = []
params = ['Vp','Vs','R','H','Rho']
locs = ['UppCrust','MidCrust','LwrCrust','Mantle']
#fields.append('TypeCode','CrustName')
for param in params:
    for loc in locs:
        if param == 'H' and loc == 'Mantle':
            fields.append("H_Total")
        else:
            fields.append(param + "_" + loc)

with open(crusttypes) as f:
    txt = f.read()

    for lon in range(-150, -50, 2):
        for lat in range(90, 40, -2):
            print (lon + 182) / 2, lat

### BUILD TYPE KEYS FROM FILE
typedict = {}
tkey = "crust_code"
with open(typekeys) as f:
    for ind, line in enumerate(f.readlines()):
        if ind % 5 == 0:
            tkey = line.split()[0]
            typedict[tkey] = []
        else:
            typedict[tkey].append(line.rstrip().split())

## Build typeGrid


## Build Shapefile

def json2shapefile(stdict):
    ''' Converts the stations.json data into a shapefile for usage with
    GIS programs such as QGIS'''
    w = shapefile.Writer( shapeType = 4 )
    # Set fields for attribute table

    fields = ["Vp","R","H","stdVp","stdR","stdH"]
    w.field("station", 'C', '6')
    w.field("network", 'C', '10')
    w.field("status", 'C', '16')
    #w.field("Vp", "C", "5")
    for field in fields:
        w.field(field, 'C', '5')

    for key in stdict.keys():
        # Set lon & lat
        w.point( stdict[key]["lon"], stdict[key]["lat"] )
        values = []
        for f in fields:
            values.append( '{0:5.2f}'.format(stdict[key][f]) if f in stdict[key] else "None ")
        w.record( key,
                  stdict[key]["network"],
                  stdict[key]["status"],
                  values[0],
                  values[1],
                  values[2],
                  values[3],
                  values[4],
                  values[5] )

    w.save(shpfile)
