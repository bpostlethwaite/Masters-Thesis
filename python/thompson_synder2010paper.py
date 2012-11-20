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
Rchili = []
Rjapan = []
stns = []
for stn in snyd.keys():
    if "hk" in stdict[stn]:
        stns.append(stn)
        Rsnyd.append(float(snyd[stn]['R']))
        R.append(float(stdict[stn]["hk"]["R"]))
        stdRsnyd.append(float(snyd[stn]['stdR']))
        stdR.append( 2 * float(stdict[stn]["hk"]["stdR"]) )
        Rjapan.append(float(stdict[stn]["hk"]['c0R']))
        Rchili.append(float(stdict[stn]["hk"]["c1R"]) )
        diff =  float(snyd[stn]['R']) - float(stdict[stn]["hk"]["R"])
        #print diff

#    if (math.fabs(diff) > float(stdict[stn]["hk"]["stdR"])):
#        print stn, float(snyd[stn]['R']), float(stdict[stn]["hk"]["R"]), diff > float(snyd[stn]['stdR']) , diff > float(stdict[stn]["hk"]["stdR"])


R = np.array(R)
Rsnyd = np.array(Rsnyd)
stdR = np.array(stdR)
stdRsnyd = np.array(stdRsnyd)
stns = np.array(stns)
Rchili = np.array(Rchili)
Rjapan = np.array(Rjapan)

ind = (R > 1.8) | (Rsnyd > 1.8)
R = R[~ind]
Rjapan = Rjapan[~ind]
Rchili = Rchili[~ind]
Rsnyd = Rsnyd[~ind]
stdR = stdR[~ind]
stdRsnyd = stdRsnyd[~ind]
stns = stns[~ind]

print np.mean(R), np.mean(Rsnyd)
print len(Rchili), len(Rjapan), len(R)

t = np.arange(len(R))
plt.plot(t, R, '-ob', lw = 4, ms = 12, label = "Vp/Vs estimate -  current data set")
plt.plot(t, Rsnyd, '-og', lw = 4, ms = 12, label = "Vp/Vs estimate Thompson et al.")
plt.plot(t, Rjapan, '*',  ms = 13, color = 'orange',  label = "Vp/Vs estimate Japan Source Region")
plt.plot(t, Rchili, '*',  ms = 13, color = 'yellow', label = "Vp/Vs estimate Chili Source Region")
plt.errorbar(t, R, yerr=stdR, xerr=None, fmt=None, ecolor = 'blue',
             elinewidth = 2, capsize = 7, mew = 2, label = "2 std dev Bootstrap")
plt.errorbar(t, Rsnyd, yerr=stdRsnyd, xerr=None, fmt=None, ecolor = 'green',
             elinewidth = 2, capsize = 7, mew = 2, label = "1 std error Eaton et. al. 2006")
plt.legend()
plt.title("Comparison for given Can. Shield Stations\n" +
          "between Thompson, Helffrich, Snyder, Eaton et al (2010) and our Current Data.\n" +
          "Including source region filtered estimates",
          size = 18)
plt.xticks(t,stns, size = 12)
plt.ylabel('Vp/Vs', size = 16)
plt.grid(True)
plt.show()
