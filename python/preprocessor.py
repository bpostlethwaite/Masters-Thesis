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
import matplotlib.pyplot as plt
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

class poorDataError(Exception):
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
    PP = None
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
           #  ##### Get slowness P ###########################
        #     process = sh("/home/bpostlet/bin/Get_tt/get_tt -z {} -d {} -p P".format(evdp,gcarc),
        #        shell=True, executable = "/bin/bash", stdout = pipe )
        #     results =  process.communicate()[0].rstrip().split('\n')
        #     for result in results:
        #         result = result.split()
        #         if result[1] == 'P':
        #             slowness = float(result[3])
        #             break
        #         else:
        #             raise NoSlownessError('No_slowness_GARC_is:{}'.format(gcarc))
        
        # st[0].stats.sac['kuser0'] = "P-slow"
        # st[0].stats.sac['user0'] = round(slowness * deg2rkm,4)        
        # st[0].write(ff, format = 'SAC')
    # Get PP time and set in headers ############################################
            process = sh("/home/bpostlet/bin/Get_tt/get_tt -z {} -d {} -p P".format(evdp,gcarc),
               shell=True, executable = "/bin/bash", stdout = pipe )
            results =  process.communicate()[0].rstrip().split('\n')
            for result in results:
                result = result.split()
                if result[1] == 'P':
                    P = float(result[2])
                    break
                else:
                    P = None
                    print "NO P!"
        
        st[0].stats.sac['kt0'] = "P"
        st[0].stats.sac['t0'] = P
        #try:
        st[0].write(ff, format = 'SAC')
        #except Exception:
            #raise IOError
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
    
    # Calculate values to be used in transformations
    dt = ev[1].stats.delta
    pslow = ev[1].stats.sac['user0']
    baz = ev[1].stats.sac['baz']
    PP = ev[1].stats.sac['t7']

    #if ev[1].stats.sac['b'] < (ev[i].stats.sac['t0'] - 50):
    #    begin = ev[1].stats.sac['t0'] - 50 # start seismogram 50 seconds before P arrival.
    #else:
    begin = ev[1].stats.sac['b']

    n1 = round(begin/dt) # Get array number of new beginning
    end = begin + N*dt     
     
    # Here we either a full size taper, or a short taper padded with zeros
    if PP and (PP < end):
        #nend = (PP - begin - 0.5)/dt # Window out 1/2 second before PP
        #ctap = np.append(cosTaper(nend),np.zeros(N-nend + 1))
        ctap = cosTaper(N)
    else:
        ctap = cosTaper(N)
        
    # window, detrend, taper all three components
    for i in range(3):
        ####### TRUNCATE #################
        ev[i].stats.sac['e'] = end
        ev[i].data = ev[i].data[ : N] # truncate
        ####### DETREND #################
        ev[i].data = detrend(ev[i].data) # Detrend all components
        ###### TAPER ###################
        ev[i].data = ev[i].data * ctap
    
    # R, T = rotate(N, E) 
    ev[1].data, ev[0].data = rotate(ev[1].data, ev[0].data,baz)
    # Call freetran and rotate into P and S space
    #ev[1].data, ev[2].data = freetran(
    #    ev[1].data, ev[2].data, pslow, 6.06, 3.5)
    # Save freetran transformed data objects
    #ev[1].write(os.path.join(eventdir,'stack_P.sac'), format='SAC')
    #ev[2].write(os.path.join(eventdir,'stack_S.sac'), format='SAC')
    # save only rotated data
    ev[1].write(os.path.join(eventdir,'stack_R.sac'), format='SAC')
    ev[2].write(os.path.join(eventdir,'stack_Z.sac'), format='SAC')

    

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

def ppicker(eventdir,rname,zname):
    """ Function ppicker is a ginput based arrival picker
    allowing for 3 time picks which are saved in SAC data headers"""
    
    rf = os.path.join(eventdir, rname)
    zf = os.path.join(eventdir, zname)
    rt = read(rf)
    zt = read(zf)
    rt = rt[0]
    zt = zt[0]
    pslow = rt.stats.sac['user0']        
    depth = rt.stats.sac['evdp']
    dt = rt.stats.delta
    N = len(rt.data)
    b = rt.stats.sac['b']        
    t0 = (rt.stats.sac['t0'] - b ) / dt       
    t4 = (rt.stats.sac['t4'] - b ) / dt   
    t7 = (rt.stats.sac['t7'] - b ) / dt
    left = round(t0 - 20/dt)
    right = round(t0 + 240/dt)
    t = np.around(np.arange(-t0*dt,(N - t0)*dt,dt))
    nn = np.arange(0,N)
    p, s = freetran(rt.data,zt.data,pslow,6.06,3.5)

    while True:
    #plt.subplot(2,1,1)
        print "Pick 3 Arrivals on event:", eventdir
        plt.figure( num = None, figsize = (22,6) )
        plt.plot(p, label = 'Pcomp')
        plt.xticks(nn[::200],t[::200])
        plt.title('{} \n P-trace, source depth = {}'.format( eventdir, depth) )
        plt.axvline(x = t0, color = 'y', label = 'gett P')
        plt.axvline(x = t4, color = 'g', label = 'gett pP')
        plt.axvline(x = t7, color = 'r', label = 'gett PP')
        plt.xlim(left, right)
        plt.xlabel('Time \n P arrival is zero seconds')
        plt.legend()
        # GINPUT b1 = add point |  b2 = STOP |  b3 = delete point
        x = plt.ginput(n = 3, timeout = 0, show_clicks = True)
        try:
            T1 = x[0][0]*dt + b
            T2 = x[1][0]*dt + b
            T3 = x[2][0]*dt + b
        except IndexError:
            print "Not all picks made in", eventdir
            print "Please retry the picks"
            continue
        plt.close()

        inp = raw_input("Keep trace? 'y' for yes, 'n' for no, 'r' for redo: ")
        if 'r' in inp:
            continue
        if 'y' in inp:
            rt.stats.sac['t1'] = T1
            rt.stats.sac['t2'] = T2
            rt.stats.sac['t3'] = T3
            rt.write(rf, format='SAC')
            zt.stats.sac['t1'] = T1
            zt.stats.sac['t2'] = T2
            zt.stats.sac['t3'] = T3
            zt.write(zf, format='SAC')
            return
        elif 'n' in inp:
            raise poorDataError('Data was discarded as poor')
    #plt.subplot(2,1,2)
    #plt.plot(s)
    #plt.title('S-trace')
    #plt.show()


