#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
###########################################################################
# IMPORTS
###########################################################################
import os, json
import numpy as np
import matplotlib.pyplot as plt
from plotTools import Args, Params


stnfile = os.environ['HOME'] + '/thesis/data/stations.json'
csfile = os.environ['HOME'] + '/thesis/data/csStations.json'


# Load station params
m = Params(stnfile, ["mb::H","mb::Vp", "mb::stdVp"])
arg = Args().stations(["ALE","ALGO","ARVN","BANO","CBRQ","DAWY","DELO","FCC","FFC","HAL","KGNO","KSVO","LMN","MBC","MNT","MOBC","ORIO","PEMO","PGC","PLVO","PMB","PTCO","SJNN","SUNO","ULM ","ULM2","WAPA ","WHY","WSLR ","YKW1","YOSQ"])
m.filter(arg)
m.filter(Args().addQuery("mb::Vp", "gt", "5.5"))

c = Params(csfile, ["H","Vp"])

c.sync(m)

print len(c.stns)

#for i in range(len(c.stns)):
#    print c.stns[i]

stdVp = 2 * m.mb_stdVp # 2 stdError

t = np.arange(len(m.mb_Vp))

figure()
plt.plot(t, m.mb_Vp, '-ob', lw = 4, ms = 12, label = "Bostock (2010) Vp estimate")
plt.errorbar(t, m.mb_Vp, yerr=stdVp, xerr=None, fmt=None, ecolor = 'blue',
             elinewidth = 2, capsize = 7, mew = 2, label = "2 std dev Bootstrap")
plt.plot(t, c.Vp, '-og', lw = 4, ms = 12, label = "Proximal Controlled Source estimate")
plt.title("Controlled source compressional wave velocity comparison", size = 18)
plt.legend()
plt.xticks(t, c.stns, size = 12)
plt.grid(True)


#####
# Show corrlation between H and Vp. Maybe better.
#####
plt.show()
