import os, re, sys
from preprocessor import SeisDataError, renameEvent, is_number
from dbutils import isPoor
from obspy.core import read
import numpy as np

def checkPickTime(f):
    if "poorData" not in f:
        s = read(f)[0]
        t1 = s.stats.sac['t1']
        t3 = s.stats.sac['t3']
        if float(t1) < 0:
            print f, t1, t3

if __name__ == '__main__':
    stns = ["MGTN"] #["EKTN","BOXN","COWN","GBLN","LUPN","MGTN","GLWN","DVKN","MLON","LGSN","ACKN","RSNT","CAMN","YMBN","MCKN","COKN","JERN","NODN","KNDN","HFRN","YNEN","SNPN","LDGN","DSMN","ILKN","YKW1","YKW3","YKW2","YKW5","YKW4","ARTN","IHLN"]

    for stn in stns:

        rootdir = '/media/TerraS/CN'
        stdir = os.path.join(rootdir, stn)
        events = os.listdir(stdir)
        reg2 = re.compile(r'^stack_(\w)\.sac')



        for event in events:
            comps = []
            eventdir = os.path.join(stdir, event)
            files = os.listdir(eventdir)
            for fs in files:
                m = reg2.match(fs)
                if m:
                    checkPickTime( os.path.join(eventdir, fs) )
                    break


