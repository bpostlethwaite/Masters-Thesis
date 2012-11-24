#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import numpy as np
from itertools import combinations

def terntransform(av, bv, cv, dv):
    """[ A, B, C ] = terntransform(a, b, c, d)
    Turns ternary plot end member values and a given data value
    into percentage locations for plotting with ternplot."""

    lines = []
    ptA = np.zeros(2)
    ptB = np.zeros(2)

    for ii in range(len(dv)):
        a = av[ii]
        b = bv[ii]
        c = cv[ii]
        d = dv[ii]
        count = 0
        # Find endpoint on Triangle
        if (d <= np.max([a,c])) & (d >= np.min([a,c])):
            ptA[count] = np.fabs( (d - c) / (a - c) )
            ptB[count] = 0
            count += 1

        if (d <= np.max([a,b])) & (d >= np.min([a,b])):
            ptA[count] = 1 - np.fabs( (d - a) / (a - b) )
            ptB[count] = np.fabs( (d - a) / (a - b) )
            count += 1

        if (d <= np.max([b,c])) & (d >= np.min([b,c])):
            ptA[count] = 0
            ptB[count] = np.fabs( ( d - c) / (b - c) )
            count += 1

        if count != 2:
            continue

        lines.append( [
            [ptA[0], ptB[0], 1 - ptA[0] - ptB[0]],
            [ptA[1], ptB[1], 1 - ptA[1] - ptB[1]]
            ])

    return lines


def perp( a ) :
    b = np.empty_like(a)
    b[0] = -a[1]
    b[1] = a[0]
    return b

def cartIntersect(line1, line2) :
    a1, a2 = line1
    b1, b2 = line2
    da = a2-a1
    db = b2-b1
    dp = a1-b1
    dap = perp(da)
    denom = np.dot( dap, db)
    num = np.dot( dap, dp )
    return (num / denom)*db + b1


def bary2cart(baryline):
    a, b, c = baryline
    return np.array([ (2*b+c) / (2 * (a+b+c))  ,  np.sqrt(3) * c / (2 * (a+b+c)) ])

def cart2bary(coord):
    T = [
        [-0.5     , 0.5],
        [-np.sqrt(3.0)/2.0, -np.sqrt(3.)/2.]
        ]
    b = np.zeros(3)
    coord -= np.array([0.5, np.sqrt(3.) / 2.])
    b[0:2] = np.linalg.solve(T, coord)
    b[2] = 1 - b[0] - b[1]
    return b

def baryIntersect(blines):
    """ Get all intersections of list of lines """
    ip = []
    if type(blines) is list:
        for l in combinations(blines, 2):
            l1 = np.array([bary2cart(l[0][0]), bary2cart( l[0][1] )])
            l2 = np.array([bary2cart(l[1][0]),bary2cart( l[1][1] )])
            b = cart2bary( cartIntersect(l1, l2) )
            if isInside(b):
                ip.append(b)

    return ip

def isInside(b):
    return (
        (0 <= b[0] <= 1) &
        (0 <= b[1] <= 1) &
        (0 <= b[2] <= 1)
        )
