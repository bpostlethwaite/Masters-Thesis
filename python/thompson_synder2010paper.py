#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

# Program to build station objects from state stored
# in JSON format.
# Functions to build station database from files
# and functions to add stats, add matlab data etc.

###########################################################################
# IMPORTS
###########################################################################
import json, os, math
import numpy as np
import matplotlib.pyplot as plt

dbfile = os.environ['HOME'] + '/thesis/data/stations.json'
stdict = json.loads( open(dbfile).read() )
data = open(os.environ['HOME'] + '/thesis/data/ThompsonSnyder2010Paper.data')

snyd = {}
for line in data:
    fields = line.rstrip().split()
    stn = fields[0]
    snyd[stn] = {}
    snyd[stn]['H'] = fields[9]
    snyd[stn]['stdH'] = fields[10]
    snyd[stn]['R'] = fields[11]
    snyd[stn]['stdR'] = fields[12]

data.close()
Rsnyd = []
R = []
stdR = []
stdRsnyd = []
stns = []
for stn in snyd.keys():
    if "hk" in stdict[stn]:
        stns.append(stn)
        Rsnyd.append(float(snyd[stn]['R']))
        R.append(float(stdict[stn]["hk"]["R"]))
        stdRsnyd.append(float(snyd[stn]['stdR']))
        stdR.append(float(stdict[stn]["hk"]["stdR"]))
        diff =  float(snyd[stn]['R']) - float(stdict[stn]["hk"]["R"])
        #print diff

#    if (math.fabs(diff) > float(stdict[stn]["hk"]["stdR"])):
#        print stn, float(snyd[stn]['R']), float(stdict[stn]["hk"]["R"]), diff > float(snyd[stn]['stdR']) , diff > float(stdict[stn]["hk"]["stdR"])


R = np.array(R)
Rsnyd = np.array(Rsnyd)
stdR = np.array(stdR)
stdRsnyd = np.array(stdRsnyd)
stns = np.array(stns)

ind = (R > 1.8) | (Rsnyd > 1.8)
R = R[~ind]
Rsnyd = Rsnyd[~ind]
stdR = stdR[~ind]
stdRsnyd = stdRsnyd[~ind]
stns = stns[~ind]

print np.mean(R), np.mean(Rsnyd)

t = np.arange(len(R))
plt.plot(t, R, '-o', lw = 4, ms = 12, label = "Vp/Vs estimate - Ben P. - ours")
plt.plot(t, Rsnyd, '-o', lw = 4, ms = 12, label = "Vp/Vs estimate Snyder et al.")
plt.errorbar(t, R, yerr=stdR, xerr=None, fmt=None,
             elinewidth = 2, capsize = 6, capthick = 4, label = "1 std dev BP")
plt.errorbar(t, Rsnyd, yerr=stdRsnyd, xerr=None, fmt=None,
             elinewidth = 2, capsize = 6, capthick = 4, label = "1 std error Eaton et. al. 2006")
plt.legend()
plt.title("Comparison for given Can. Shield Stations\n" +
          "between Thompson, Snyder, Eaton et al (2010) and our Current Data",
          size = 18)
plt.xticks(t,stns, size = 14)
plt.ylabel('Vp/Vs', size = 16)
plt.grid(True)
plt.show()
