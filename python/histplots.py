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

stnfile = os.environ['HOME'] + '/thesis/data/stations.json'
moonfile = os.environ['HOME'] + '/thesis/data/moonvpGeology.json'
vfile = os.environ['HOME'] + '/thesis/data/voronoi.data'

def poisson(R):
    ''' Function to go from Vp/Vs -> Poisson's ratio '''
    return 0.5 * ( 1 - 1 / (R**2 - 1) )


def addtext(data, ax, n, arclen):
    for ii, v in enumerate(data):
        txt = r'$\sigma=$'+"{:0.3f}".format(v)
        ax.annotate(txt, xy = (v , 0.85 * max(n)) if ii else (v , 0.7 * max(n)),  xycoords='data', size = 16,
                     xytext=(arclen, 10), textcoords='offset points',
                     arrowprops=dict(arrowstyle="->",lw = 3,
                                     connectionstyle="arc3,rad=.2"))

def distfunc(data, bins, n = None):
    """ Distribution curve of histogram with some
    added optional scaling """
    (mu, sigma) = norm.fit(data)
    # add a 'best fit' line
    y = mlab.normpdf( bins, mu, sigma)
    if n != None:
        y *= np.max(n) / np.max(y)
    return y

def plotlines(plt, data, label, ptype):
    h = []
    if ptype == "Vp":
        gran = 6.208
        biot = 6.302
        mafc = 6.942
    elif ptype == "P":
        gran = 0.250
        biot = 0.257
        mafc = 0.283
    else:
        raise Exception("Unknown type in plotlines!")
    h.append(plt.axvline(x = data, linewidth = 4, color = 'r', label = label))
    h.append(plt.axvline(x = gran, linewidth = 4, color = '0.7', label = "granite gneiss"))
    h.append(plt.axvline(x = biot, linewidth = 4, color = '0.5', label = "tonalitic gneiss"))
    h.append(plt.axvline(x = mafc, linewidth = 4, color = '0.3', label = "mafic gneiss"))
    return h

def formatplot(plt, ax, title, legendsize, ptype):
    xlabel = "Poisson Ratio" if ptype == "P" else "P-wave Velocity Vp [km/s]"
    plt.title(title, size = 22)
    plt.xlabel(xlabel, size = 16)
    plt.ylabel("# of Data", size = 16)
    plt.legend(prop={'size':legendsize})
    plt.grid(True)

    for tick in ax1.xaxis.get_major_ticks():
        tick.label.set_fontsize(14)



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
    plots.py 4  Archean vs Proterozoic
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
    # Poisson Ratio bar control
    pnmin = 0.22
    pnmax = 0.30
    dpn = (pnmax - pnmin) / 25
    # Vp bar control
    vpmin = 5.8
    vpmax = 7.2
    dvp = (vpmax - vpmin) / 25
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
        ax1 = plt.subplot(111)
        # Get data
        d.hk_P = poisson(d.hk_R)
        # Get voronoi data
        d.avgvn = poisson(vdict['canada']['kanamori']['R'])
        # the histogram of the data
        bins = np.arange(pnmin, pnmax, dpn)
        n, bins, patches = plt.hist(d.hk_P, bins = bins, facecolor='green', alpha=0.75, label='Poisson ratio')
        # add a 'best fit' line
        y = distfunc(d.hk_P, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plotlines(plt, d.avgvn, "Area Weighted\nPoisson Average", "P")
        formatplot(plt, ax1, "Canada Wide Poisson Ratio Histogram", legsize, "P")

    ## Mooney Vp Histogram
        # Set figure
        plt.figure( figsize = (width, height) )
        ax2 = plt.subplot(111)
        # Get data
        m.avgvn = vdict['canada']['mooney']['Vp']

        # the histogram of the data
        bins = np.arange(vpmin, vpmax, dvp)
        n, bins, patches = plt.hist(m.Vp, bins = bins, facecolor='green', alpha=0.75, label='Mooney Vp')

        # add a 'best fit' line
        y = distfunc(m.Vp, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plotlines(plt, m.avgvn, "Area Weighted\nVp Average", "Vp")
        formatplot(plt, ax1, "Canada Wide P-wave Velocity Histogram", legsize, "Vp")


    #######################################################################
    # F1
    if plotnum[1]:

        fig = plt.figure( figsize = (width, height) )

        provs = [
            "Superior Province",
            "Churchill Province",
            "Slave Province",
            "Grenville Province"
            ]

        color = ['b', 'g', 'm', 'y', 'k', 'c']
        bins = np.arange(pnmin, pnmax, dpn)
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

            d.hk_P = poisson(d.hk_R)
            prov = province.replace(" ", "")
            d.avgvn = poisson(vdict[prov]['kanamori']['R'])
            d.avgpNik = 0.265

            ax = ( plt.subplot(4,1,ii + 1) )

            n, bins, patches = plt.hist(d.hk_P, bins = bins, histtype = "bar",
                     color = color[ii], rwidth = 1, alpha = 0.6,
                     label = province)
            handle, label = ax.get_legend_handles_labels()
            handles += (handle[0],)
            labels += (label[0],)

            y = distfunc(d.hk_P, bins, n)
            distc = plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
            abgvn = plt.axvline(x = d.avgvn, linewidth = 4, color = 'r', label = "Area Weighted\nPoisson Average")
            avgpNik = plt.axvline(x = d.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust\nN. Christensen ('96)")
            plt.setp( ax.get_xticklabels(), visible=False)
            plt.ylabel("num of stations")
            plt.xlabel("Vp/Vs")
            addtext([d.avgvn, d.avgpNik], ax, n, -80)
            plt.grid(True)

        handles += (distc, abgvn, avgpNik)
        labels += ('Distribution curve', 'Area Weighted\nPoisson Average', "Avg Cont. Crust N.\nChristensen ('96)")
        fig.legend(handles, labels, 'right', prop={'size': legsize})
        plt.setp( ax.get_xticklabels(), visible= True)
        plt.suptitle('Poisson Ratio Histogram\n Major Canadian Shield Provinces', size = 22)

        for tick in ax.xaxis.get_major_ticks():
            tick.label.set_fontsize(14)

    ## Mooney Vp ##
        fig = plt.figure( figsize = (width, height) )

        plt.subplots_adjust(left = None, bottom=None, right = 0.75, top= None,
                            wspace=None, hspace=0.05)

        bins = np.arange(vpmin, vpmax, dvp)
        handles = ()
        labels = ()

        for (ii, province) in enumerate(provs):

            m.reset()
            arg = Args()
            arg.addQuery("geoprov", "in", province)
            m2 = Params(moonfile,  ["H","Vp"], arg)

            m.sync(m2)
            prov = province.replace(" ", "")
            m.avgvn = vdict[prov]['mooney']['Vp']
            m.avgpNik = 6.454

            ax = ( plt.subplot(4,1,ii + 1) )

            n, bins, patches = plt.hist(m.Vp, bins = bins, histtype = "bar",
                     color = color[ii], rwidth = 1, alpha = 0.6,
                     label = province)
            handle, label = ax.get_legend_handles_labels()
            handles += (handle[0],)
            labels += (label[0],)

            y = distfunc(m.Vp, bins, n)
            distc = plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
            abgvn = plt.axvline(x = m.avgvn, linewidth = 4, color = 'r', label = "Area Weighted\nPoisson Average")
            avgpNik = plt.axvline(x = m.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust\nN. Christensen ('96)")
            plt.setp( ax.get_xticklabels(), visible=False)
            plt.ylabel("num of stations")
            plt.xlabel("Vp [km/s]")
            addtext([m.avgvn, m.avgpNik], ax, n, -180)

            plt.grid(True)


    #    ax = plt.subplot(4,1,4)
        handles += (distc, abgvn, avgpNik)
        labels += ('Distribution curve', 'Area Weighted\nPoisson Average', "Avg Cont. Crust N.\nChristensen ('96)")
        fig.legend(handles, labels, 'right', prop={'size': legsize})
        plt.setp( ax.get_xticklabels(), visible= True)
        plt.suptitle('Mooney Vp Histogram\n Major Canadian Shield Provinces', size = 22)

        for tick in ax.xaxis.get_major_ticks():
            tick.label.set_fontsize(14)


    #######################################################################
    # F2 Sheild as a whole
    if plotnum[2]:

    ### Vp/Vs Estimates
    # Voronoi average Vp/Vs = 1.734761
    # Voronoi average H = 39.107447
        plt.figure( figsize = (width, height) )
        arg = Args()
        arg.addQuery("geoprov", "in", "Province")
        d.filter(arg)

        d.hk_P = poisson(d.hk_R)
        d.avgvn = poisson(vdict['Shield']['kanamori']['R'] )
        d.avgpNik = 0.265

        ax = plt.subplot(111)
        # the histogram of the data
        bins = np.arange(pnmin, pnmax, dpn)
        n, bins, patches = plt.hist(d.hk_P, bins = bins, facecolor='green', alpha=0.75, label='Poisson ratio')

        # add a 'best fit' line
        y = distfunc(d.hk_P, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plt.axvline(x = d.avgvn, linewidth = 4, color = 'r', label = "Area Weighted\nPoisson Average")
        plt.axvline(x = d.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust\nN. Christensen ('96)")
        plt.title("Canadian Shield - Poisson Ratio Histogram", size = 22)
        plt.xlabel("Poisson Ratio", size = 16)
        plt.ylabel("# of Data", size = 16)
        plt.legend(prop={'size': legsize})
        plt.grid(True)

        for tick in ax.xaxis.get_major_ticks():
                    tick.label.set_fontsize(14)

        addtext([d.avgvn, d.avgpNik], ax, n, -100)

    ## Mooney Vp Histogram
    # Voronoi average Vp = 6.406250
    # Voronoi average H = 38.169429
        plt.figure( figsize = (width, height) )
        ax2 = plt.subplot(111)
        arg = Args()
        arg.addQuery("geoprov", "in", "Province")
        m.filter(arg)

        m.avgvn = vdict['Shield']['mooney']['Vp']
        m.avgpNik = 6.454

        # the histogram of the data
        bins = np.arange(vpmin, vpmax, dvp)
        n, bins, patches = plt.hist(m.Vp, bins = bins, normed = True,  facecolor='green', alpha=0.75, label='Mooney Vp')

        # add a 'best fit' line
        y = distfunc(m.Vp, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plt.axvline(x = m.avgvn, linewidth = 4, color = 'r', label = "Area Weighted\nMooney Vp")
        plt.axvline(x = m.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust\nN. Christensen ('96)")
        plt.title("Canadian Shield - Mooney Vp Data", size = 22)
        plt.xlabel("Mooney Vp", size = 16)
        plt.ylabel("# of Data", size = 16)
        plt.legend(prop={'size': legsize})
        plt.grid(True)

        for tick in ax2.xaxis.get_major_ticks():
                    tick.label.set_fontsize(14)

        addtext([m.avgvn, m.avgpNik], ax2, n, -120)

    #######################################################################
    # F3 Orogens
    if plotnum[3]:
    # Kanamori Poisson Histogram
        plt.figure( figsize = (width, height) )
        arg = Args()
        arg.addQuery("geoprov", "in", "Orogen")

        d.filter(arg)

        d.hk_P = poisson(d.hk_R)
        d.avgvn = poisson( np.mean(d.hk_R))
        d.avgpNik = 0.265

        ax = plt.subplot(111)
        # the histogram of the data
        bins = np.arange(pnmin, pnmax, dpn)
        n, bins, patches = plt.hist(d.hk_P, bins = bins, facecolor='green', alpha=0.75, label='Poisson ratio')

        # add a 'best fit' line
        y = distfunc(d.hk_P, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plotlines(plt, m.avgvn, "Geometric\nPoisson Average")
        plt.title("Canadian Orogens - Poisson Ratio Histogram", size = 22)
        plt.xlabel("Poisson Ratio", size = 16)
        plt.ylabel("# of Data", size = 16)
        plt.legend(prop={'size': legsize})
        plt.grid(True)

        for tick in ax.xaxis.get_major_ticks():
                    tick.label.set_fontsize(14)

        addtext([d.avgvn, d.avgpNik], ax, n, -100)

    # Mooney Vp histogram
    # Voronoi average Vp/Vs = 6.364002
    # Voronoi average H = 36.249304
        plt.figure( figsize = (width, height) )
        ax2 = plt.subplot(111)
        arg = Args()
        arg.addQuery("geoprov", "in", "Orogen")
        m.filter(arg)

        m.avgvn = np.mean(m.Vp)
        m.avgpNik = 6.454

        # the histogram of the data
        bins = np.arange(vpmin, vpmax, dvp)
        n, bins, patches = plt.hist(m.Vp, bins = bins, facecolor='green', alpha=0.75, label='Mooney Vp')

        # add a 'best fit' line
        y = distfunc(m.Vp, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')

        plt.title("Canadian Orogens - Mooney Vp Data", size = 22)
        plt.xlabel("Mooney Vp", size = 16)
        plt.ylabel("# of Data", size = 16)
        plt.legend(prop={'size': legsize})
        plt.grid(True)

        for tick in ax2.xaxis.get_major_ticks():
                    tick.label.set_fontsize(14)

        addtext([m.avgvn, m.avgpNik], ax2, n, -120)


    #######################################################################
    # F4 Platforms
    if plotnum[4]:
    # Kanamori Poisson Histogram
        plt.figure( figsize = (width, height) )
        arg = Args()
        arg.addQuery("geoprov", "in", "Platform")

        d.filter(arg)

        d.hk_P = poisson(d.hk_R)
        d.avgvn = poisson( np.mean(d.hk_R))
        d.avgpNik = 0.265

        ax = plt.subplot(111)
        # the histogram of the data
        bins = np.arange(pnmin, pnmax, dpn)
        n, bins, patches = plt.hist(d.hk_P, bins = bins, facecolor='green', alpha=0.75, label='Poisson ratio')

        # add a 'best fit' line
        y = distfunc(d.hk_P, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')

        plt.title("Platforms - Poisson Ratio Histogram", size = 22)
        plt.xlabel("Poisson Ratio", size = 16)
        plt.ylabel("# of Data", size = 16)
        plt.legend(prop={'size': legsize})
        plt.grid(True)

        for tick in ax.xaxis.get_major_ticks():
                    tick.label.set_fontsize(14)

        addtext([d.avgvn, d.avgpNik], ax, n, -100)

    # Mooney Vp histogram
    # Voronoi average Vp/Vs = 6.364002
    # Voronoi average H = 36.249304
        plt.figure( figsize = (width, height) )
        ax2 = plt.subplot(111)
        arg = Args()
        arg.addQuery("geoprov", "in", "Orogen")
        m.filter(arg)

        m.avgvn = np.mean(m.Vp)
        m.avgpNik = 6.454

        # the histogram of the data
        bins = np.arange(vpmin, vpmax, dvp)
        n, bins, patches = plt.hist(m.Vp, bins = bins, facecolor='green', alpha=0.75, label='Mooney Vp')

        # add a 'best fit' line
        y = distfunc(m.Vp, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')

        plt.title("Platforms - Mooney Vp Data", size = 22)
        plt.xlabel("Mooney Vp", size = 16)
        plt.ylabel("# of Data", size = 16)
        plt.legend(prop={'size': legsize})
        plt.grid(True)

        for tick in ax2.xaxis.get_major_ticks():
                    tick.label.set_fontsize(14)

        addtext([m.avgvn, m.avgpNik], ax2, n, -120)

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

        d.hk_P = poisson(d.hk_R)
        d2.hk_P = poisson(d2.hk_R)
        d.avgvn = poisson(1.734)
        d.avgpNik = 0.265

        ax = plt.subplot(111)
        # the histogram of the data
        bins = np.arange(pnmin, pnmax, dpn)
        n, bins, patches = plt.hist(d.hk_P, bins = bins, facecolor='green', alpha=0.75, label='Poisson ratio')
        n2, bins2, patches2 = plt.hist(d2.hk_P, bins = bins, facecolor='red', alpha=1, label='Poisson ratio')
        # add a 'best fit' line
        y = distfunc(d.hk_P, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')

        plt.title("Archean vs Proterozoic - Poisson Ratio Histogram", size = 22)
        plt.xlabel("Poisson Ratio", size = 16)
        plt.ylabel("# of Data", size = 16)
        plt.legend(prop={'size': legsize})
        plt.grid(True)

        for tick in ax.xaxis.get_major_ticks():
                    tick.label.set_fontsize(14)

        addtext([d.avgvn, d.avgpNik], ax, n, -100)

#############    # Mooney Vp histogram ###############

        plt.figure( figsize = (width, height) )
        ax2 = plt.subplot(111)
        arg = Args()
        arg.addQuery("wm::type", "in", "Archean")

        m2 = copy.deepcopy(m)

        arg2 = Args()
        arg2.addQuery("wm::type", "in", "Proter")

        m.filter(arg)
        m2.filter(arg2)
        m.avgvn = 6.40625
        m.avgpNik = 6.454

        # the histogram of the data
        bins = np.arange(vpmin, vpmax, dvp)
        n, bins, patches = plt.hist(m.Vp, bins = bins, facecolor='green', alpha=0.75, label='Mooney Vp')
        n2, bins, patches = plt.hist(m2.Vp, bins = bins, facecolor='red', alpha=1, label='Mooney Vp')

        # add a 'best fit' line
        y = distfunc(m.Vp, bins, n)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')

        plt.title("Archean vs Proterozoic - Mooney Vp Data", size = 22)
        plt.xlabel("Mooney Vp", size = 16)
        plt.ylabel("# of Data", size = 16)
        plt.legend(prop={'size': legsize})
        plt.grid(True)

        for tick in ax2.xaxis.get_major_ticks():
                    tick.label.set_fontsize(14)

        addtext([m.avgvn, m.avgpNik], ax2, n, -120)




    for p in plotnum:
        if p:
            plt.show()

