#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
###########################################################################
# IMPORTS
###########################################################################
import os, sys, re, shutil


reg = re.compile(r'^(\d{4}\.\d{3}\.\d{2}\.\d{2}\.\d{2})\.\d{4}\.(\w{2})\.(\w*)\.\.(\w{3}).*')
os.walk


ddir = "/media/TerraS/CN/GAC"

evdirs = os.listdir(ddir)

for e in evdirs:n
    ed = os.path.join(ddir, e)
    fs = os.listdir(ed)
    if len(fs) < 3:
        shutil.rmtree(ed)
        continue
    for f in fs:
        m = reg.match(f)
        if m:
            if m.group(4)[0] == "E":
                fd = os.path.join(ed, f)
                os.remove(fd)
                #
    if len(e) > 10:
        os.rename(ed, os.path.join(ddir, e[0:10]))
