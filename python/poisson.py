#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################

import re, sys
from histplots import poisson



if __name__== '__main__' :

    reverse = False

    if len(sys.argv) > 1:
        if sys.argv[1] == '-r':
            reverse = True

    numbers = sys.stdin.read().split()

    numbers = map(float, numbers)

    for n in numbers:
        print poisson(n, reverse)


