#!/bin/python3
#
# python-mode indent C-c < or C-c >
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save

from obspy.core import read
from scipy.signal.signaltools import detrend
import os, re
import numpy as np
import matplotlib.pyplot as plt


testdir = '/media/TerraS/TEST/'
logfile = open(testdir+'log','w')

reg = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w{2})\.(\w{4})\.\.(\w{3}).*')

files = os.listdir(testdir)

for fs in files:
    if 'EHZ' in fs:
        f = fs
        

#for f in files:
try:
    m1 = reg.match(f)
    comp = m1.group(4)
    ff = testdir + f
    st = read(ff)
    print 'working on component: ' + comp
    tr = st[0]
    hdr = tr.stats.sac
    #for k, v in st[0].stats.sac.items():
    #    print k, ': ', v    
    dt = tr.stats.delta
    data = tr.data
    t = range(len(data))
    p1 = plt
    p1.plot(t, detrend(data - data.mean()) ,t,detrend(data))
    p1.title('mean of data is {}'.format(data.mean()))
    p1.show()
    tr.write('detrendEHZ.SAC', format='SAC')
    
    #tr.plot(color='gray', tick_format='%I:%M %p',
    #        starttime = tr.stats.starttime,
    #        endtime=st[0].stats.starttime + 1000)
except IOError as e:
    print 'Error occured, see log file'
    logfile.write('Error with file: ' + f)
except AttributeError as e:
    print 'No match on file: ', ff

        
logfile.close() 
