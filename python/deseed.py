#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
#
# Program for deseeding and moving files into proper directory
#
#
###########################################################################
# IMPORTS
###########################################################################

import os, os.path, re, shutil, sys
import subprocess
from time import sleep

sh = subprocess.Popen
pipe = subprocess.PIPE
rdseed = "/home/bpostlet/thesis/shellscripts/rdseedv5.2/rdseed -df"

#############################################################
# Seperate Data into Event Folders                          #
#############################################################
# Directories
baseDir = '/media/TerraS/CN'
seedDir = '/tmp/seed'
deseedDir = '/tmp/deseed/'

if not os.path.exists(seedDir):
    os.makedirs(seedDir)
if not os.path.exists(deseedDir):
    os.makedirs(deseedDir)

os.chdir(deseedDir)

# Define Matching criteria
reg = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w{2})\.(\w*)\.\.(\w{3}).*')

count = 0
seedfiles = os.listdir(seedDir)
nfiles = len(seedfiles)

if seedfiles:
    for s in seedfiles:

        count += 1
        event = s[:-5]
        s2 = os.path.join(deseedDir, s)
        shutil.copyfile( os.path.join(seedDir, s), s2)
        subprocess.check_call(rdseed + " " + s2, shell=True, stdout = pipe)
        os.unlink(s2) # remove seedfile.
        sacfiles = os.listdir(deseedDir)

        for f in sacfiles:
            m1 = reg.match(f)
            if m1:
                station = m1.group(3)                      
                evDir = os.path.join(baseDir, station, event)
                if not os.path.exists(evDir):
                    os.makedirs(evDir)
                shutil.move( os.path.join(deseedDir, f), os.path.join(evDir, f) )
            

        left = os.listdir(deseedDir)
        if len(left) != 0:
            print "remaining files, abort"
            exit()

        #sys.stdout.write('deseeded  [%d%%]\r' %(count*100/nfiles))
        sys.stdout.write(event+"\n")
        sys.stdout.flush()


    
    


