#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save

###########################################################################
# IMPORTS
###########################################################################
import os, re, time, shutil
from preprocessor import setHeaders, detrend_taper_rotate, SeisDataError
import subprocess
sh = subprocess.Popen
###########################################################################
# HELPER FUNCTIONS
###########################################################################
def renameEvent(eventdir,error):
    shutil.move(eventdir,eventdir + "_" + error)
    
def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False
    except TypeError:
        return False

if __name__== '__main__' :
    ###########################################################################
    # SET DIRECTORIES, FILES, VARS
    ###########################################################################
    networks = ['CN']
    datadir = '/media/TerraS' 
    
    ###########################################################################
    #  SET regex matches
    ###########################################################################
    reg1 = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w{2})\.(\w*)\.\.(\w{3}).*')
    reg2 = re.compile(r'^stack_(\w)\.sac')

    ###########################################################################
    #  Walk through Networks supplied above. These are the root folders in 
    #  main directory folder
    ###########################################################################
    for network in networks:
        try:
            print "operating on network:", network
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
            try: 
                print "operating on station:", station
                stdir = os.path.join(netdir,station)
                events = os.listdir(stdir)
            except OSError as e:
                print e
                print "exiting"
                exit()

    ###########################################################################
    # Walk through all events found in station folder
    ###########################################################################
            for event in events:
                if "MissingComponents" in event:
                    comps = []
                    eventdir = os.path.join(stdir, event)
                    eventdirclean = eventdir[0:-18]
                    files = os.listdir(eventdir)
                    for f in files:
                        m1 = reg1.match(f)
                        if m1:
                            comps.append( (m1.group(4), f) )
                    
                    print eventdir, len(comps)
                    
