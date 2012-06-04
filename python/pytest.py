#!/usr/bin/python2.7

import matplotlib
matplotlib.__version__ = "1.1.0"
from obspy.core import read
from obspy.signal.rotate import rotate_NE_RT as rotate 
from scipy.signal.signaltools import detrend
from obspy.signal.invsim import cosTaper
import subprocess 
import numpy as np
import os.path, math, sys
import matplotlib.pyplot as plt
from preprocessor import SeisDataError
from loopApplyDRIVER import renameEvent


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

sh = subprocess.Popen
pipe = subprocess.PIPE
N = 16384  #Max length of seismic array, truncate for speed
ev = []

# READ 3 Component SAC files into object array.

files = sh("ls *.SAC | sort", shell=True, stdout = pipe ).communicate()[0].split('\n')
ev = [ (read(f)[0]) for f in files if f ]
    
    
    # Calculate values to be used in transformations
dt = ev[1].stats.delta
pslow = ev[1].stats.sac['user0']
baz = ev[1].stats.sac['baz']
PP = ev[1].stats.sac['t7']

# Begin seismogram 50 seconds before P arrival
b = ev[1].stats.sac['b']
end = b + N*dt
N = len(ev[1].data)
# Here we either a full size taper, or a short taper padded with zeros
if PP and (PP < end):
    nend = (PP - b - 0.5)/dt # Window out 1/2 second before PP
    ctap = np.append(cosTaper(nend),np.zeros(N-nend + 1))
else:
    ctap = cosTaper(N)

# window, detrend, taper all three components

i = 2
    ####### SET NEW INFO #################
ev[i].stats.sac['e'] = end

plt.subplot(311) 
plt.plot(ev[i].data)
####### DETREND #################
ev[i].data = detrend(ev[i].data) 
plt.subplot(312) 
plt.plot(ev[i].data)
####### TAPER #################
ev[i].data = ev[i].data * ctap
plt.subplot(313) 
plt.plot(ev[i].data)

plt.show() 
   
# R, T = rotate(N, E) 
R, T = rotate(ev[1].data, ev[0].data, baz)
# Call freetran and rotate into P and S space
Z = ev[2].data
p, s = freetran(R, Z, pslow, 6.06, 3.5)

N = len(p.data)
depth = ev[0].stats.sac['evdp']
t0 = (ev[0].stats.sac['t0'] - b ) / dt       
t4 = (ev[0].stats.sac['t4'] - b ) / dt   
t7 = (ev[0].stats.sac['t7'] - b ) / dt
left = round(t0 - 120/dt)
right = round(t0 + 220/dt)
t = np.around(np.arange(-t0*dt,(N - t0)*dt,dt))
nn = np.arange(0,N)

# plt.figure( num = None, figsize = (22,6) )
# plt.plot(p, label = 'Pcomp')
# #plt.xticks(nn[::200],t[::200])
# plt.title('Source depth = {}'.format( depth) )
# plt.axvline(x = t0, color = 'y', label = 'gett P')
# plt.axvline(x = t4, color = 'g', label = 'gett pP')
# plt.axvline(x = t7, color = 'r', label = 'gett PP')
# #plt.xlim(left, right)
# plt.xlabel('Time \n P arrival is zero seconds')
# plt.legend()
# plt.show()




