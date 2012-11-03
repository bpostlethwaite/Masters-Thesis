#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save

###########################################################################
# IMPORTS
###########################################################################
import os, re, time, shutil, sys, tty, argparse
from preprocessor import SeisDataError, renameEvent, is_number
from dbutils import isPoor
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

def ppicker(eventdir, pname, sname, repick = False):
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

    # Skip if T1 and T3 are greater than zero. The default is a large negative number
    if repick:
        if float(pt.stats.sac['t1']) > 0 and float(pt.stats.sac['t3']) > 0:
            return 's'

    left = round(t0 - 30/dt)
    right = round(t0 + 140/dt)
    t = np.around(np.arange(-t0*dt, (N - t0)*dt, dt)) # Time axis
    nn = np.arange(0,N)

    get = Getch()

    plt.figure( num = None, figsize = (22,6) )
    plt.plot(p, label = 'Pcomp')
    plt.xticks(nn[::round(5/dt)],t[::round(5/dt)]) # Changed from 200
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
        return 'r'

    plt.close()

    print "Keep trace? 'n' for no, 'r' for redo, 'p' for previous, 's' for skip and any other for yes: "

    inp = get()

    if inp not in ['n','r','p','s']:
        # Assume yes and save
        pt.stats.sac['t1'] = T1
        pt.stats.sac['t3'] = T3
        pt.write(pf, format='SAC')
        st.stats.sac['t1'] = T1
        st.stats.sac['t3'] = T3
        st.write(sf, format='SAC')

    return inp

def isEitherPoorOrNumber(s):
    if isPoor(s) or is_number(s):
        return True
    else:
        return False

if __name__== '__main__' :

    reg2 = re.compile(r'^stack_(\w)\.sac')

    # Create top-level parser
    parser = argparse.ArgumentParser(description = "Pick seismograms with a few options for file control. ")

    parser.add_argument('stndir', nargs = 1, help = "Include full path to station folder to be picked")

    parser.add_argument('-a', '--all', action = 'store_true',
                        help = "selects numeric event folders as well as those marked poorData")

    parser.add_argument('-u','--unpicked', action = 'store_true',
                        help = "select only those events with SAC times identified as unpicked")

    parser.add_argument('-p', '--poor', action = 'store_true',
                        help = 'Picks only folders renamed with the poorData suffix')

    parser.add_argument('-r','--reset', action = 'store_true',
                        help = "unpicks all folders by renaming them back to numeric event folder names")

    args = parser.parse_args()

    # Suck out command line argument for station directory and return list of event folders
    stdir = args.stndir[0]
    events = os.listdir(stdir)

    if args.reset:
         for event in events:
            if "poorData" in event:
                renameEvent( os.path.join(stdir,event), [], True)
         exit()

    if args.all:
        events = filter(isEitherPoororNumber, events)

    if args.poor:
        events = filter(isPoor, events)

    if not args.poor and not args.all:
        events = filter( is_number, events)

    index = 0
    while index < len(events):
        event = events[index]
        print "{}/{} Pick P-coda limits".format(index + 1, len(events) )
        comps = []
        eventdir = os.path.join(stdir, event)
        files = os.listdir(eventdir)
        for fs in files:
            m = reg2.match(fs)
            if m:
                comps.append((m.group(1),fs))

    ###########################################################################
    # Check if three components have been found
    # If yes, sort alphebetically and call picker function
    ###########################################################################
        if (len(comps) != 2):
             print "Did not register 2 components in directory:", eventdir
             index += 1
             continue
         # Sort in decending alphabetical, so 'E' is [0] 'N' is [1] and 'Z' is [2]
         # Pull outn sacfiles from zipped sorted list.
        comps.sort()
        _ , sacfiles = zip(*comps)

        cmd = ppicker(eventdir,sacfiles[0],sacfiles[1], args.unpicked)

    ###########################################################################
    # This is the control switch board. If function returns n, rename folder.
    # If it return a p, go to previous index. If it is an r, redo. Else move
    # forward
    ###########################################################################

        if cmd == 'n':
            events[index] = os.path.basename( renameEvent(eventdir,"poorData") )
            index += 1
        elif cmd == 'p':
            index -= 1
            continue
        elif cmd == 'r':
            continue
        elif cmd == 's':
            index += 1
            continue
        else:
            # If yes, check if dir previously renamed as poorData, if so rename to healthy event dir
            if "poorData" in eventdir:
                events[index] = os.path.basename(renameEvent( eventdir, [], True))
            index += 1
            continue
