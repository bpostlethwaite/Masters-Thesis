#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import numpy as np
import sys, os
from ternarytools import terntransform, baryIntersect
import matplotlib.pyplot as plt

path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../programming/python/python-ternary'))
if not path in sys.path:
    sys.path.insert(1, path)
del path

import ternary as tern

assemblages = [
['Granite Gneiss', np.array([6.208, 0.25])],
['Mafic Granulite', np.array([6.942, 0.283])],
['Gray Gneiss', np.array([6.302, 0.257])],
['quartz', np.array([6.05, 0.08])],
['an29', np.array([6.35, 0.29])],
['bronzite', np.array([7.84, 0.21])],
['perthite', np.array([5.90, 0.28])]
]


regions = [
["Canada",np.array([6.333308436,0.258088786361])],
["Shield",np.array([6.422288412,0.253789492491])],
["ChurchillProvince",np.array([6.386424187,0.25031941449])],
["SlaveProvince",np.array([6.436475844,0.252983892165])],
["GrenvilleProvince",np.array([6.476571768,0.269634678812])],
["SuperiorProvince",np.array([6.439460302,0.252702533063])]
]

endmembers = [x[0] for x in assemblages]
lithdata = [x[1] for x in assemblages]

# Select Assemblage
data = lithdata[3:6]
endmembers = endmembers[3:6]

# Data

plt.figure()
for ind, region in enumerate(regions):

    data = lithdata[3:6]
    data.append(region[1])

    datalabels = ['Vp',r'$\sigma$']
    colors = ['b','g','c','m','r','y']

    lines = terntransform( *data )

    for line, color, label in zip(lines, colors, datalabels):
        tern.plot(line, color = color, linewidth=2.0, label = label if (ind == 0) else None)

    ip = baryIntersect(lines)
    tern.plotIntersect(ip, marker = 'o'+colors[ind], label = region[0])

step = 0.2
tern.gridlines(step, '0.7')
tern.draw_boundary()
tern.addlabels(endmembers)
plt.legend()

    #pyplot.box(on='off')
h = plt.gca()
#plt.axis('off')
xmin = -0.1
xmax = 1.1
ymin = -0.1
ymax = 1
v = [xmin, xmax, ymin, ymax]
plt.axis(v)
h.axes.get_xaxis().set_visible(False)
h.axes.get_yaxis().set_visible(False)


plt.show()
