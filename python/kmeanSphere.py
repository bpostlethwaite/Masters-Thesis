#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
# Note Scipy detrend is same as doing a remove mean and then detrend
# Detrend demean taper rotate rename save

# This performs the kmeans clustering algorithm on
# SAC data in a given station folder. The program opens
# Each folder and picks out a sac


###########################################################################
# IMPORTS
###########################################################################
import os, re, time, shutil, sys
from loopApplyDRIVER import renameEvent, is_number
from collections import defaultdict
import numpy as np
from math import cos, acos, pi, sin, atan2, sqrt
import matplotlib.pyplot as plt
from obspy.core import read
import scipy.io
from random import randint
from mpl_toolkits.basemap import Basemap

def vectorize(latlon):
    ''' Takes lat and long and spits out 3D vects'''
    vects = np.zeros( (len(latlon), 3) )
    rads = latlon * pi / 180      #convert to radians
    for ind, obs in enumerate(rads):
        vects[ind] = [cos(obs[0]) * cos(obs[1]) ,
                      cos(obs[0]) * sin(obs[1]) ,
                      sin(obs[0]) ]
    return vects

def assignVect2Cluster(vects, clusters):
   '''This calculates distances between vects and array of clusters
   producing an array of distances, each row for obs and each col
   for particular cluster, than we choose index of min dist'''
   members = np.dot(vects, clusters.T).argmin(axis = 1)            
   return members

def moveClusters(vects, clusters, members):
    ''' selects the vects belonging into a cluster, sums along the
    the components and divides by length to get mean vect component
    and sets the cluster at this new mean'''
    for ind in range( len(clusters) ):
        clusters[ind] = vects[members == ind].sum(axis = 0) / len(vects)
    return clusters
    
def devectorize(vects):
    latlon = np.zeros( (len(vects) , 2) )
    for ind, v in enumerate(vects):
        latlon[ind] = [ atan2( v[2], sqrt( v[0]**2 + v[1]**2) ) ,
                   atan2( v[1], v[0] ) ] 
    return latlon * 180/pi

        
if __name__== '__main__' :

    reg2 = re.compile(r'^stack_(\w)\.sac')
    stdir = "/media/TerraS/CN/ULM"
    
    events = os.listdir(stdir)
    events = filter(is_number,events)

    data = np.zeros( (len(events), 2) )

    for ind, event in enumerate(events):
        files = os.listdir( os.path.join(stdir, event) )
        for fs in files:
            if reg2.match(fs):
                st = read( os.path.join(stdir, event, fs) )
                evla = float(st[0].stats.sac['evla'])
                evlo = float(st[0].stats.sac['evlo'])
                data[ind] = [ evla, evlo ]
                continue

    # Default to two clusters, one around japan the other
    # around Chile.
    clusterlatlon = np.array( [ [35 , 135 ],
                                [35, -71] ] )
                               
    vects = vectorize(data)
    clusters = vectorize(clusterlatlon)

    for i in range(5):
        members = assignVect2Cluster(vects, clusters)
        clusters = moveClusters(vects, clusters, members)
        cls = devectorize(clusters)

    bmap = Basemap(projection = 'robin', lon_0 = -80)
    bmap.fillcontinents(color = '#cc9966', lake_color = '#99ffff')
    bmap.drawmapboundary(fill_color='0.3')
    bmap.drawparallels(np.arange(-90.,120.,30.))
    bmap.drawmeridians(np.arange(0.,420.,60.))
    x1, y1 = bmap( data[:,1], data[:,0] )
    x2, y2 = bmap( cls[:,1], cls[:,0] )
    print cls 
    print x2, y2

    clr = ['g','b','r','k','m']
    for i in range( len(clusterlatlon) ):
        bmap.scatter(x1[members == i], y1[members == i], c = clr[i], marker = '.')

    plt.show()


# Need to save all the membership into SAC files.
