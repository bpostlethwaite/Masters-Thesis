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
from preprocessor import calculate_slowness, detrend_taper_rotate, NoSlownessError, ppicker
from preprocessor import poorDataError
from obspy.core import read
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
    # SET DIRECTORIES, FILES
    ###########################################################################
    # networks = ['CN','NE','X5']
    networks = ['X5']
    datadir = '/media/TerraS' 
    d = time.localtime(time.time())
    logname = "/log_{}_{}_{}_{}".format(d.tm_year,d.tm_mon,d.tm_mday,d.tm_hour)
    logfile = open(datadir + logname, 'w')

    ###########################################################################
    #  SET regex matches
    ###########################################################################
    reg1 = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w{2})\.(\w{4})\.\.(\w{3}).*')
    reg2 = re.compile(r'^stack_(\w)\.sac')
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
                        #m1 = reg1.match(fs)
                        #comps.append((m1.group(4),fs)) # Save the component extension, see Regex above.
                        m2 = reg2.match(fs)
                        comps.append((m2.group(1),fs))
                    except AttributeError as e:
                        #print "No match on file:",fs
                        pass

    ###########################################################################
    # Check if three components have been found
    # If yes, sort alphebetically and call processor function
    ###########################################################################
                if len(comps) != 2:
                    print "Did not register 2 components in directory:", eventdir
                    logfile.write('Error Processing: ' + eventdir +  ' Did not register 3 components\n')
                    continue
                    # Sort in decending alphabetical, so 'E' is [0] 'N' is [1] and 'Z' is [2]
                    # Pull out sacfiles from zipped sorted list.
                comps.sort()
                _ , sacfiles = zip(*comps)

                # Run Processing function
                try:
                # calculate_slowness(eventdir, sacfiles)
                    ppicker(eventdir,sacfiles[0],sacfiles[1])
                    rf = os.path.join(eventdir, sacfiles[0])
                    zf = os.path.join(eventdir, sacfiles[1])
                    rt = read(rf)
                    zt = read(zf)
                    rt = rt[0]
                    zt = zt[0]
                    print rt.stats.sac['t0']
                    print rt.stats.sac['t1']        
                    print rt.stats.sac['t2']
                    print rt.stats.sac['t3']
                    print zt.stats.sac['t2']
                    print zt.stats.sac['t2']
                    print zt.stats.sac['t2']
#detrend_taper_rotate(eventdir, sacfiles)
                    #sh("rm {}/*stack*".format(eventdir), shell=True, executable = "/bin/bash")
                #except IOError:
                    #print "IOERROR in event:", eventdir
                    #logfile.write("Error Processing: " + eventdir + " IOError\n")
                    #renameEvent(eventdir,"IOERROR")
                    #continue
                #except NoSlownessError, err:
                    #print err.parameter
                    #logfile.write('Error Processing: ' + eventdir + err.parameter + "\n")
                    #renameEvent(eventdir,err.parameter)
                    #continue
                #except ValueError:
                    #print "ValueError in event:", eventdir
                    #logfile.write("Error Processing: " + eventdir + " ValueError\n")
                    #renameEvent(eventdir,"ValueError")
                    #continue
                except poorDataError:
                    renameEvent(eventdir,"PoorData")
                    continue
    logfile.close()
