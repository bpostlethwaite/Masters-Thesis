#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;


###########################################################################
# IMPORTS
###########################################################################
import os, re, time, shutil
from loopApplyDRIVER import renameEvent, is_number
from collections import defaultdict

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


class StationStats(object):
    
    def __init__(self, name):
        self.name = name
        self.width = 40

    def setStats(self, totalEvents, goodEvents, missingComps, poorData, match, nomatch, saveableMCs):
        self.totalev = totalEvents
        self.goodEvents = goodEvents
        self.missingComps = missingComps
        self.poorData = poorData
        self.match = match
        self.nomatch = nomatch
        self.saveableMCs = saveableMCs
        self.percentGood = float(self.goodEvents) / float(self.totalev)
        self.poor2good = float(self.poorData) / float(self.goodEvents)

    def printLine(self, stuff):
        spacer = " " * (self.width - 4 - len(stuff))
        print "*  " + stuff + spacer + "*"

    def printStats(self):
        print "*" * self.width 
        self.printLine(self.name)
        self.printLine("Total events: {}".format(self.totalev) )
        self.printLine("Percent useable: {0:2.1%}".format(self.percentGood) )
        self.printLine("Percent poor: {0:2.1%}".format(self.poor2good) )
        self.printLine("Possible Rescuable Comps: {}".format(self.saveableMCs))


if __name__== '__main__' :
    ###########################################################################
    # SET DIRECTORIES, FILES, VARS
    ###########################################################################
    networks = ['CN']
    datadir = '/media/TerraS' 
    
    ###########################################################################
    #  SET regex matches
    ###########################################################################
    reg1 = re.compile(r'^(\d{4})\.(\d{3})\.(\d{2})\.(\d{2})\.(\d{2})\.\d{4}\.(\w{2})\.(\w*)\.\.(\w{3}).*')
    reg2 = re.compile(r'^stack_(\w)\.sac')

    ###########################################################################
    #  Walk through Networks supplied above. These are the root folders in 
    #  main directory folder
    ###########################################################################
    for network in networks:
        try:
            netdir = os.path.join(datadir,network)
            stations = os.listdir(netdir)
        except OSError as e:
            print e
            print "exiting"
            exit()

    ###########################################################################
    # Walk through all stations found in network folder
    ###########################################################################
        for station in stations:
            
            statdict = {}
            fdict = {}
            mfiles = []          
            d = defaultdict(int)
            stdir = os.path.join(netdir,station)
            events = os.listdir(stdir)
            statdict['totalEvents'] = len(events)
            statdict['poorData'] = 0
            statdict['match'] = 0
            statdict['nomatch'] = 0
            statdict['saveableMCs'] = 0
            statdict['goodEvents'] = 0
            statdict['missingComps'] = 0

            for event in events:
                if "poorData" in event:
                    statdict['poorData'] += 1
                if "MissingComponents" not in event:
                    # Build up a list of filenames NOT in MissingComponent folders
                    comps = []
                    eventdir = os.path.join(stdir, event)
                    eventdirclean = eventdir[0:-18]
                    files = os.listdir(eventdir)
                    for f in files:
                        fdict[f] = True
                if is_number(event):
                    statdict['goodEvents'] += 1
            for event in events:
                if "MissingComponents" in event:
                    # Go through list once more, this time with full list of filenames that are
                    # not in missing component folders. Check to see how many of the M.C. files
                    # are unique.
                    statdict['missingComps'] += 1
                    mfiles = os.listdir( os.path.join(stdir,event) )
                    for mf in mfiles:
                        try:
                            if fdict[mf]:
                                statdict['match'] += 1
                        except KeyError:
                            statdict['nomatch'] += 1
                            d[ mf[:32] ] += 1 #Put partial match here and increment counter 

            for key in d:
                if d[key] >= 3:
                    statdict['saveableMCs'] += 1

            stationstat = StationStats(station)
            stationstat.setStats(**statdict)
            stationstat.printStats()

                        
            
    ###########################################################################
    # Empty out all missing component folders into one LostComponent Folder
    ###########################################################################
            #for event in events:
            #    if "MissingComponents" in event:
            #        eventdir = os.path.join(stdir, event)
            #        files = os.listdir(eventdir)
            #        for f in files:
            #            try:
            #                shutil.move( os.path.join(eventdir,f), os.path.join(stdir,"lostcomps") )
            #            except Exception as e:
            #                print e
            #        shutil.rmtree(eventdir)
    ###########################################################################
    # Walk through all events found in station folder
    ###########################################################################
            #for event in events:
            #     if "lostcomps" in event:
            #        comps = []
            #        eventdir = os.path.join(stdir, event)
            #        eventdirclean = eventdir[0:-18]
            #        files = os.listdir(eventdir)
            #        for f in files:
            #            m1 = reg1.match(f)
            #            if m1:
            #                eventfolder = rehashdate(m1)
            #                #comps.append( (eventfolder, f) )
            #                print eventfolder
            #                #if os.path.exists(os.path.join(stdir,eventfolder)):
            #                #    print os.path.join(stdir,eventfolder)
            #     
            #     elif is_number(event):
            #         print event
