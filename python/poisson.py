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

    if len(sys.argv) == 2:
        if sys.argv[1] == '-r':
            reverse = True
        else:
            numbers = [sys.argv[1]]

    if len(sys.argv) == 3:
        if sys.argv[1] == '-r':
            reverse = True
        numbers = [sys.argv[2]]

    if sys.stdin.isatty():
        pass
    else:
        # trick to get all floats out of list
        numbers =  re.findall(r'[-+]?[0-9]*\.?[0-9]+', sys.stdin.read() )

    numbers = map(float, numbers)

    for n in numbers:
        print poisson(n, reverse)


