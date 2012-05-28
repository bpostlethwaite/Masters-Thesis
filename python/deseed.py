#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
from obspy.core import read
import subprocess
import os, os.path

sh = subprocess.Popen
pipe = subprocess.PIPE

