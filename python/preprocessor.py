#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save

###########################################################################
# IMPORTS
###########################################################################
from obspy.core import read
from obspy.signal.rotate import rotate_NE_RT as rotate 
from scipy.signal.signaltools import detrend
from obspy.signal.invsim import cosTaper
import subprocess 
import numpy as np
import os.path, math

###########################################################################
#  CREATE CUSTOM ERRORS
###########################################################################
class NoSlownessError(Exception):
    def __init__(self, value):
        self.parameter = value
        def __str__(self):
            return repr(self.parameter)

###########################################################################
#  SET UTILS, VARS & REFS
###########################################################################
sh = subprocess.Popen
pipe = subprocess.PIPE
earthradius = 6371
deg2rkm = 180/(math.pi * earthradius)
###########################################################################
# CALCULATE_SLOWNESS function takes the great circle arc and the
# depth of the event and adds slowness into the header information
# in user0 and set kuser0 as "pslow"
###########################################################################
def calculate_slowness(eventdir, sacfiles):
    """CALCULATE_SLOWNESS function takes the great circle arc and the
    depth of the event and adds slowness into the header information
    in user0 and set kuser0 as 'pslow' """

    slowness = None
    # READ 3 Component SAC files into object array.
    for i in range(3):
        ff = os.path.join(eventdir, sacfiles[i])
        try:
            st = read(ff)
        except Exception, err:
            raise IOError
        if i == 0:
            evdp = st[0].stats.sac['evdp']
            gcarc = st[0].stats.sac['gcarc']
            # Get slowness P
            process = sh("/home/bpostlet/bin/Get_tt/get_tt -z {} -d {} -p P".format(evdp,gcarc),
               shell=True, executable = "/bin/bash", stdout = pipe )
            results =  process.communicate()[0].rstrip().split('\n')
            for result in results:
                result = result.split()
                if result[1] == 'P':
                    slowness = float(result[3])
                    break
                else:
                    raise NoSlownessError('No_slowness_GARC_is:{}'.format(gcarc))
            # Get PP time and set in headers
            process = sh("/home/bpostlet/bin/Get_tt/get_tt -z {} -d {} -p P".format(evdp,gcarc),
               shell=True, executable = "/bin/bash", stdout = pipe )
            results =  process.communicate()[0].rstrip().split('\n')
            for result in results:
                result = result.split()
                if result[1] == 'P':
                    slowness = float(result[3])
                    break
                else:
                    raise NoSlownessError('No_slowness_GARC_is:{}'.format(gcarc))
        st[0].stats.sac['kuser0'] = "P-slow"
        st[0].stats.sac['user0'] = round(slowness * deg2rkm,4)
        st[0].write(ff, format = 'SAC')
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
    
    N = 16384  #Max length of seismic array, truncate for speed
    ev = []
    
    # READ 3 Component SAC files into object array.
    for i in range(3):
        ff = os.path.join(eventdir, sacfiles[i])
        st = read(ff)
        ev.append(st[0]) 
    
    dt = ev[1].stats.delta
    pslow = ev[1].stats.sac['user0']

    # window, detrend, taper all three components
    for i in range(3):
        ev[i].stats.sac['b'] = ev[i].stats.sac['t0'] - 70 # start seismogram 70 seconds before P arrival, adjust beginning time in header.
        n1 = round(ev[i].stats.sac['b']/dt) # Get array number of new beginning
        ev[i].data = ev[i].data[n1:n1+N] # truncate from 70s before pick to
        ev[i].data = detrend(ev[i].data) # Detrend all components
        ctap = cosTaper(16384)
        ev[i].data = ev[i].data * ctap

    # Rotate to E and N to R and T
    baz = ev[0].stats.sac['baz']
    # Note R, T = rotate(N, E) 
    ev[1].data, ev[0].data = rotate(ev[1].data, ev[0].data,baz)
    # Call freetran and rotate into P and S space
    ev[1].data, ev[2].data = freetran(
        ev[1].data, ev[2].data, pslow, 6.06, 3.5)
    # Save transformed data objects
    ev[1].write(os.path.join(eventdir,'STACK_P.sac'), format='SAC')
    ev[2].write(os.path.join(eventdir,'STACK_S.sac'), format='SAC')

    

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
    qbeta = sqrt( 1/beta2 - p2)
    vpz = -(1 - 2 * beta2 * p2) / (2 * alpha * qalpha);
    vpr = pslow * beta2 / alpha;
    vsr = (1 - 2 * beta2 * p2)/( 2 * beta * qbeta);
    vsz = pslow * beta;
    trn = np.array([ [-vpr,vpz] , [-vsr,vsz] ]);
    dum = np.dot( trn, np.vstack( (Ur, Ut) ) )
    
    return dum[0,], dum[1,]

