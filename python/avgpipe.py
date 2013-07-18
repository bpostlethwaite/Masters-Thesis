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

    numbers = re.findall(r'\d+', sys.stdin.read() )
    numbers = map(int, numbers)

    sortn = [numbers.pop()]
    while numbers:
        hit = False
        n = numbers.pop()
        for i, ns in enumerate(sortn):
            if n < ns:
                sortn.insert(ind, n)
                hit = True
        if not hit:
            sortn.append(n)
