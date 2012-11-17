#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

###########################################################################
# IMPORTS
###########################################################################
import sys, os, json
#from dbutils import queryStats, getStats
from plotTools import Args, Params
import matplotlib.pyplot as plt
import numpy as np
from scipy.signal import detrend
from scipy.stats import pearsonr, norm
#from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.mlab as mlab



def poisson(R):
    ''' Function to go from Vp/Vs -> Poisson's ratio '''
    return  ( (R**2 - 2) / (2*(R**2 - 1)))


def addtext(data, ax, n, arclen):
    for ii, v in enumerate(data):
        txt = r'$\sigma=$'+"{:0.3f}".format(v)
        ax.annotate(txt, xy = (v , 0.85 * max(n)) if ii else (v , 0.7 * max(n)),  xycoords='data', size = 16,
                     xytext=(arclen, 10), textcoords='offset points',
                     arrowprops=dict(arrowstyle="->",lw = 3,
                                     connectionstyle="arc3,rad=.2"))

def distfunc(data, bins):
    (mu, sigma) = norm.fit(data)
    # add a 'best fit' line
    return mlab.normpdf( bins, mu, sigma)

if __name__  == "__main__":

    # Get user input and turn on plot flag ############
    help = '''
    #####################
    # PLOTS.PY CMD
    #####################
    plots.py 0  Canada Wide Histogram
    plots.py 1  Canadian Shield Province Histograms (Provinces)
    plots.py 2  Canadian Shield Aggregate
    plots.py 3  Cordilleran Orogen
    ######################
    '''

    plotnum = [False for i in range(15)]
    if len(sys.argv) < 2:
        print help
    else:
        plotnum[int(sys.argv[1])] = True
    ####################################################

    ## Figure Properties #######
    width = 12
    height = 9
    legsize = width + 3
    # Poisson Ratio bar control
    pnmin = 0.20
    pnmax = 0.35
    dpn = 0.0025
    # Vp bar control
    vpmin = 0
    vpmax = 50.0
    dvp = 0.04
    ###########################
    ## Prep Data
    arg = Args()
    arg.addQuery("hk::stdR", "lt", "0.041")
    # Load station params
    d = Params(os.environ['HOME'] + '/thesis/data/stations.json', ["hk::H","hk::R"], arg)
    a = sorted(d.stns)
    d.filter(arg.addQuery("usable", "eq", "1"))

    arg = Args()
    #arg.addQuery("Vp", "gt", "5.6")
    m = Params(os.environ['HOME'] + '/thesis/data/moonvpGeology.json', ["H","Vp"])
    m.filter(arg.addQuery("geoprov", "not in", "oceanic"))
    m.filter(arg.addQuery("geoprov", "not in", "Shelf"))

    print m.stns[m.Vp < 5.2], m.Vp[m.Vp < 5.2]

    # argp.addQuery("Vp", "lt", "5.2")
    # mp = Params(os.environ['HOME'] + '/thesis/data/moonvpGeology.json', argp, ["H","Vp"])
    # print sorted(map(float,mp.stns))

    #######################################################################
    # F0
    if plotnum[0]:
    ## Kanamori Poisson Histogram

        fig = plt.figure( figsize = (width, height) )
        d.hk_P = poisson(d.hk_R)
        d.avgvn = poisson(1.746516)
        d.avgpNik = 0.265

        ax1 = plt.subplot(111)

        # the histogram of the data
        bins = np.arange(pnmin, pnmax, dpn)
        n, bins, patches = plt.hist(d.hk_P, bins = bins, normed = True,  facecolor='green', alpha=0.75, label='Poisson ratio')

        # add a 'best fit' line
        y = distfunc(d.hk_P, bins)

        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plt.axvline(x = d.avgvn, linewidth = 4, color = 'r', label = "Area Weighted\nPoisson Average")
        plt.axvline(x = d.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust\nN. Christensen ('96)")
        plt.title("Canada Wide Poisson Ratio Histogram", size = 22)
        plt.xlabel("Poisson Ratio", size = 16)
        plt.ylabel("Probability", size = 16)
        plt.legend(prop={'size':legsize})
        plt.grid(True)

        for tick in ax1.xaxis.get_major_ticks():
                    tick.label.set_fontsize(14)


        addtext([d.avgvn, d.avgpNik], ax1, n, -180)

    ## Mooney Vp Histogram
        plt.figure( figsize = (width, height) )
        ax2 = plt.subplot(111)
        # Voronoi average Vp/Vs = 6.289357
        # Voronoi average H = 34.700373
        m.avgvn = 6.289
        m.avgpNik = 6.454

        # the histogram of the data
        bins = np.arange(vpmin, vpmax, dvp)
        n, bins, patches = plt.hist(m.Vp, bins = bins, normed = True,  facecolor='green', alpha=0.75, label='Mooney Vp')

        # add a 'best fit' line
        y = distfunc(m.Vp, bins)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plt.axvline(x = m.avgvn, linewidth = 4, color = 'r', label = "Area Weighted\nMooney Vp")
        plt.axvline(x = m.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust\nN. Christensen ('96)")
        plt.title("Canada Wide Mooney Vp Data", size = 22)
        plt.xlabel("Mooney Vp", size = 16)
        plt.ylabel("Probability", size = 16)
        plt.legend(prop={'size': legsize})
        plt.grid(True)

        for tick in ax2.xaxis.get_major_ticks():
                    tick.label.set_fontsize(14)


        addtext([m.avgvn, m.avgpNik], ax2, n, -100)


    #######################################################################
    # F1
    if plotnum[1]:

        fig = plt.figure( figsize = (width, height) )

        # province: voronoiR, vonoroiH, voronoiMooneyVp, voronoiMooneyH
        provinces = {
            "Churchill Province": [1.7325, 38.9727, 6.3775, 38.3817],
            "Superior Province": [1.7249, 39.8632,  6.4350, 37.7152],
            "Slave Province": [1.7392, 38.4625, 6.4144 , 42.1742],
            "Grenville Province": [1.8250, 41.7257, 6.4794, 40.9236]
            }

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
            d2 = Params(os.environ['HOME'] + '/thesis/data/stations.json', arg, ["hk::H","hk::R"])

            d.sync(d2)

            d.hk_P = poisson(d.hk_R)
            d.avgvn = poisson(provinces[province][0])
            d.avgpNik = 0.265

            ax = ( plt.subplot(4,1,ii + 1) )

            n, bins, patches = plt.hist(d.hk_P, bins = bins, histtype = "bar", normed = True,
                     color = color[ii], rwidth = 1, alpha = 0.6,
                     label = province)
            handle, label = ax.get_legend_handles_labels()
            handles += (handle[0],)
            labels += (label[0],)

            y = distfunc(d.hk_P, bins)
            distc = plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
            abgvn = plt.axvline(x = d.avgvn, linewidth = 4, color = 'r', label = "Area Weighted\nPoisson Average")
            avgpNik = plt.axvline(x = d.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust\nN. Christensen ('96)")
            plt.setp( ax.get_xticklabels(), visible=False)

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
            arg.addQuery("Vp", "gt", "5.6")
            m2 = Params(os.environ['HOME'] + '/thesis/data/moonvpGeology.json', arg, ["H","Vp"])

            m.sync(m2)

            m.avgvn = provinces[province][2]
            m.avgpNik = 6.454

            ax = ( plt.subplot(4,1,ii + 1) )

            n, bins, patches = plt.hist(m.Vp, bins = bins, histtype = "bar", normed = True,
                     color = color[ii], rwidth = 1, alpha = 0.6,
                     label = province)
            handle, label = ax.get_legend_handles_labels()
            handles += (handle[0],)
            labels += (label[0],)

            y = distfunc(m.Vp, bins)
            distc = plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
            abgvn = plt.axvline(x = m.avgvn, linewidth = 4, color = 'r', label = "Area Weighted\nPoisson Average")
            avgpNik = plt.axvline(x = m.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust\nN. Christensen ('96)")
            plt.setp( ax.get_xticklabels(), visible=False)

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
        d2 = Params(os.environ['HOME'] + '/thesis/data/stations.json', arg, ["hk::H","hk::R"])

        d.sync(d2)

        d.hk_P = poisson(d.hk_R)
        d.avgvn = poisson(1.734)
        d.avgpNik = 0.265

        ax = plt.subplot(111)
        # best fit of data
        (mu, sigma) = norm.fit(d.hk_P)
        # the histogram of the data
        bins = np.arange(pnmin, pnmax, dpn)
        n, bins, patches = plt.hist(d.hk_P, bins = bins, normed = True,  facecolor='green', alpha=0.75, label='Poisson ratio')

        # add a 'best fit' line
        y = mlab.normpdf( bins, mu, sigma)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plt.axvline(x = d.avgvn, linewidth = 4, color = 'r', label = "Area Weighted\nPoisson Average")
        plt.axvline(x = d.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust\nN. Christensen ('96)")
        plt.title("Canadian Shield - Poisson Ratio Histogram", size = 22)
        plt.xlabel("Poisson Ratio", size = 16)
        plt.ylabel("Probability", size = 16)
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
        m2 = Params(os.environ['HOME'] + '/thesis/data/moonvpGeology.json', arg, ["H","Vp"])

        m.sync(m2)

        m.avgvn = 6.40625
        m.avgpNik = 6.454

        # the histogram of the data
        bins = np.arange(vpmin, vpmax, dvp)
        n, bins, patches = plt.hist(m.Vp, bins = bins, normed = True,  facecolor='green', alpha=0.75, label='Mooney Vp')

        # add a 'best fit' line
        y = distfunc(m.Vp, bins)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plt.axvline(x = m.avgvn, linewidth = 4, color = 'r', label = "Area Weighted\nMooney Vp")
        plt.axvline(x = m.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust\nN. Christensen ('96)")
        plt.title("Canadian Shield - Mooney Vp Data", size = 22)
        plt.xlabel("Mooney Vp", size = 16)
        plt.ylabel("Probability", size = 16)
        plt.legend(prop={'size': legsize})
        plt.grid(True)

        for tick in ax2.xaxis.get_major_ticks():
                    tick.label.set_fontsize(14)

        addtext([m.avgvn, m.avgpNik], ax2, n, -120)

    #######################################################################
    # F3
    if plotnum[3]:
    # Kanamori Poisson Histogram
    # Voronoi average Vp/Vs = 1.757236
    # Voronoi average H = 33.755679
        plt.figure( figsize = (width, height) )
        arg = Args()
        arg.addQuery("geoprov", "in", "Cordilleran Orogen")
        d2 = Params(os.environ['HOME'] + '/thesis/data/stations.json', arg, ["hk::H","hk::R"])

        d.sync(d2)

        d.hk_P = poisson(d.hk_R)
        d.avgvn = poisson(1.734)
        d.avgpNik = 0.265

        ax = plt.subplot(111)
        # best fit of data
        (mu, sigma) = norm.fit(d.hk_P)
        # the histogram of the data
        bins = np.arange(pnmin, pnmax, dpn)
        n, bins, patches = plt.hist(d.hk_P, bins = bins, normed = True,  facecolor='green', alpha=0.75, label='Poisson ratio')

        # add a 'best fit' line
        y = mlab.normpdf( bins, mu, sigma)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plt.axvline(x = d.avgvn, linewidth = 4, color = 'r', label = "Area Weighted\nPoisson Average")
        plt.axvline(x = d.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust\nN. Christensen ('96)")
        plt.title("Cordilleran Orogen - Poisson Ratio Histogram", size = 22)
        plt.xlabel("Poisson Ratio", size = 16)
        plt.ylabel("Probability", size = 16)
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
        arg.addQuery("geoprov", "in", "Cordilleran Orogen")
        m2 = Params(os.environ['HOME'] + '/thesis/data/moonvpGeology.json', arg, ["H","Vp"])

        m.sync(m2)

        #Voronoi average Vp/Vs = 6.289357
        #Voronoi average H = 34.700373
        m.avgvn = 6.40625
        m.avgpNik = 6.454

        # the histogram of the data
        bins = np.arange(vpmin, vpmax, dvp)
        n, bins, patches = plt.hist(m.Vp, bins = bins, normed = True,  facecolor='green', alpha=0.75, label='Mooney Vp')

        # add a 'best fit' line
        y = distfunc(m.Vp, bins)
        plt.plot(bins, y, 'r--', linewidth=2, label='Distribution curve')
        plt.axvline(x = m.avgvn, linewidth = 4, color = 'r', label = "Area Weighted\nMooney Vp")
        plt.axvline(x = m.avgpNik, linewidth = 4, color = 'b', label = "Avg Cont. Crust\nN. Christensen ('96)")
        plt.title("Cordilleran Orogen - Mooney Vp Data", size = 22)
        plt.xlabel("Mooney Vp", size = 16)
        plt.ylabel("Probability", size = 16)
        plt.legend(prop={'size': legsize})
        plt.grid(True)

        for tick in ax2.xaxis.get_major_ticks():
                    tick.label.set_fontsize(14)

        addtext([m.avgvn, m.avgpNik], ax2, n, -120)


    #######################################################################
    # F4
    if plotnum[4]:
        pass

    #######################################################################
    # F5
    if plotnum[5]:
        pass



    for p in plotnum:
        if p:
            plt.show()

