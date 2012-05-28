#!/usr/bin/python2

import os, sys

def countLinesOfCode(directory):
    """
    Procedure to count total lines of code in each file
    """
    total = 0
    listing = os.listdir(directory)
    for fname in listing:
        subtotal = 0
        Fname = os.path.join(directory,fname)
        if fname[-2:] == "py" or fname[-1:] == "m" or fname[-2:] == "sh":
            with open(Fname) as f:
                for i, l in enumerate(f):
                    pass
                subtotal = i + 1
            print fname, "line num:", subtotal
            total += subtotal
    print total

if __name__ == "__main__":
    """
    TEST ALL THE THINGS
    """
    if (len(sys.argv) < 2):
        print "Please supply a directory"
        exit()
    
    countLinesOfCode(sys.argv[1])
