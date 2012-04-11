#!/bin/python
# preprawdata takes directory of raw seismograms and
# 1) Seperates into seperate station and event directories
# 2) Loops through event folders and performs:
#     a)detrend b)demean c)taper d)rotate e)rename

import os, os.path, re, shutil, sys

#############################################################
# Seperate Data into Event Folders                          #
#############################################################
# Directories
basedir = '/media/TerraS'
rawdatadir = os.path.join(basedir,'BEN')

# Define Matching criteria
reg = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w{2})\.(\w{4})\.\.(\w{3}).*')
files = os.listdir(rawdatadir)
nfiles = len(files)
count = 0
for d in files:
    try:
        count += 1
        m1 = reg.match(d)
        fullfile = os.path.join(rawdatadir,d)
        date = m1.group(1).split('.')
        network = m1.group(2)
        station = m1.group(3)
        event =  date[0][2:4]+date[1]+date[2]
        try:
            ndir = os.path.join(basedir, network, station, event)
            if not os.path.exists(ndir):
                os.makedirs(ndir)
            shutil.copy(fullfile, ndir + '/' + d)
            sys.stdout.write('copied  [%d%%]\r' %(count*100/nfiles))
            sys.stdout.flush()
        except AttributeError:
            print 'problem copying file: ', d
        
    except AttributeError:
        print 'could not make match on: ', d


