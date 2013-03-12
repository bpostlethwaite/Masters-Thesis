import json

data = """ACTO 40.5 0.9 1.77 0.04
ALFO 37.0 0.5 1.80 0.02
ALGO 43.0 0.5 1.81 0.02
BANO 40.0 0.4 1.74 0.01
BRCO 45.0 0.4 1.78 0.01
BUKO 40.5 1.0 1.77 0.03
CBRQ 34.5 0.9 1.73 0.05
CLPO 39.0 0.6 1.76 0.02
CLWO 42.5 1.7 1.79 0.06
DELO 39.0 0.5 1.78 0.01
ELGO 43.0 1.4 1.74 0.04
HGVO 40.9 0.5 1.77 0.01
KGNO 40.1 0.4 1.83 0.01
KLBO 43.5 0.9 1.85 0.03
KSVO 36.5 1.0 1.80 0.05
LINO 39.0 0.4 1.73 0.01
MEDO 41.9 0.5 1.75 0.01
MPPO 40.5 0.9 1.73 0.03
MRHQ 38.2 1.3 1.72 0.05
PECO 44.0 0.5 1.74 0.01
PEMO 37.9 0.5 1.74 0.02
PKRO 40.0 0.5 1.73 0.01
PLIO 52.4 1.7 1.73 0.07
PLVO 38.6 1.0 1.77 0.04
PTCO 43.5 1.0 1.74 0.02
RSPO 36.5 1.0 1.74 0.04
SADO 38.0 0.5 1.74 0.01
STCO 43.0 0.5 1.72 0.01
SUNO 36.0 0.5 1.69 0.02
TOBO 39.5 0.9 1.75 0.02
TYNO 40.5 0.9 1.79 0.03
WLVO 40.5 0.8 1.73 0.02"""



stnd = {}
for line in data.split("\n"):
    fields = line.split()
    stn = fields[0]
    stnd[stn] = {}
    stnd[stn]["H"] = float(fields[1])
    stnd[stn]["stdH"] = float(fields[2])
    stnd[stn]["R"] = float(fields[3])
    stnd[stn]["stdR"] = float(fields[4])



open("eatonPaper.json",'w').write( json.dumps(stnd, sort_keys = True, indent = 2 ))

