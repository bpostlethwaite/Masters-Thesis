import json, os
import numpy as np

moonvpGeoChron = os.environ['HOME'] + "/thesis/data/moonvpGeoChron.json"
j = json.loads(open(moonvpGeoChron).read())


keys = j.keys()

archH = []
archV = []
protH = []
protV = []

for key in keys:

    print j[key]["period"]

    if "archean" in j[key]["period"]:
        archH.append(j[key]["H"])
        archV.append(j[key]["Vp"])

    else:
        if "proterozoic" in j[key]["period"]:
            protH.append(j[key]["H"])
            protV.append(j[key]["Vp"])

print "arch Vp", np.mean(archV)
print "arch H",  np.mean(archH)
print "prot Vp", np.mean(protV)
print "prot H", np.mean(protH)
