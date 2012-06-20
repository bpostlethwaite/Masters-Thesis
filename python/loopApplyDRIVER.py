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
    networks = ['TEST']
    datadir = '/media/TerraS' 
    d = time.localtime(time.time())
    logname = "/log_{}_{}_{}_{}".format(d.tm_year,d.tm_mon,d.tm_mday,d.tm_hour)
    logfile = open(datadir + logname, 'w')
    eventdict = {}
    ###########################################################################
    #  SET regex matches
    ###########################################################################
    reg1 = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w{2})\.(\w*)\.\.(\w{3}).*')
    reg2 = re.compile(r'^stack_(\w)\.sac')

    ###########################################################################
    # Build a dictionary from file event.list from Request system
    # fields[0] -> event name     fields[2] -> lat
    # fields[3] -> lon            fields[4] -> depth
    # fields[6] -> GCARC
     ###########################################################################
    with open("/home/bpostlet/thesis/shellscripts/requests/event.list", 'r') as f:
        for line in f:
            fields = line.split()
            eventdict[ fields[0] ] = (fields[2], fields[3], fields[4], fields[6])

    ###########################################################################
    #  Walk through Networks supplied above. These are the root folders in 
    #  main directory folder
    ###########################################################################
    for network in networks:
        try:
            logfile.write("operating on network: " + network + "\n")
            print "operating on network:", network
            netdir = os.path.join(datadir,network)
            stations = os.listdir(netdir)
        except OSError as e:
            logfile.write('Problems working in network ' + network + ' --skipping \n')
            print e
            continue

    ###########################################################################
    # Walk through all stations found in network folder
    ###########################################################################
        for station in stations:
            try: 
                logfile.write("operating on station: " + station + "\n")
                print "operating on station:", station
                stdir = os.path.join(netdir,station)
                events = os.listdir(stdir)
            except OSError as e:
                logfile.write("Encountered Error: " + repr(e) + " --Skipping station: " + station + "\n")
                print e
                continue

    ###########################################################################
    # Walk through all events found in station folder
    ###########################################################################
            for event in events:
                if not is_number(event): # Make sure event dir is right format, skip those not in number format
                    logfile.write("Skipping event: " + repr(event))
                    continue
                comps = []
                eventdir = os.path.join(stdir,event)
                files = os.listdir(eventdir)
                for fs in files:
                    try:
                        m1 = reg1.match(fs)
                        comps.append((m1.group(4),fs)) # Save the component extension, see Regex above.
                        #m2 = reg2.match(fs)
                        #comps.append((m2.group(1),fs))
                    except AttributeError as e:
                        #print "No match on file:",fs
                        pass

    ###########################################################################
    # Check if three components have been found
    # If yes, sort alphebetically and call processor function
    ###########################################################################
                if len(comps) != 3:
                    print "Did not register 3 components in directory:", eventdir
                    logfile.write('Error Processing: ' + eventdir +  ' Did not register 3 components\n')
                    renameEvent(eventdir,"MissingComponents")
                    continue
                    # Sort in decending alphabetical, so 'E' is [0] 'N' is [1] and 'Z' is [2]
                    # Pull out sacfiles from zipped sorted list.
                comps.sort()
                _ , sacfiles = zip(*comps)

                # Run Processing function
                try:
                    setHeaders(eventdir, sacfiles, eventdict)
                    detrend_taper_rotate(eventdir, sacfiles)                    
                    #sh("rm {}/*stack*".format(eventdir), shell=True, executable = "/bin/bash")
                except IOError:
                    print "IOError in event:", eventdir
                    logfile.write("Error Processing: " + eventdir + " IOError\n")
                    renameEvent(eventdir,"IOError")
                    continue
                except SeisDataError as e:
                    print e.msg + " in event:", eventdir
                    logfile.write("Error Processing: " + eventdir + ": " + e.msg + "\n")
                    renameEvent(eventdir, e.msg)
                    continue
                except ValueError:
                    print "ValueError in event:", eventdir
                    logfile.write("Error Processing: " + eventdir + " ValueError\n")
                    renameEvent(eventdir,"ValueError")
                    continue
               

                
    logfile.close()
