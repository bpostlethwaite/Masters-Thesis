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
#import matplotlib
#matplotlib.__version__ = "1.1.0"
from obspy.core import read
from obspy.signal.rotate import rotate_NE_RT as rotate
from scipy.signal.signaltools import detrend
from obspy.signal.invsim import cosTaper
import subprocess, sys, os, re, shutil
import numpy as np
import os.path, math

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
def renameEvent(eventdir,error, reverse = False, size = 10):
    if not reverse:
        newname = eventdir + "_" + error
        shutil.move(eventdir, newname)
    elif reverse:
        head, tail = os.path.split(eventdir)
        try:
            float(tail[:size])
            newname = os.path.join(head,tail[:size])
            shutil.move( eventdir, newname )
        except ValueError:
            print "Error returning", tail, "into directory", tail[:size]
            newname = eventdir
    return newname

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

def rotate(eventdir, sacfiles):
    """preprocess performs the demean,detrend,taper and rotation into radial and
    transverse components. It saves these at STACK_R.sac and STACK_T.sac"""

    ev = []
    # READ 3 Component SAC files into object array.
    for i in range(2):
        ff = os.path.join(eventdir, sacfiles[i])
        try:
            st = read(ff)
        except Exception:
            raise SeisDataError('ReadSacError')
        ev.append(st[0])

    # Calculate values to be used in transformations
    if ev[1].stats.sac['t3'] < 0:
        return SeisDataError('t3 not picked')
    dt = ev[1].stats.delta
    pslow = ev[1].stats.sac['user0']
    baz = ev[1].stats.sac['baz']
    PP = ev[1].stats.sac['t5']
    N = ev[1].stats.npts
    # Begin seismogram 60 seconds before P arrival
####### TRUNCATE if not truncated############


    # Here we either a full size taper, or a short taper padded with zeros
    if PP and (PP < ev[1].stats.sac['e'] ):
        nend = (PP - ev[1].stats.sac['b'] - 0.5)/dt # Window out 1/2 second before PP
        ctap = np.append( cosTaper(nend), np.zeros(N-nend + 1) )
    else:
        ctap = cosTaper(N)

    # detrend, taper all three components

    # Call freetran and rotate into P and S space
    ev[0].data, ev[1].data = freetran(
        ev[0].data, ev[1].data, pslow, 6.45, 3.64)
    # Save freetran transformed data objects
    ev[0].write(os.path.join(eventdir,'stack_P.sac'), format='SAC')
    ev[1].write(os.path.join(eventdir,'stack_S.sac'), format='SAC')

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

###########################################################################
#  SET regex matches
###########################################################################
#    reg1 = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w*)\.(\w{2}[R|Z])\.(\w{3}).*')
    reg1 = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w*)\.(\w{3}.?)\.(\w{3}).*')
    reg2 = re.compile(r'^STACK_([R|Z])\.\w{3}')
    reg3 = re.compile(r'^(\w{2}[R|Z])')
    for station in ['BBB', 'CBB', 'FNBC', 'MBC', 'MOBC', 'OZB', 'PGC', 'PHC', 'PMB', 'RSNT', 'SHB', 'ULM2']:
        try:
            stdir = os.path.join(netdir,station)
            events = os.listdir(stdir)
        except OSError as e:
            print e
            continue
#########n##################################################################
# Walk through all events found in station folder
###########################################################################
        for event in events:
            if not is_number(event): # Make sure event dir is right format, skip those not in number format
                #renameEvent( os.path.join(stdir, event), '', True, 8)
                continue
            #else:
             #   continue
            comps = []
            eventdir = os.path.join(stdir,event)
            files = os.listdir(eventdir)
            for fs in files:
                m1 = reg1.match(fs)
                if m1:
                    if m1.group(4).upper() == "SAC" and reg3.match(m1.group(3)):
                        comps.append((m1.group(3),fs)) # Save the component extension, see Regex above.
                    if reg3.match(m1.group(4)):
                        comps.append((m1.group(4),fs)) # Save the component extension, see Regex above.
###########################################################################
# Check if three components have been found
# If yes, sort alphebetically and call processor function
###########################################################################
            if len(comps) != 2:
                comps = []
                for fs in files:
                    m2 = reg2.match(fs)
                    if m2:
                         comps.append((m2.group(1),fs)) # Save the component extension, see Regex above.

            if len(comps) != 2:
                print files
                print "Did not register 2 components in directory:", eventdir
                #renameEvent(eventdir,"MissingComponents")
                continue
                # Sort in decending alphabetical, so 'E' is [0] 'N' is [1] and 'Z' is [2]
                # Pull out sacfiles from zipped sorted list.
            comps.sort()
            _ , sacfiles = zip(*comps)
            #print sacfiles
            # Run Processing function
            try:

                rotate(eventdir, sacfiles)
            #     #sh("rm {}/*stack*".format(eventdir), shell=True, executable = "/bin/bash")
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
