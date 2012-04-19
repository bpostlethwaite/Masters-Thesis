#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Pick a random event directory and compare results
###########################################################################
# IMPORTS
###########################################################################
from obspy.core import read
from obspy.signal.invsim import cosTaper
import numpy as np
import scipy.fftpack as fft
from scipy.signal.signaltools import detrend
import random, os, os.path, re
import matplotlib.pyplot as plt

###########################################################################
# Get random event directory
###########################################################################
checkdir = '/media/TerraS/TEST'
stations = os.listdir(checkdir)
station = stations[random.randint(0,len(stations)-1)]
events = os.listdir(checkdir + '/' + station)
event = events[random.randint(0,len(events)-1)]
eventdir = os.path.join(checkdir,station,event)
print "Going to compare data in event directory: ", eventdir
###########################################################################
# Read in files
###########################################################################
reOld = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w{2})\.(\w{4})\.\.(\w{3}).*')
reNew = re.compile(r'^STACK_(\w)\.sac')
fs = os.listdir(eventdir)
newfs = []
oldfs = []

for f in fs:
    try:
        m1 = reOld.match(f)
        if m1 is not None:
            oldfs.append(eventdir + '/' + m1.group(0))
        m2 = reNew.match(f)
        if m2 is not None:
            newfs.append(eventdir + '/' + m2.group(0))
        #comps.append((m1.group(4),fs)) # Save the component extension, see Regex above.
    except AttributeError:
        pass

trOld = []
trNew = []

for f in sorted(oldfs):
    st = read(f)
    st[0].data = detrend(st[0].data)
    ctap = cosTaper(len(st[0].data))
    st[0].data = st[0].data * ctap
    trOld.append(st[0]) 
    
for f in sorted(oldfs):
    st = read(f)
    trNew.append(st[0]) 

# Plot and compare
N = len(trNew[1].data)
t = range(N)
dt = trNew[0].stats.delta
fbin = fft.fftfreq(N, d = dt)
 
plt.subplot(2,1,1)
plt.plot(fbin, np.fft.fft(trNew[0].data))
plt.title('Frequency comparison')
plt.subplot(2,1,2)
plt.plot(fbin, np.fft.fft(trOld[1].data))
plt.show()




