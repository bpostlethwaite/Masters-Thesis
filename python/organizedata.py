#!/usr/bin/python2
# preprawdata takes directory of raw seismograms and
# 1) Seperates into seperate station and event directories
# 2) Loops through event folders and performs:
#     a)detrend b)demean c)taper d)rotate e)rename

import os, os.path, re, shutil, sys
#from obspy.core import read
#############################################################
# Seperate Data into Event Folders                          #
#############################################################
# Directories
basedir = '/media/TerraS'
rawdatadir = os.path.join(basedir,'BEN')


# Following is for renaming event dirs based on the sac file name format.
# Build Dictionaries.
leapyrs = ["2000", "2004", "2008", "2012"]
months = [(1,31),(2,28),(3,31),(4,30),(5,31),(6,30),(7,31),(8,31),(9,30),(10,31),(11,30),(12,31)]
monthsleap = [(1,31),(2,29),(3,31),(4,30),(5,31),(6,30),(7,31),(8,31),(9,30),(10,31),(11,30),(12,31)]
yrdays = []
yrdaysleap = []
day = 0

for month in months:
    for i in range(month[1]):
        yrdays.append( ["{:02d}".format(month[0]),"{:02d}".format(i+1)] )
        day += 1

for month in monthsleap:
    for i in range(month[1]):
        yrdaysleap.append( ["{:02d}".format(month[0]),"{:02d}".format(i+1)] )
        day += 1

def rehashdate(match):
    yr = match.group(1)
    yrday = match.group(2)
    hour = match.group(3)
    minute = match.group(4)

    if yr in leapyrs:
        month = yrdaysleap[int(yrday)-1][0]
        day = yrdaysleap[int(yrday)-1][1]
    else:
        month = yrdays[int(yrday)-1][0]
        day = yrdays[int(yrday)-1][1]
    return yr[2:4]+month+day+hour+minute


# Define Matching criteria
reg = re.compile(r'^(\d{4})\.(\d{3})\.(\d{2})\.(\d{2})\.(\d{2})\.\d{4}\.(\w{2})\.(\w{4})\.\.(\w{3}).*')
files = os.listdir(rawdatadir)
nfiles = len(files)
count = 0
evd = {}

for d in files:
    try:
        m1 = reg.match(d)
        fullfile = os.path.join(rawdatadir,d)
        date = m1.group(1).split('.')
        station = m1.group(7)
        event =  rehashdate(m1)
        ndir = os.path.join(basedir, "CN", station, event)
        # Problem is that the different components have slightly different
        # event times. So we have to check only up to the hour, not minute.
        # Then move into the right folder.
        # If truncated entry has not made it into dictionary,
        # create one, and add full entry.
        # If it is, use the full ndir from previous similar event name.
        if ndir[:-2] not in evd:
            evd[ndir[:-2]] = ndir
        try:
            if not os.path.exists(evd[ndir[:-2]]):
                os.makedirs( evd[ndir[:-2]] )

            count += 1
            shutil.copy( fullfile, evd[ndir[:-2]] )
            sys.stdout.write('copied  [%d%%]\r' %(count*100/nfiles))
            sys.stdout.flush()
        except AttributeError:
            print 'problem copying file: ', d


    except AttributeError:
        print 'could not make match on: ', d


### GET STATION INFO FROM DATA

# date = 1
# net = 2
# stn = 3
# comp = 4
# d = {}

# ss = set(['SHWN', 'NOTN', 'ELEF', 'CTSN', 'HOWN', 'VTIN', 'MNGN', 'PNGN', 'SHMN', 'KIMN', 'DORN', 'EA06', 'CRLN', 'MANN', 'ARTN'])

# for event in events:
#     m = reg.match(event)
#     if m.group(stn) in ss:
#         s = read(os.path.join(davedir, event))
#         d[ m.group(stn) ] = {
#             "network" : s[0].stats.network,
#             "lat" : float(s[0].stats.sac['stla']),
#             "lon" : float(s[0].stats.sac['stlo']),
#             "start" : float(0.),
#             "stop" : float(0.),
#             "status": "not aquired"
#             }

#         ss.remove(m.group(stn))

# stdict = json.loads( open(dbfile).read() )
# stdict.update(d)
#print json.dumps(stdict, sort_keys = True, indent = 4 )
#open(dbfile,'w').write( json.dumps(stdict, sort_keys = True, indent = 2))

