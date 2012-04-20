#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save

###########################################################################
# IMPORTS
###########################################################################
import os, re
from preprocessor import calculate_slowness, detrend_taper_rotate, NoSlownessError

###########################################################################
# SET DIRECTORIES, FILES
###########################################################################
# networks = ['CN','NE','X5']
networks = ['TEST']
datadir = '/media/TerraS' 
logfile = open(datadir + '/log', 'w')

###########################################################################
#  SET regex matches
###########################################################################
reg = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w{2})\.(\w{4})\.\.(\w{3}).*')

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
            logfile.write("Encountered Error: " + repr(e) + " --Skipping \n")
            print e
            continue

###########################################################################
# Walk through all events found in station folder
###########################################################################
        for event in events:
            comps = []
            eventdir = os.path.join(stdir,event)
            files = os.listdir(eventdir)
            for fs in files:
                try:
                    m1 = reg.match(fs)
                    comps.append((m1.group(4),fs)) # Save the component extension, see Regex above.
                except AttributeError as e:
                    #print "No match on file:",fs
                    pass

###########################################################################
# Check if three components have been found
# If yes, sort alphebetically and call processor function
###########################################################################
            if len(comps) != 3:
                print "Did not register 3 components in directory:", eventdir
                logfile.write(eventdir + ": Did not register 3 components --skipping\n")

                # Sort in decending alphabetical, so 'E' is [0] 'N' is [1] and 'Z' is [2]
                # Pull out sacfiles from zipped sorted list.
            comps.sort()
            _ , sacfiles = zip(*comps)

            # Run Processing function
            try:
                calculate_slowness(eventdir, sacfiles)
                #print "successfully added slowness to headers in event:", event
                #detrend_taper_rotate(eventdir, sacfiles)
                #print "successfully processed event:", eventdir
            except IOError as e:
                print "error processing: "
                logfile.write('Error Processing: ' + eventdir + "\n")
            except NoSlownessError:
                print "did not find a good slowness in event folder:", eventdir


logfile.close()
