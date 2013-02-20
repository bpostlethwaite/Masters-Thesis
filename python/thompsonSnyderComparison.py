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
from scipy.stats import pearsonr, spearmanr


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
Hsnyd = []
H = []
stdH = []
stdHsnyd = []
Rchili = []
Rjapan = []
stns = []
for stn in snyd.keys():
    if ("hk" in stdict[stn]) and ("c0R" in stdict[stn]["hk"]):
        stns.append(stn)
        Rsnyd.append(float(snyd[stn]['R']))
        R.append(float(stdict[stn]["hk"]["R"]))
        Hsnyd.append(float(snyd[stn]['H']))
        H.append(float(stdict[stn]["hk"]["H"]))
        stdHsnyd.append(float(snyd[stn]['stdH']))
        stdH.append(float(stdict[stn]["hk"]["stdH"]))
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
stdH = np.array(stdH)
stdHsnyd = np.array(stdHsnyd)
H = np.array(H)
Hsnyd = np.array(Hsnyd)
stns = np.array(stns)
Rchili = np.array(Rchili)
Rjapan = np.array(Rjapan)

ind = (R > 1.8) | (Rsnyd > 1.8)
R = R[~ind]
Rjapan = Rjapan[~ind]
Rchili = Rchili[~ind]
Rsnyd = Rsnyd[~ind]
H = H[~ind]
Hsnyd = Hsnyd[~ind]
stdH = stdH[~ind]
stdHsnyd = stdHsnyd[~ind]
stdR = stdR[~ind]
stdRsnyd = stdRsnyd[~ind]
stns = stns[~ind]

corr = pearsonr(R, Rsnyd)
print "Correlation between Vp/Vs datasets is {0:.2f}".format(corr[0])

t = np.arange(len(R))

#######################
# Plotting formatter
#######################
width = 10
height = width / 1.9
ratio = 1.5
lw = 4 / ratio# line width
ms = 12 / ratio# marker size
caplen = 7 / ratio
capwid = 2 / ratio
elw = 2 / ratio
ticks = 16 / ratio
label = 16 / ratio
title = 18 / ratio
leg = 16 / ratio

plt.figure(figsize = (width, height))
ax = plt.subplot(111)
plt.plot(t, R, '-ob', lw = lw, ms = ms, label = "Vp/Vs estimate -  current data set")
plt.plot(t, Rsnyd, '-og', lw = lw, ms = ms, label = "Vp/Vs estimate Thompson et al.")
# plt.plot(t, Rjapan, '*',  ms = ms, color = 'orange',  label = "Vp/Vs estimate Japan Source Region")
# plt.plot(t, Rchili, '*',  ms = ms, color = 'yellow', label = "Vp/Vs estimate Chili Source Region")
plt.errorbar(t, R, yerr=stdR, xerr=None, fmt=None, ecolor = 'blue',
             elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std error")
plt.errorbar(t, Rsnyd, yerr=stdRsnyd, xerr=None, fmt=None, ecolor = 'green',
             elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std error")
plt.legend(prop={'size': leg})
# plt.title("Comparison for given Canadian Shield Stations - " +
#           "Thompson et al (2010) data.\n" +
#           "Correlation: {0:2.3f}".format(corr[0]),
#           size = title)
plt.xticks(t,stns, size = ticks)
for tick in ax.xaxis.get_major_ticks():
                tick.label.set_fontsize( ticks )
                # specify integer or one of preset strings, e.g.
                #tick.label.set_fontsize('x-small')
                tick.label.set_rotation('vertical')
plt.yticks(size = ticks)
plt.ylabel('Vp/Vs', size = label)
plt.grid(True)
plt.axis("tight")



plt.figure(figsize = (width, height))
ax = plt.subplot(111)

corr = pearsonr(H, Hsnyd)
print "Correlation between H datasets is {0:.2f}".format(corr[0])

plt.plot(t, H, '-ob', lw = lw, ms = ms, label = "H estimate -  current data set")
plt.plot(t, Hsnyd, '-og', lw = lw, ms = ms, label = "H estimate Thompson et al.")
plt.errorbar(t, H, yerr = stdH, xerr=None, fmt=None, ecolor = 'blue',
             elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std error")
plt.errorbar(t, Hsnyd, yerr = stdHsnyd, xerr=None, fmt=None, ecolor = 'green',
             elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std error")
plt.legend(prop={'size': leg})
# plt.title("Comparison for given Canadian Shield Stations - " +
#           "Thompson et al (2010) data.\n" +
#           "Correlation: {0:2.3f}".format(corr[0]),
#           size = title)
plt.xticks(t,stns, size = ticks)
for tick in ax.xaxis.get_major_ticks():
                tick.label.set_fontsize( ticks )
                # specify integer or one of preset strings, e.g.
                #tick.label.set_fontsize('x-small')
                tick.label.set_rotation('vertical')
plt.yticks(size = ticks)
plt.ylabel('Vp/Vs', size = label)
plt.grid(True)
plt.axis("tight")


plt.show()
