#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save

###########################################################################
# IMPORTS
###########################################################################

import re, sys


if __name__== '__main__' :


    numbers = sys.stdin.read().split()
    numbers = map(float, numbers)
    print sum(numbers)/len(numbers)


