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
import numpy as np


if __name__== '__main__' :

    numbers = re.findall(r'\d+.\d+', sys.stdin.read() )
    numbers = map(float, numbers)

    print np.mean(numbers)
