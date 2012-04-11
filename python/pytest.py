#!/bin/python

import sys, time
nfiles = 100
for count in range(nfiles):
    #print type(count/nfiles)
    time.sleep(0.01)
    sys.stdout.write('copied  [%d%%]\r' %(count*100/nfiles))
    sys.stdout.flush()
