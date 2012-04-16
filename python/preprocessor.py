#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save

from obspy.core import read
from obspy.signal.rotate import rotate_NE_RT as rotate 
from scipy.signal.signaltools import detrend
from obspy.signal.invsim import cosTaper

import os, re
import numpy as np
import matplotlib.pyplot as plt


homedir = os.getenv('HOME')
testdir = os.path.join(homedir,'programming/matlab/thesis/testdata')
logfile = open(testdir+'log','w')

reg = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w{2})\.(\w{4})\.\.(\w{3}).*')

events = sorted(os.listdir(testdir))
eventdir = testdir + '/' + events[0]

files = os.listdir(eventdir)
comps = [] # Set up a list to hold component fname tuple
ev = [] # An event list of component objects

for fs in files:
    try:
        m1 = reg.match(fs)
        comps.append((m1.group(4),fs)) # Get the last letter of component, N E or Z
    except AttributeError as e:
        print "No match on file:",fs

comps.sort()
assert len(comps) == 3

for i in range(3):
    try:
    # READ 3 Component SAC files into object array.
        ff = eventdir + '/' + comps[i][1]
        st =  read(ff)
        ev.append(st[0]) 
    except IOError as e:
        print 'Error occured, see log file'
        print e
        logfile.write('Error with file: ' + f)

# Detrend and taper
for i in range(3):
    ev[i].data = detrend(ev[i].data) # Detrend all components
    print 'mean of component', comps[i][0], 'is', np.mean(ev[i].data)    
    ctap = cosTaper(len(ev[i].data))
    ev[i].data = ev[i].data * ctap

# Rotate to r and t
baz = ev[0].stats.sac['baz']
# Note N -> R  and  E -> T
ev[1].data, _ = rotate(ev[1].data,ev[0].data,baz)


# Save transformed data objects
ev[1].write(eventdir + '\STACK_R.sac', format='SAC')
ev[2].write(eventdir + '\STACK_Z.sac', format='SAC')

# # READ NEW DATA BACK
# st = read(detrff)
# tr2 = st[0]

# Plot and compare:
t = range(len(ev[1].data))

plt.subplot(2,1,1)
plt.plot(t, ev[1].data, t, ev[0].data)
plt.title('north & east vs radial & transverse')
plt.subplot(2,1,2)
plt.plot(t,t)
plt.show()


        
logfile.close() 





