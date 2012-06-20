#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Pick a random event directory and compare results
###########################################################################
# IMPORTS
###########################################################################
import matplotlib
matplotlib.__version__ = "1.1.0"
from obspy.core import read
from obspy.signal.invsim import cosTaper
import numpy as np
import scipy.fftpack as fft
from scipy.signal.signaltools import detrend
import random, os, os.path, re
import matplotlib.pyplot as plt
from loopApplyDRIVER import is_number

###########################################################################
# Some variables and stuff
###########################################################################
reOld = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w{2})\.(\w{4})\.\.(\w{3}).*')
reNew = re.compile(r'^stack_(\w)\.sac')
newfs = []
oldfs = []

###########################################################################
# Get random event directory
###########################################################################
checkdir = '/media/TerraS/TEST'
stations = os.listdir(checkdir)
while True:
    station = stations[random.randint(0,len(stations)-1)]
    events = os.listdir(checkdir + '/' + station)
    event = events[random.randint(0,len(events)-1)]
    if not is_number(event): # Make sure event dir is right format, skip those not in number format
        print "skipping event", event
        continue
    eventdir = os.path.join(checkdir,station,event)
    print "Going to compare data in event directory: ", eventdir
###########################################################################
# Read in files
###########################################################################
    files = os.listdir(eventdir)
    comps = []
    for fs in files:
        try:
            m1 = reNew.match(fs)
            comps.append((m1.group(1),fs)) # Save the component extension, see Regex above.
        except AttributeError as e:
            pass
###########################################################################
# Check if three components have been found
# If yes, sort alphebetically and call processor function
###########################################################################
    if len(comps) != 2:
        print "Did not register 2 components in directory:", eventdir
        continue
        # Sort in decending alphabetical, so 'E' is [0] 'N' is [1] and 'Z' is [2]
        # Pull out sacfiles from zipped sorted list.
    comps.sort()
    _ , sacfiles = zip(*comps)

    try:
        pt = read(os.path.join(eventdir,sacfiles[0]))
        pt = pt[0]
        st = read(os.path.join(eventdir,sacfiles[1]))
        st = st[0]
    except IOError:
        print "some error opening SAC files"
        continue

    dt = pt.stats.delta
    b = pt.stats.sac['b']
    N = len(pt.data)
    depth = pt.stats.sac['evdp']
    t0 = (pt.stats.sac['t0'] - b ) / dt       
    t4 = (pt.stats.sac['t4'] - b ) / dt   
    t7 = (pt.stats.sac['t7'] - b ) / dt
    left = round(t0 - 60/dt)
    #right = round(t0 + 220/dt)
    right = len(pt.data)
    t = np.around(np.arange(-t0*dt,(N - t0)*dt,dt))
    nn = np.arange(0,N)

    plt.figure( num = None, figsize = (22,6) )
    plt.subplot(2,1,1)
    plt.plot(pt.data, label = 'Pcomp')
    plt.xticks(nn[::200],t[::200])
    plt.title(station + ": " + event + "\n" + 'P-Trace.  Source depth = {}'.format( depth) )
    plt.axvline(x = t0, color = 'y', label = 'gett P')
    plt.axvline(x = t4, color = 'g', label = 'gett pP')
    plt.axvline(x = t7, color = 'r', label = 'gett PP')
    plt.xlim(left, right)
    plt.xlabel('Time \n P arrival is zero seconds')
    plt.legend()
    plt.subplot(2,1,2)
    plt.plot(st.data)
    plt.title('S-trace')
    plt.xlim(left, right)
    plt.show()

    



