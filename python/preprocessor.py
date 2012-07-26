#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save
#
# This program takes piped in station list input (space or newline seperated)
# and an event.list arguement.
#

###########################################################################
# IMPORTS
###########################################################################
import matplotlib
matplotlib.__version__ = "1.1.0"
from obspy.core import read
from obspy.signal.rotate import rotate_NE_RT as rotate
from scipy.signal.signaltools import detrend
from obspy.signal.invsim import cosTaper
import subprocess, sys, os, re, shutil
import numpy as np
import os.path, math
sh = subprocess.Popen
###########################################################################
#  CREATE CUSTOM ERRORS
###########################################################################
class SeisDataError(Exception):
    def __init__(self, value):
        self.msg = value
    def __str__(self):
        return repr(self.msg)

###########################################################################
# HELPER FUNCTIONS
###########################################################################
def renameEvent(eventdir,error, reverse = False):
    if not reverse:
        shutil.move(eventdir,eventdir + "_" + error)
    elif reverse:
        head, tail = os.path.split(eventdir)
        try:
            float(tail[:10])
            shutil.move( eventdir, os.path.join(head,tail[:10]) )
        except ValueError:
            print "Error returning", tail, "into directory", tail[:10]


def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False
    except TypeError:
        return False



###########################################################################
#  SET UTILS, VARS & REFS
###########################################################################
sh = subprocess.Popen
pipe = subprocess.PIPE
earthradius = 6371
deg2rkm = 180/(math.pi * earthradius)

###########################################################################
# SETHEADERS function sets various headers using get_tt & event.list info
###########################################################################
def setHeaders(eventdir, sacfiles, eventdict):
    """CALCULATE_SLOWNESS function takes the great circle arc and the
    depth of the event and adds slowness into the header information
    in user0 and set kuser0 as 'pslow'. It also adds various travel time
    information into the headers."""

    slowness = -12345
    P  = -12345
    PP = -12345
    pP = -12345
    evla, evlo, evdp, gcarcOLD = eventdict[ os.path.basename(eventdir) ]
    st = read( os.path.join(eventdir, sacfiles[0]) )
    stla = st[0].stats.sac['stla']
    stlo = st[0].stats.sac['stlo']
    dt = st[0].stats.delta
    ##### Get BAZ & GCARC #####################
    azim = os.environ["HOME"] + "/thesis/shellscripts/azim"
    try:
        process = sh("{} -s {} {} -e {} {}".format(azim, stlo, stla, evlo, evla),
                     shell=True, executable = "/bin/bash", stdout = pipe )
        result =  process.communicate()[0].rstrip().split('\n')
        gcarc = float( result[0].split(":")[1] )
        baz = float(result[2].split(":")[1] )
    except ValueError as e:
        raise SeisDataError("noAzim")

    ##### Get OLD P  #####################
    process = sh(os.environ["HOME"] + "/bin/Get_tt/get_tt -z {} -d {} -p P".format(evdp,gcarcOLD),
                 shell=True, executable = "/bin/bash", stdout = pipe )
    results =  process.communicate()[0].rstrip().split('\n')
    for result in results:
        result = result.split()
        if result[1] == 'P':
            beginOLD = math.ceil( float(result[2]) ) - 120
            break
        else:
            raise SeisDataError('noPOld')

    ##### Get P & Pslow #####################
    process = sh(os.environ["HOME"] + "/bin/Get_tt/get_tt -z {} -d {} -p P".format(evdp, gcarc),
                 shell=True, executable = "/bin/bash", stdout = pipe )
    results =  process.communicate()[0].rstrip().split('\n')
    for result in results:
        result = result.split()
        if result[1] == 'P':
            slowness = float(result[3])
            P = float(result[2])
            break
        else:
            raise SeisDataError('noPslow')

    ##### Get PP ###########################
    process = sh(os.environ["HOME"] + "/bin/Get_tt/get_tt -z {} -d {} -p PP".format(evdp,gcarc),
                 shell=True, executable = "/bin/bash", stdout = pipe )
    results =  process.communicate()[0].rstrip().split('\n')
    for result in results:
        result = result.split()
        if result:
            if result[1] == 'PP':
                PP = float(result[2])
                break
    ##### Get pP ###########################
    process = sh(os.environ["HOME"] + "/bin/Get_tt/get_tt -z {} -d {} -p pP".format(evdp,gcarc),
                 shell=True, executable = "/bin/bash", stdout = pipe )
    results =  process.communicate()[0].rstrip().split('\n')
    for result in results:
        result = result.split()
        if result:
            if result[1] == 'pP':
                pP = float(result[2])
                break

    ##### CALCULATE BEGINNING AND END #####
    N = 16384
    begin = math.ceil(P) - 60
    if begin < beginOLD:
        begin = beginOLD
    end = begin + N*dt

    ####### SET HEADERS #################
    for sacfile in sacfiles:
        ff = os.path.join(eventdir, sacfile)
        try:
            st = read(ff)
            st[0].stats.sac['evla'] = evla
            st[0].stats.sac['evlo'] = evlo
            st[0].stats.sac['baz'] = baz
            st[0].stats.sac['gcarc'] = gcarc
            st[0].stats.sac['evdp'] = evdp
            st[0].stats.sac['kuser0'] = "P-slow"
            st[0].stats.sac['user0'] = round(slowness * deg2rkm, 4)
            st[0].stats.sac['kt0'] = "P"
            st[0].stats.sac['t0'] = P
            st[0].stats.sac['kt7'] = "PP"
            st[0].stats.sac['t7'] = PP
            st[0].stats.sac['kt4'] = "pP"
            st[0].stats.sac['t4'] = pP
            st[0].stats.sac['kt1'] = "P_beg" # For picking p-coda energy
            st[0].stats.sac['kt3'] = "P_end" # for picking p-coda energy


            ####### TRUNCATE if not truncated############
            if begin != st[0].stats.sac['b']:
                st[0].data = st[0].data[ (begin - beginOLD)/dt
                                         : (end - beginOLD)/dt + 1 ] # truncate
                st[0].stats.sac['b'] = begin
                st[0].stats.sac['e'] = end

            ####### WRITE #################
            st[0].write(ff, format = 'SAC')
        except IOError:
            print "problem reading and writing in setHeaders func"
            raise IOError

###########################################################################
# detrend_taper_rotate function to be imported by program which walks through
# directories and applies this function.
# This does Demean, Detrend, taper, and rotation.
# It expects 3 SAC files in component order: E,N,Z. (passed as tuple)
# It saves the rotated files into eventdir
###########################################################################
def detrend_taper_rotate(eventdir, sacfiles):
    """preprocess performs the demean,detrend,taper and rotation into radial and
    transverse components. It saves these at STACK_R.sac and STACK_T.sac"""

    ev = []
    # READ 3 Component SAC files into object array.
    for i in range(3):
        ff = os.path.join(eventdir, sacfiles[i])
        st = read(ff)
        ev.append(st[0])

    # Calculate values to be used in transformations
    dt = ev[1].stats.delta
    pslow = ev[1].stats.sac['user0']
    baz = ev[1].stats.sac['baz']
    PP = ev[1].stats.sac['t7']
    N = ev[1].stats.npts
    # Begin seismogram 50 seconds before P arrival
    # Here we either a full size taper, or a short taper padded with zeros
    if PP and (PP < ev[1].stats.sac['e'] ):
        nend = (PP - ev[1].stats.sac['b'] - 0.5)/dt # Window out 1/2 second before PP
        ctap = np.append( cosTaper(nend), np.zeros(N-nend + 1) )
    else:
        ctap = cosTaper(N)

    # detrend, taper all three components
    for i in range(3):
        ####### DETREND & TAPER #################
        ev[i].data = detrend(ev[i].data) * ctap

    # R, T = rotate(N, E)
    ev[1].data, ev[0].data = rotate(ev[1].data, ev[0].data, baz)
    # Call freetran and rotate into P and S space
    ev[1].data, ev[2].data = freetran(
        ev[1].data, ev[2].data, pslow, 6.06, 3.5)
    # Save freetran transformed data objects
    ev[1].write(os.path.join(eventdir,'stack_P.sac'), format='SAC')
    ev[2].write(os.path.join(eventdir,'stack_S.sac'), format='SAC')

def freetran(rcomp, zcomp, pslow, alpha, beta):
    """ Function FREETRAN converts radial and vertical component
    displacement seismograms to P and S components assuming
    a given slowness PSLOW, and surface velocities alpha, beta.
    (Using 6.06 and 3.5 for A0 and B0)
    Usage: pcomp, scomp = freetran(rcomp,zcomp,pslow,alpha,beta)
    See: 'Bostock, M. Mantle Stratigraphy and Evolution of the
    Slave Province, 1998' for formulation"""

    alpha2 = alpha*alpha
    beta2 = beta*beta
    p2 = pslow*pslow
    qalpha = math.sqrt(1/alpha2 - p2)
    qbeta = math.sqrt( 1/beta2 - p2)
    vpz = -(1 - 2 * beta2 * p2) / (2 * alpha * qalpha);
    vpr = pslow * beta2 / alpha;
    vsr = (1 - 2 * beta2 * p2)/( 2 * beta * qbeta);
    vsz = pslow * beta;
    trn = np.array([ [-vpr,vpz] , [-vsr,vsz] ]);
    dum = np.dot( trn, np.vstack( (rcomp, zcomp) ) )

    return dum[0,], dum[1,]

if __name__== '__main__' :

###########################################################################
# SET DIRECTORIES, FILES, VARS
###########################################################################
    netdir = '/media/TerraS/CN'

    if len(sys.argv) != 2:
        print "usage: preprocessor.py eventfile"
        exit()
    eventlist = sys.argv[1]
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
    with open(eventlist, 'r') as f:
        for ind, line in enumerate(f):
            if ind == 0:
                stations = line.split()
                continue

            fields = line.split()
            eventdict[ fields[0] ] = (fields[2], fields[3], fields[4], fields[6])

###########################################################################
# Walk through all stations piped into the program
###########################################################################
    stations = sys.stdin.read()
    # Determine if stations being piped in are a newline list or a space delimited list
    # and take the proper action
    for num, line in enumerate(stations):
        pass
    if num > 0:
        stations = stations.split()
    else:
        stations = stations.split('\n')

    for station in stations:
        try:
            stdir = os.path.join(netdir,station)
            events = os.listdir(stdir)
        except OSError as e:
            print e
            continue

###########################################################################
# Walk through all events found in station folder
###########################################################################
        for event in events:
            if not is_number(event): # Make sure event dir is right format, skip those not in number format
                renameEvent( os.path.join(stdir,event) , '', True):
                continue
            else:
                continue

            comps = []
            eventdir = os.path.join(stdir,event)
            files = os.listdir(eventdir)
            for fs in files:
                m1 = reg1.match(fs)
                if m1:
                    comps.append((m1.group(4),fs)) # Save the component extension, see Regex above.

###########################################################################
# Check if three components have been found
# If yes, sort alphebetically and call processor function
###########################################################################
            if len(comps) != 3:
                print "Did not register 3 components in directory:", eventdir
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
                renameEvent(eventdir,"IOError")
                continue
            except SeisDataError as e:
                print e.msg + " in event:", eventdir
                renameEvent(eventdir, e.msg)
                continue
            except ValueError:
                print "ValueError in event:", eventdir
                renameEvent(eventdir,"ValueError")
                continue
