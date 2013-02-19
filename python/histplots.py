#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import sys, os, json, copy
#from dbutils import queryStats, getStats
from plotTools import Args, Params
import matplotlib.pyplot as plt
import numpy as np
from scipy.signal import detrend
from scipy.stats import pearsonr, norm
#from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.mlab as mlab
from ternarytools import terntransform, baryIntersect
import ternplots as tern

stnfile = os.environ['HOME'] + '/thesis/data/stations.json'
moonfile = os.environ['HOME'] + '/thesis/data/moonvpGeology.json'
vfile = os.environ['HOME'] + '/thesis/data/voronoi.data'

parameterType = 'thickness'

def poisson(R, reverse = False):
    ''' Function to go from Vp/Vs -> Poisson's ratio '''
    if reverse:
        return np.sqrt( 1 / (1 - 2 * R) + 1)
    else:
        return 0.5 * ( 1 - 1 / (R**2 - 1) )


def addtext(data, ax, n, arclen):
    if type(data) is not list:
        data = [data]
    for ii, v in enumerate(data):
        txt = "{:0.3f}".format(v)
        ax.annotate(txt, xy = (v , 0.85 * max(n)) if ii else (v , 0.7 * max(n)),  xycoords='data', size = 16,
                     xytext=(-200 - ii*50, 10), textcoords='offset points',
                     arrowprops=dict(arrowstyle="->",lw = 3,
                                     connectionstyle="arc3,rad=0.2"))

def distfunc(data, bins, n = None):
    """ Distribution curve of histogram with some
    added optional scaling """
    (mu, sigma) = norm.fit(data)
    # add a 'best fit' line
    y = mlab.normpdf( bins, mu, sigma)
    if n != None:
        y *= np.max(n) / np.max(y)
    return y

def plotlines(plt, data, pt):
    h = []
    label = pt.avglabel
    if pt.dbtype == 'moon' and not pt.H:
        gran = 6.208
        biot = 6.302
        mafc = 6.942
    elif pt.dbtype == 'kan' and not pt.H:
        gran = 0.250
        biot = 0.257
        mafc = 0.283
    elif pt.H:
        pass
    else:
        raise Exception("Unknown type in plotlines!")
    h.append(plt.axvline(x = data, linewidth = 4, color = 'r', label = label))
    if not pt.H:
        h.append(plt.axvline(x = gran, linewidth = 4, color = '0.7', label = "granite gneiss: " + str(gran)))
        h.append(plt.axvline(x = biot, linewidth = 4, color = '0.5', label = "tonalite gneiss: " + str(biot)))
        h.append(plt.axvline(x = mafc, linewidth = 4, color = '0.3', label = "mafic gneiss: " + str(mafc)))
    return h

def formatplot(plt, ax, legendsize, pt):
    if pt.title:
        plt.title(pt.title, size = 22)
    if pt.xlabel:
        plt.xlabel(pt.xlabel, size = 16)
    plt.ylabel("# of Data", size = 16)
    if legendsize:
        plt.legend(prop={'size':legendsize})
    plt.grid(True)

    for tick in ax.xaxis.get_major_ticks():
        tick.label.set_fontsize(14)


def plottern(plt, alpha, vp):
    gran = np.array([6.208, 0.25])
    mafc = np.array([6.942, 0.283])
    gray = np.array([6.302, 0.257])
    vp = np.array([vp, alpha])

    a = gran
    b = mafc
    c = gray
    d = vp

    endmembers = ('Granite Gneiss', 'Mafic Granulite', 'Gray Gneiss')
    datalabels = ['Vp',r'$\sigma$']
    colors = ['b','g','c','m','r']
    lines = terntransform(a, b, c, d)

    step = 0.2

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


def getdata(dtype, d, m, vdict, vdictregion):
    # Poisson Ratio bar control
    pnmin = 0.22
    pnmax = 0.30
    dpn = (pnmax - pnmin) / 25
    # Vp bar control
    vpmin = 5.8
    vpmax = 7.2
    dvp = (vpmax - vpmin) / 25
    # Thickness bar control
    hmin = 25
    hmax = 55
    dh = (hmax - hmin) / 25

    # Create a plot Type object that will keep track
    # of what database we used, what parameter is being
    # plotted so we can funnel the right info into titles
    # labels etc
    # Set either 'velocity' or 'thickness' Histograms with
    pt = Ptype(parameterType, dtype)

    if pt.Vp | pt.R:
        if pt.dbtype == "kan":
            data = poisson(d.hk_R)
            bins = np.arange(pnmin, pnmax, dpn)
            if vdictregion in vdict:
                pt.avgmethod = "weighted"
                avgd = poisson(vdict[vdictregion]['kanamori']['R'])
            else:
                avgd = np.mean(poisson(d.hk_R))
        if pt.dbtype == 'moon':
            data = m.Vp
            bins = np.arange(vpmin, vpmax, dvp)
            if vdictregion in vdict:
                pt.avgmethod = "weighted"
                avgd = vdict[vdictregion]['mooney']['Vp']
            else:
                avgd = np.mean(m.Vp)
    if pt.H:
        if pt.dbtype == "kan":
            data = d.hk_H
            bins = np.arange(hmin, hmax, dh)
            if vdictregion in vdict:
                pt.avgmethod = "weighted"
                avgd = vdict[vdictregion]['kanamori']['H']
            else:
                avgd = np.mean(d.hk_H)
        if pt.dbtype == 'moon':
            data = m.H
            bins = np.arange(hmin, hmax, dh)
            if vdictregion in vdict:
                pt.avgmethod = "weighted"
                avgd = vdict[vdictregion]['mooney']['H']
            else:
                avgd = np.mean(m.H)

    return data, avgd, bins, pt.setattribs()

class Ptype(object):
    """ A class for delivering plot type information
    to control titles, legend and additional data """
    def __init__(self, param, db):
        self.H = False
        self.R = False
        self.Vp = False
        if param == "thickness":
            self.H = True
        if param == "velocity":
            self.R = True
            self.Vp = True

        self.dbtype = db
        self.avgmethod = "geometric"
        self.title = None

    def setattribs(self):
        if self.H:
            header = "Crustal Thickness"
            self.xlabel = header + " H [km]"
        if (self.dbtype == 'kan') and not self.H:
            header = "Poisson's Ratio"
            self.xlabel = header
        if self.dbtype == 'moon' and not self.H:
            header = "P-wave Velocity"
            self.xlabel = header + " Vp [km/s]"

        if self.avgmethod == "weighted":
            lstring = "Area Weighted Avg."
        else:
            lstring = "Geometric Avg."
        self.avglabel = lstring + "\n" + header

        self.histlabel = header

        return self

    def settitle(self, prefix):
        self.title = prefix + "\n" + self.histlabel + " Histogram"

vdict = json.loads( open(vfile).read() )

if __name__  == "__main__":

    # Get user input and turn on plot flag ############
    help = '''
    #####################
    # PLOTS.PY CMD
    #####################
    plots.py 0  Canada Wide Histogram
    plots.py 1  Canadian Shield Province Histograms (Provinces)
    plots.py 2  Canadian Shield Aggregate
    plots.py 3  Orogens
    plots.py 4  Platforms
    plots.py 5  Archean vs Proterozoic
    ######################
    '''

    plotnum = [False for i in range(15)]
    if len(sys.argv) < 2:
        print help
        exit()
    else:
        plotnum[int(sys.argv[1])] = True
    ####################################################

    ## Figure Properties #######
    width = 12
    height = 9
    legsize = width + 3
    ###########################
    ## Prep Data
    arg = Args()
    arg.addQuery("status", "eq", "processed-ok")
    # Load station params
    d = Params(stnfile, ["hk::H","hk::R"], arg)

    arg = Args()
    m = Params(moonfile, ["H","Vp"])
    m.filter(arg.addQuery("geoprov", "not in", "oceanic"))
    m.filter(arg.addQuery("geoprov", "not in", "Shelf"))

    #######################################################################
    # F0
    # CANADA
    if plotnum[0]:
    ## Kanamori Poisson Histogram
        # Set figure
        fig = plt.figure( figsize = (width, height) )
        ax = plt.subplot(111)
        # Get data
        dk, avgdk, bins, ptype = getdata("kan", d, m, vdict, "Canada")
        ptype.settitle("Canada Total")

        n, bins, patches = plt.hist(dk, bins = bins, facecolor='green', alpha=0.75, label = ptype.histlabel)
        # add a 'best fit' line
        y = distfunc(dk, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label = "Distribution Curve")
        plotlines(plt, avgdk, ptype)
        formatplot(plt, ax, legsize, ptype)
        addtext(avgdk, ax, n, 0.3)

    ## Mooney Vp Histogram
        # Set figure
        plt.figure( figsize = (width, height) )
        ax = plt.subplot(111)
        # Get data
        dm, avgdm, bins, ptype = getdata("moon", d, m, vdict, "Canada")
        ptype.settitle("Canada Total")


        n, bins, patches = plt.hist(dm, bins = bins, facecolor='green', alpha=0.75, label = ptype.histlabel)

        # add a 'best fit' line
        y = distfunc(dm, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label= "Distribution Curve")
        plotlines(plt, avgdm, ptype)
        formatplot(plt, ax, legsize, ptype)
        addtext(avgdm, ax, n, 0.3)

        if not ptype.H:
            plt.figure(figsize = (width, height))
            plottern(plt, avgdk, avgdm)
    #######################################################################
    # F1
    if plotnum[1]:

        fig = plt.figure( figsize = (width, height) )

        avgp = []
        avgv = []

        provs = [
            "Churchill Province",
            "Superior Province",
            "Slave Province",
            "Grenville Province"
            ]

        color = ['b', 'g', 'm', 'y', 'k', 'c']
        handles = ()
        labels = ()
        plt.subplots_adjust(left= None, bottom=None, right = 0.75, top=None,
                            wspace=None, hspace=0.05)

        for (ii, province) in enumerate(provs):

            d.reset()
            arg = Args()
            arg.addQuery("geoprov", "in", province)
            d2 = Params(stnfile,  ["hk::H","hk::R"], arg)
            d.sync(d2)

            prov = province.replace(" ", "")
            dk, avgdk, bins, ptype = getdata("kan", d, m, vdict, prov)
            avgp.append( avgdk )

            ax = ( plt.subplot(4,1,ii + 1) )

            n, bins, patches = plt.hist(dk, bins = bins, histtype = "bar",
                     color = color[ii], rwidth = 1, alpha = 0.6,
                     label = province)

            handle, label = ax.get_legend_handles_labels()
            handles += (handle[0],)
            labels += (label[0],)

            y = distfunc(dk, bins, n)
            plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
            plotlines(plt, avgdk, ptype)
            if ii < 3:
                ptype.xlabel = None
            formatplot(plt, ax, None, ptype)
            plt.setp( ax.get_xticklabels(), visible=False)
            addtext(avgdk, ax, n, 0.3)

        handle, label = ax.get_legend_handles_labels()
        handles += tuple(handle[:-1])
        labels += tuple(label[:-1])
        fig.legend(handles, labels, 'right', prop={'size': legsize})
        plt.setp( ax.get_xticklabels(), visible= True)
        plt.suptitle(ptype.histlabel + ' Histogram\n Major Canadian Shield Provinces', size = 22)


    ## Mooney Vp ##
        fig = plt.figure( figsize = (width, height) )
        plt.subplots_adjust(left = None, bottom=None, right = 0.75, top= None,
                            wspace=None, hspace=0.05)
        handles = ()
        labels = ()

        for (ii, province) in enumerate(provs):

            m.reset()
            arg = Args()
            arg.addQuery("geoprov", "in", province)
            m2 = Params(moonfile,  ["H","Vp"], arg)

            m.sync(m2)
            prov = province.replace(" ", "")
            dm, avgdm, bins, ptype = getdata("moon", d, m, vdict, prov)
            avgv.append(avgdm)

            ax = ( plt.subplot(4,1,ii + 1) )

            n, bins, patches = plt.hist(dm, bins = bins, histtype = "bar",
                     color = color[ii], rwidth = 1, alpha = 0.6,
                     label = province)

            handle, label = ax.get_legend_handles_labels()
            handles += (handle[0],)
            labels += (label[0],)

            y = distfunc(dm, bins, n)
            plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
            plotlines(plt, avgdm, ptype)
            if ii < 3:
                ptype.xlabel = None
            formatplot(plt, ax, None, ptype)
            addtext(avgdm, ax, n, 0.3)
            plt.setp( ax.get_xticklabels(), visible=False)

        handle, label = ax.get_legend_handles_labels()
        handles += tuple(handle[:-1])
        labels += tuple(label[:-1])
        fig.legend(handles, labels, 'right', prop={'size': legsize})
        plt.setp( ax.get_xticklabels(), visible= True)
        plt.suptitle(ptype.histlabel + ' Histogram\n Major Canadian Shield Provinces', size = 22)

        if not ptype.H:
            plt.figure(figsize = (width, height))
            ii = 0
            for p, v in zip(avgp, avgv):
                plt.subplot(2,2,ii)
                plottern(plt, p, v)
                ii += 1

    #######################################################################
    # F2 Sheild as a whole
    if plotnum[2]:
    ### Vp/Vs Estimates
        plt.figure( figsize = (width, height) )
        arg = Args()
        arg.addQuery("geoprov", "in", "Province")
        d.filter(arg)
        dk, avgdk, bins, ptype = getdata("kan", d, m, vdict, "Shield")
        ptype.settitle("Canadian Shield")
        ax = plt.subplot(111)
        n, bins, patches = plt.hist(dk, bins = bins, facecolor='green', alpha=0.75, label=ptype.histlabel)

        # add a 'best fit' line
        y = distfunc(dk, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plotlines(plt, avgdk, ptype)
        formatplot(plt, ax, legsize, ptype)
        addtext(avgdk, ax, n, 0.3)

    ## Mooney Vp Histogram
        plt.figure( figsize = (width, height) )
        ax = plt.subplot(111)
        arg = Args()
        arg.addQuery("geoprov", "in", "Province")
        m.filter(arg)

        dm, avgdm, bins, ptype = getdata("moon", d, m, vdict, "Shield")
        ptype.settitle("Canadian Shield")
        n, bins, patches = plt.hist(dm, bins = bins, normed = True,  facecolor='green', alpha=0.75, label='Mooney Vp')

        # add a 'best fit' line
        y = distfunc(dm, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plotlines(plt, avgdm, ptype)
        formatplot(plt, ax, legsize, ptype)
        addtext(avgdm, ax, n, 0.3)

    #######################################################################
    # F3 Orogens
    if plotnum[3]:
    # Kanamori Poisson Histogram
        plt.figure( figsize = (width, height) )
        arg = Args()
        arg.addQuery("geoprov", "in", "Orogen")

        d.filter(arg)
        dk, avgdk, bins, ptype = getdata("kan", d, m, vdict, 'Orogen')
        ptype.settitle("Canadian Orogens")
        ax = plt.subplot(111)
        n, bins, patches = plt.hist(dk, bins = bins, facecolor='green', alpha=0.75, label=ptype.histlabel)

        # add a 'best fit' line
        y = distfunc(dk, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plotlines(plt, avgdk, ptype)
        formatplot(plt, ax, legsize, ptype)
        addtext(avgdk, ax, n, 0.3)

    # Mooney Vp histogram
        plt.figure( figsize = (width, height) )
        ax = plt.subplot(111)
        arg = Args()
        arg.addQuery("geoprov", "in", "Orogen")
        m.filter(arg)

        dm, avgdm, bins, ptype = getdata("moon", d, m, vdict, "Orogen")
        ptype.settitle("Canadian Orogens")
        n, bins, patches = plt.hist(dm, bins = bins, facecolor='green', alpha=0.75, label=ptype.histlabel)

        # add a 'best fit' line
        y = distfunc(dm, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plotlines(plt, avgdm, ptype)
        formatplot(plt, ax, legsize, ptype)
        addtext(avgdm, ax, n, 0.3)

    #######################################################################
    # F4 Platforms
    if plotnum[4]:
    # Kanamori Poisson Histogram
        plt.figure( figsize = (width, height) )
        arg = Args()
        arg.addQuery("geoprov", "in", "Platform")

        d.filter(arg)
        dk, avgdk, bins, ptype = getdata("kan", d, m, vdict, 'Platform')
        ptype.settitle("Canadian Platforms")
        ax = plt.subplot(111)
        n, bins, patches = plt.hist(dk, bins = bins, facecolor='green', alpha=0.75, label=ptype.histlabel)

        # add a 'best fit' line
        y = distfunc(dk, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plotlines(plt, avgdk, ptype)
        formatplot(plt, ax, legsize, ptype)
        addtext(avgdk, ax, n, 0.3)

    # Mooney Vp histogram

        plt.figure( figsize = (width, height) )
        ax = plt.subplot(111)
        arg = Args()
        arg.addQuery("geoprov", "in", "Platform")
        m.filter(arg)

        dm, avgdm, bins, ptype = getdata("moon", d, m, vdict, "Platform")
        ptype.settitle("Canadian Platforms")
        n, bins, patches = plt.hist(dm, bins = bins, facecolor='green', alpha=0.75, label=ptype.histlabel)

        # add a 'best fit' line
        y = distfunc(dm, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plotlines(plt, avgdm, ptype)
        formatplot(plt, ax, legsize, ptype)
        addtext(avgdm, ax, n, 0.3)

    #######################################################################
    # F5 Archean vs Proterozoic
    if plotnum[5]:
        plt.figure( figsize = (width, height) )
        arg = Args()
        arg.addQuery("wm::type", "in", "Archean")
        d2 = copy.deepcopy(d)
        arg2 = Args()
        arg2.addQuery("wm::type", "in", "Proter")

        d.filter(arg)
        d2.filter(arg2)

        dk, avgdk, bins, ptype = getdata("kan", d, m, vdict, 'Archean')
        ptype.settitle("Archean and Proterozoic")
        d2k, avgd2k, dum1, ptype2 = getdata("kan", d2, [], vdict, 'Proter')

        ax = plt.subplot(111)
        n, bins, patches = plt.hist(dk, bins = bins, facecolor='green', alpha=1, label= "Archean")
        n2, bins2, patches2 = plt.hist(d2k, bins = bins, facecolor='blue', alpha=0.65, label= "Proterozoic")
        # add a 'best fit' line
        y = distfunc(dk, bins, n)
        y2 = distfunc(d2k, bins, n2)
        plt.plot(bins, y, 'r--', linewidth=2, label='Archean Distribution')
        plt.plot(bins, y2, 'b--', linewidth=2, label='Proter. Distribution')
        ptype.avglabel = "Geometric Avg.\nArchean"
        plotlines(plt, avgdk, ptype)
        plt.axvline(x = avgd2k, linewidth = 4, color = 'b', label = "Geometric Avg.\n" + "Proterozoic" )
        #ptype.title = "Archean and Proterozoic\n Crustal Thickness from Processed Station Data"
        formatplot(plt, ax, legsize, ptype)
        addtext([avgdk, avgd2k], ax, n, 0.3)

#############    # Mooney Vp histogram ###############

        plt.figure( figsize = (width, height) )
        ax = plt.subplot(111)
        arg = Args()
        arg.addQuery("wm::type", "in", "Archean")

        m2 = copy.deepcopy(m)

        arg2 = Args()
        arg2.addQuery("wm::type", "in", "Proter")

        m.filter(arg)
        m2.filter(arg2)

        dm, avgdm, bins, ptype= getdata("moon", d, m, vdict, "Archean")
        ptype.settitle("Archean and Proterozoic")
        d2m, avgd2m, dum1, dum2 = getdata("moon", d2, m2, vdict, "Proter")

        n, bins, patches = plt.hist(dm, bins = bins, facecolor='green', alpha=1, label= "Archean")
        n2, bins, patches = plt.hist(d2m, bins = bins, facecolor='blue', alpha=0.65, label="Proterozoic")

        # add a 'best fit' line
        y = distfunc(dm, bins, n)
        y2 = distfunc(d2m, bins, n2)
        plt.plot(bins, y, 'r--', linewidth=2, label='Archean curve')
        plt.plot(bins, y2, 'b--', linewidth=2, label='Proter. Distribution')
        ptype.avglabel = "Geometric Avg.\nArchean"
        plotlines(plt, avgdm, ptype)
        plt.axvline(x = avgd2m, linewidth = 4, color = 'b', label = "Geometric Avg.\n" + "Proterozoic" )
        #ptype.title = "Archean and Proterozoic\n Crustal Thickness from W. Mooney et. al. (2004) Data"
        formatplot(plt, ax, legsize, ptype)
        addtext([avgdm, avgd2m], ax, n, 0.3)




#    select fig and plot    #
#############################
                            #
    for p in plotnum:       #
        if p:               #
            plt.show()      #
                            #
#############################
