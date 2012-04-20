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
from preprocessor import calculate_slowness, detrend_taper_rotate, NoSlownessError


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
comps = []

###########################################################################
# Checking processing function on random directories:
###########################################################################
for f in fs:
    try:
        m1 = reOld.match(f)
        comps.append((m1.group(4),f)) # Save the component extension, see Regex above.
    except AttributeError as e:
        print "No match on file:",f
if len(comps) != 3:
    print "Did not register 3 components in directory:", eventdir
    # Sort in decending alphabetical, so 'E' is [0] 'N' is [1] and 'Z' is [2]
    # Pull out sacfiles from zipped sorted list.
comps.sort()
_ , sacfiles = zip(*comps)
try:
    calculate_slowness(eventdir, sacfiles)
except NoSlownessError:
    print "did not find a good slowness in event folder:", eventdir
#detrend_taper_rotate(eventdir,sacfiles)




# for f in fs:
#     try:
#         m1 = reOld.match(f)
#         if m1 is not None:
#             oldfs.append(eventdir + '/' + m1.group(0))
#         m2 = reNew.match(f)
#         if m2 is not None:
#             newfs.append(eventdir + '/' + m2.group(0))
#         #comps.append((m1.group(4),fs)) # Save the component extension, see Regex above.
#     except AttributeError:
#         pass

# trOld = []
# trNew = []

# for f in sorted(oldfs):
#     st = read(f)
#     st[0].data = detrend(st[0].data)
#     ctap = cosTaper(len(st[0].data))
#     st[0].data = st[0].data * ctap
#     trOld.append(st[0]) 
    
# for f in sorted(oldfs):
#     st = read(f)
#     trNew.append(st[0]) 

# # Plot and compare
# N = len(trNew[1].data)
# t = range(N)
# dt = trNew[0].stats.delta

 
#plt.subplot(2,1,1)
#
#plt.title('Frequency comparison')
#plt.subplot(2,1,2)
#
#plt.show()




