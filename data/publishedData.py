import json

data = """ATKO 44 0.46 1.71 0.011
EPLO 41 0.45 1.73 0.015
HSMO 32 0.83 1.76 0.038
KAPO 48 0.62 1.71 0.020
KILO 35 0.45 1.87 0.012
LDIO 41 0.49 1.82 0.021
MALO 37 0.36 1.77 0.024
MUMO 38 0.31 1.74 0.015
NANO 42 0.67 1.75 0.022
OTRO 41 0.81 1.79 0.029
PKLO 37 0.35 1.81 0.012
PNPO 44 0.54 1.69 0.017
RLKO 42 0.32 1.77 0.011
RSPO 34 0.40 1.80 0.015
SILO 38 0.29 1.73 0.011
SUNO 34 0.39 1.79 0.018
VIMO 44 0.66 1.73 0.010
WEMQ 39 0.38 1.72 0.014"""



stnd = {}
for line in data.split("\n"):
    fields = line.split()
    stn = fields[0]
    stnd[stn] = {}
    stnd[stn]["H"] = float(fields[1])
    stnd[stn]["stdH"] = float(fields[2])
    stnd[stn]["R"] = float(fields[3])
    stnd[stn]["stdR"] = float(fields[4])



open("darbyshirePaper.json",'w').write( json.dumps(stnd, sort_keys = True, indent = 2 ))

