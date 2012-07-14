#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save

###########################################################################
# IMPORTS
###########################################################################
import os, re, time, shutil, sys, tty
from preprocessor import SeisDataError, renameEvent, is_number
import matplotlib.pyplot as plt
from obspy.core import read
import numpy as np

class Getch:
    def __init__(self):
        import tty, sys

    def __call__(self):
        import sys, tty, termios
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(sys.stdin.fileno())
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch

def ppicker(eventdir,pname,sname,repick = False):
    """ Function ppicker is a ginput based arrival picker
    allowing for 3 time picks which are saved in SAC data headers"""

    pf = os.path.join(eventdir, pname)
    sf = os.path.join(eventdir, sname)
    pt = read(pf)[0]
    st = read(sf)[0]
    p, s = (pt.data, st.data)

    dt = pt.stats.delta
    N = len(pt.data)
    b = pt.stats.sac['b']
    depth = pt.stats.sac['evdp']
    t0 = (pt.stats.sac['t0'] - b ) / dt
    t4 = (pt.stats.sac['t4'] - b ) / dt
    t7 = (pt.stats.sac['t7'] - b ) / dt
    left = round(t0 - 20/dt)
    right = round(t0 + 140/dt)
    t = np.around(np.arange(-t0*dt,(N - t0)*dt,dt))
    nn = np.arange(0,N)

    get = Getch()

    if repick:
        if float(pt.stats.sac['t1']) > 0 or float(pt.stats.sac['t3']) > 0:
            return


    while True:

        plt.figure( num = None, figsize = (22,6) )
        plt.plot(p, label = 'Pcomp')
        plt.xticks(nn[::200],t[::200])
        plt.title('{} \n P-trace, source depth = {}'.format( eventdir, depth) )
        plt.axvline(x = t0, color = 'y', label = 'gett P')
        plt.axvline(x = t4, color = 'g', label = 'gett pP')

        if t7 < right:
            plt.axvline(x = t7, color = 'r', label = 'gett PP')

        plt.xlim(left, right)
        plt.xlabel('Time \n P arrival is zero seconds')
        plt.legend()
        x = plt.ginput(n = 2, timeout = 0, show_clicks = True)

        try:
            T1 = x[0][0]*dt + b
            T3 = x[1][0]*dt + b

        except IndexError:
            print "Not all picks made in", eventdir
            print "Please retry the picks"
            continue

        plt.close()

        print "Keep trace? 'n' for no, 'r' for redo, any other for yes: "
        inp = get()

        if 'r' in inp:
            continue

        elif 'n' in inp:
            raise SeisDataError('poorData')

        else:
            pt.stats.sac['t1'] = T1
            pt.stats.sac['t3'] = T3
            pt.write(pf, format='SAC')
            st.stats.sac['t1'] = T1
            st.stats.sac['t3'] = T3
            st.write(sf, format='SAC')
            return


if __name__== '__main__' :

    repick = False
    count = 1
    reg2 = re.compile(r'^stack_(\w)\.sac')

    if (len(sys.argv) < 2):
        print "Send a absolute Station directory and optional flag"
        exit()

    elif (len(sys.argv) > 2):
        flag = sys.argv[1]
        stdir = sys.argv[2]

        if flag in "-r":
            repick = True

        elif flag in "-u":
            events = os.listdir(stdir)
            for event in events:
                if "poorData" in event:
                    renameEvent( os.path.join(stdir,event), [], True)
            exit()

        else:
            print "unsupported flag option. Use -r to repick only unpicked seismograms, or -u to unpick entire directory"
            exit()

    else:
        stdir = sys.argv[1]

    events = os.listdir(stdir)
    events = filter(is_number,events)

    for event in events:
        print "{}/{} Pick P-coda limits".format(count, len(events) )
        if not is_number(event): # Make sure event dir is right format, skip those not in number format
            continue
        comps = []
        eventdir = os.path.join(stdir,event)
        files = os.listdir(eventdir)
        for fs in files:
            m = reg2.match(fs)
            if m:
                comps.append((m.group(1),fs))

    ###########################################################################
    # Check if three components have been found
    # If yes, sopt alphebetically and call processor function
    ###########################################################################
        if (len(comps) != 2):
             print "Did not register 2 components in directory:", eventdir
             renameEvent(eventdir,"MissingComponents")
             continue
         # Sort in decending alphabetical, so 'E' is [0] 'N' is [1] and 'Z' is [2]
         # Pull outn sacfiles from zipped sorted list.
        comps.sort()
        _ , sacfiles = zip(*comps)

        try:
            count += 1
            ppicker(eventdir,sacfiles[0],sacfiles[1], repick)
        except SeisDataError as e:
            renameEvent(eventdir, e.msg)
            continue
