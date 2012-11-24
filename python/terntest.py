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


gran = np.array([6.208, 0.25])
mafc = np.array([6.942, 0.283])
gray = np.array([6.302, 0.257])
vp = np.array([6.316, 0.2585])

a = gran
b = mafc
c = gray
d = vp

endmembers = ('Granite Gneiss', 'Mafic Granulite', 'Gray Gneiss')
datalabels = ['Vp',r'$\sigma$']
colors = ['b','g','c','m','r']
lines = terntransform(a, b, c, d)

step = 0.2



plt.figure()

for line,color,label in zip(lines,colors,datalabels):
    tern.plot(line, color = color, linewidth=2.0, label = label)

ip = baryIntersect(lines)
tern.plotIntersect(ip)

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
