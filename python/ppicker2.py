#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save

###########################################################################
# IMPORTS
###########################################################################

from ppicker import ppicker, Getch
from preprocessor import SeisDataError, renameEvent, is_number
import re, os

if __name__== '__main__' :

    reg2 = re.compile(r'^stack_(\w)\.sac')

    events = open("depthPoorEvent.list",'r').read().split('\n')


    index = 0

    while index < len(events):
        event = events[index]
        print "{}/{} {}".format(index + 1, len(events), event )
        comps = []
        try:
            files = os.listdir(event)
        except OSError:
            print "skipping", event
            index += 1
            continue
        for fs in files:
            m = reg2.match(fs)
            if m:
                comps.append((m.group(1),fs))

    ###########################################################################
    # Check if three components have been found
    # If yes, sort alphebetically and call picker function
    ###########################################################################
        if (len(comps) != 2):
             print "Did not register 2 components in directory:", event
             index += 1
             continue
         # Sort in decending alphabetical, so 'E' is [0] 'N' is [1] and 'Z' is [2]
         # Pull outn sacfiles from zipped sorted list.
        comps.sort()
        _ , sacfiles = zip(*comps)

        cmd = ppicker(event,sacfiles[0],sacfiles[1], False)

    ###########################################################################
    # This is the control switch board. If function returns n, rename folder.
    # If it return a p, go to previous index. If it is an r, redo. Else move
    # forward
    ###########################################################################

        if cmd == 'n':
            events[index] = os.path.basename( renameEvent(event,"poorData") )
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
            if "poorData" in event:
                events[index] = os.path.basename(renameEvent( event, [], True))
            index += 1
            continue
