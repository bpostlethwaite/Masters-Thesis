#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save

###########################################################################
# IMPORTS
###########################################################################

# Build Dictionaries.
leapyrs = ["2000", "2004", "2008", "2012"]
months = [(1,31),(2,28),(3,31),(4,30),(5,31),(6,30),(7,31),(8,31),(9,30),(10,31),(11,30),(12,31)]
monthsleap = [(1,31),(2,29),(3,31),(4,30),(5,31),(6,30),(7,31),(8,31),(9,30),(10,31),(11,30),(12,31)]
yrday = []
yrdayleap = []
day = 0


for month in months:
    for i in range(month[1]):
        yrday.append( ["{:02d}".format(month[0]),"{:02d}".format(i+1)] )
        day += 1

for month in monthsleap:
    for i in range(month[1]):
        yrdayleap.append( ["{:02d}".format(month[0]),"{:02d}".format(i+1)] )
        day += 1

print yrday
