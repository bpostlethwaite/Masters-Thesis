#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
###########################################################################
# IMPORTS
###########################################################################
import os, json
import numpy as np
import matplotlib.pyplot as plt
from plotTools import Args, Params
from scipy.stats import pearsonr, spearmanr


stnfile = os.environ['HOME'] + '/thesis/data/stations.json'
csfile = os.environ['HOME'] + '/thesis/data/csStations.json'


def meanDifference(x, y):
    assert (len(x) == len(y))
    n = len(x)
    md = 0
    for i in range(n):
        md += abs(x[i] - y[i])

    return md/(n)


def princomp(A,numpc=0):
     # computing eigenvalues and eigenvectors of covariance matrix
    C = np.dot(A, A.T) / A.shape[1]
    [eigValue,eigVect] = np.linalg.eig( C )
    p = np.size(eigVect,axis=1)
    idx = np.argsort(eigValue) # sorting the eigenvalues
    idx = idx[::-1]       # in ascending order
    # sorting eigenvectors according to the sorted eigenvalues
    eigVect = eigVect[:,idx]
    eigValue = eigValue[idx] # sorting eigenvalues
    if numpc < p or numpc >= 0:
        eigVect = eigVect[:,range(numpc)] # cutting some PCs
        score = np.dot(eigVect, A) # projection of the data in the new space
        return eigVect, score, eigValue, C

def getPCAvect(pc, xscale):
    yb = pc[1] #+ am[1]
    xb = pc[0] #+ am[0]
    slope = -pc[1] / pc[0]
    ypt = np.array([slope * xscale[0], slope * xscale[1]]) #+ 1.2
    return xscale, ypt


# def getPCAvect(pc, xscale):
#     yb = pc[1] #+ am[1]
#     xb = pc[0] #+ am[0]
#     slope = -pc[1] / pc[0]
#     b = yb - slope * xb
#     ypt = np.array([slope * xscale[0] + b, slope * xscale[1] + b]) #+ 1.2
#     return xscale, ypt


if __name__  == "__main__":


    ## Figure Properties #######
    figwidth = 12
    figheight = figwidth / 1.618
    ratio = 1.5
    lw = 4 / ratio# line width
    ms = 12 / ratio# marker size
    caplen = 7 / ratio
    capwid = 2 / ratio
    elw = 2 / ratio
    ticks = 16 / ratio
    label = 16 / ratio
    title = 18 / ratio
    leg = 16 / ratio


    #############################################################################
    # FIG 1: Vp estimates against H
    ##############################################################################

    if 0:
        f = Params(stnfile, ["fg::H","fg::Vp", "fg::stdVp", "hk::stdR"])

        corrfg = pearsonr(f.fg_Vp, f.fg_H)
        print "FG: Vp vs H: {} stations, correlation = {}".format(len(f.stns), corrfg[0])


        A = np.vstack( (f.fg_H, f.fg_Vp) )
        M = (A.T - np.mean(A,1)).T
        M[0] = M[0] /  np.std(M,1)[0]
        M[1] = M[1] /  np.std(M,1)[1]
        eigVect, pcomp, eigValue, C = princomp(M, 2)

        var = np.sum(pcomp * pcomp, axis = 1)
        var /= np.sum(var)

        print "variance of components is {}".format(var)

        hmin = np.min(M[0])
        hmax = np.max(M[0])
        xscale = [hmin, hmax]
        x1, y1 = getPCAvect(eigVect[1], xscale)
        x2, y2 = getPCAvect(eigVect[0], xscale)

        fig = plt.figure( figsize = (figwidth, figheight) )
        plt.plot(M[0], M[1], 'ob', lw = lw, ms = ms, label = "normalized Vp vs H")
        plt.plot(x2, y2,'--r', lw = lw, label="Primary PCA: variance = {:2.1f}%".format(var[0]*100))
        plt.plot(x1, y1,'--g', lw = lw, label="Secondary PCA: variance = {:2.1f}%".format(var[1]*100))

        plt.legend(loc= 2, prop={'size': leg})
        plt.ylabel("normalized Vp", size = label)
        plt.xlabel("normalized H", size = label)
        plt.grid(True)
        plt.axis("equal")

    #############################################################################
    # FIG 2: Vp estimates and controlled source
    ##############################################################################
    if 0:
        maxerr = 0.25#0.24#0.21
        arg = Args().addQuery("fg::stdVp", "lt", str(maxerr))
        f = Params(stnfile, ["fg::H","fg::Vp", "fg::stdH", "fg::stdVp", "hk::stdR"], arg)

        c = Params(csfile, ["H","Vp"])
        c.sync(f)

        stdVp = 2 * f.fg_stdVp # 2 stdError
        stdH = 2 * f.fg_stdH
        t = np.arange(len(f.fg_Vp))

        corr = pearsonr(f.fg_Vp, c.Vp)
        print "Active Source vs FG Vp with {} stations: correlation = {}".format(len(f.stns), corr[0])


        fig = plt.figure()
        ax1 = fig.add_subplot(111)


        l1=ax1.plot(t, f.fg_Vp, '-ob', lw = lw, ms = ms, label = "Full Gridsearch Vp estimate")
        l2=ax1.errorbar(t, f.fg_Vp, yerr=stdVp, xerr=None, fmt=None, ecolor = 'blue',
                     elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std dev Bootstrap")
        l3=ax1.plot(t, c.Vp, ':ob', lw = lw, ms = ms, label = "Proximal active source Vp estimate")
        ax1.set_xlabel('stations', color='b')
        ax1.set_ylabel('Vp [km]', color='b')
        for tl in ax1.get_yticklabels():
            tl.set_color('b')

        for tick in ax1.xaxis.get_major_ticks():
            tick.label.set_fontsize( ticks )
            # specify integer or one of preset strings, e.g.
            #tick.label.set_fontsize('x-small')
            tick.label.set_rotation('vertical')


        plt.xticks(t, c.stns, size = ticks)



        ax2 = ax1.twinx()

        l4=ax2.plot(t, f.fg_H, '-or', lw = lw, ms = ms, label = "Full Gridsearch H estimate")
        l5=ax2.errorbar(t, f.fg_H, yerr=stdH, xerr=None, fmt=None, ecolor = 'red',
                     elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std dev Bootstrap")
        l6=ax2.plot(t, c.H, ':or', lw = lw, ms = ms, label = "Proximal active source H estimate")

        ax2.set_ylabel('H [km]', color='r')
        for tl in ax2.get_yticklabels():
            tl.set_color('r')

        # added these three lines
        lns = l1+l3+l4+l6
        labs = [l.get_label() for l in lns]
        ax1.legend(lns, labs, loc=0, prop={'size': leg})

        plt.grid(True)



########################
    if 1:

        maxerr = 0.21#0.24#0.21
        arg = Args().addQuery("fg::stdVp", "lt", str(maxerr))
        f = Params(stnfile, ["fg::H","fg::Vp", "fg::stdH", "fg::stdVp", "hk::stdR"], arg)
        w = Params(stnfile, ["wm::Vp","wm::H"])


        c = Params(csfile, ["H","Vp"])
        c.sync(f)

        w.sync(c)

        stdVp = 2 * f.fg_stdVp # 2 stdError
        stdH = 2 * f.fg_stdH
        t = np.arange(len(f.fg_Vp))

        corr = pearsonr(f.fg_Vp, c.Vp)
        print "Active Source vs FG Vp with {} stations: correlation = {}".format(len(f.stns), corr[0])

        md = meanDifference(f.fg_Vp, c.Vp)
        print "Active Source vs FG Vp with {} stations: Mean Difference = {}".format(len(f.stns), md)

        fig = plt.figure( figsize = (figwidth, figheight) )
        ax = plt.subplot(111)

        plt.plot(t, f.fg_Vp, '-ob', lw = lw, ms = ms, label = "Full Gridsearch Vp estimate")
        plt.errorbar(t, f.fg_Vp, yerr=stdVp, xerr=None, fmt=None, ecolor = 'blue',
                     elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std dev Bootstrap")
        plt.plot(t, c.Vp, '-og', lw = lw, ms = ms, label = "Proximal active source estimate")
        plt.plot(t, w.wm_Vp, '-or', lw = lw, ms = ms, label = "Crust 2.0 Vp estimate")

        plt.axis("tight")

        for tick in ax.xaxis.get_major_ticks():
            tick.label.set_fontsize( ticks )
            # specify integer or one of preset strings, e.g.
            #tick.label.set_fontsize('x-small')
            tick.label.set_rotation('vertical')

        plt.xticks(t, c.stns, size = ticks)
        plt.grid(True)

        plt.legend(prop={'size': leg})
        plt.xlabel("Stations", size = label)
        plt.ylabel("Vp [km/s]", size = label)



        fig = plt.figure( figsize = (figwidth, figheight) )
        ax = plt.subplot(111)


        plt.plot(t, f.fg_H, '-ob', lw = lw, ms = ms, label = "Full Gridsearch H estimate")
        plt.errorbar(t, f.fg_H, yerr=stdH, xerr=None, fmt=None, ecolor = 'blue',
                     elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std dev Bootstrap")
        plt.plot(t, c.H, '-og', lw = lw, ms = ms, label = "Proximal active source estimate")
        plt.plot(t, w.wm_H, '-or', lw = lw, ms = ms, label = "Crust 2.0 H estimate")


        for tick in ax.xaxis.get_major_ticks():
            tick.label.set_fontsize( ticks )
            # specify integer or one of preset strings, e.g.
            #tick.label.set_fontsize('x-small')
            tick.label.set_rotation('vertical')

        plt.xticks(t, c.stns, size = ticks)
        plt.grid(True)


        plt.legend(prop={'size': leg})
        plt.xlabel("Stations", size = label)
        plt.ylabel("H [km]", size = label)
        plt.axis("tight")

#############################################################################
    # FIG 3: FG Vp/Vs versus Kan Vp/Vs
    ##############################################################################
    if 0:
        f = Params(stnfile, ["fg::H","fg::R", "fg::stdR", "fg::stdH", "fg::Vp"])
        k = Params(stnfile, ["hk::H","hk::R", "hk::stdR", "hk::stdH", "wm::Vp"])

        maxerr = 0.06
        f.filter(Args().addQuery("fg::stdR", "lt", str(maxerr)))
        k.sync(f)

        stdR = 2 * f.fg_stdR # 2 stdError
        t = np.arange(len(f.fg_R))

        corr = pearsonr(f.fg_R, k.hk_R)
        print "FullGrid to ZK R with stddev limit {} and {} stations, correlation = {}".format(maxerr, len(k.stns), corr[0])

        fig = plt.figure( figsize = (figwidth, figheight) )
        ax = plt.subplot(111)

        plt.plot(t, f.fg_R, '-ob', lw = lw, ms = ms, label = "Full Gridsearch Vp/Vs estimate")
        plt.errorbar(t, f.fg_R, yerr= stdR, xerr=None, fmt=None, ecolor = 'blue',
                     elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std dev Bootstrap")
        plt.plot(t, k.hk_R, '-og', lw = lw, ms = ms, label = "ZK Vp/Vs estimate")
        plt.errorbar(t, k.hk_R, yerr=2 * k.hk_stdR, xerr=None, fmt=None, ecolor = 'green',
                     elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std dev Bootstrap")

        plt.legend(prop={'size': leg})
        plt.xlabel("Stations", size = label)
        plt.ylabel("Vp/Vs", size = label)

        plt.axis("tight")

        for tick in ax.xaxis.get_major_ticks():
            tick.label.set_fontsize( ticks )
            # specify integer or one of preset strings, e.g.
            #tick.label.set_fontsize('x-small')
            tick.label.set_rotation('vertical')

        plt.xticks(t, k.stns, size = ticks)
        plt.grid(True)

        #############################################################################
        # FIG 4: FG H versus Kan H
        ##############################################################################

        stdH = 2 * f.fg_stdH # 2 stdError
        t = np.arange(len(f.fg_H))

    #    f.fg_H = f.fg_H / f.fg_Vp
    #    k.hk_H = k.hk_H / k.wm_Vp

        corr = pearsonr(f.fg_H, k.hk_H)
        print "FullGrid to ZK H with stddev limit {} and {} stations, correlation = {}".format(maxerr, len(k.stns), corr[0])

        fig = plt.figure( figsize = (figwidth, figheight) )
        ax = plt.subplot(111)

        plt.plot(t, f.fg_H, '-ob', lw = lw, ms = ms, label = "Full Gridsearch H estimate")
        plt.errorbar(t, f.fg_H, yerr= stdH, xerr=None, fmt=None, ecolor = 'blue',
                     elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std dev Bootstrap")
        plt.plot(t, k.hk_H, '-og', lw = lw, ms = ms, label = "ZK H estimate")
        plt.errorbar(t, k.hk_H, yerr=2 * k.hk_stdH, xerr=None, fmt=None, ecolor = 'green',
                     elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std dev Bootstrap")

        plt.legend(prop={'size': leg})
        plt.xlabel("Stations", size = label)
        plt.ylabel("H [km]", size = label)

        plt.axis("tight")

        for tick in ax.xaxis.get_major_ticks():
            tick.label.set_fontsize( ticks )
            # specify integer or one of preset strings, e.g.
            #tick.label.set_fontsize('x-small')
            tick.label.set_rotation('vertical')

        plt.xticks(t, k.stns, size = ticks)
        plt.grid(True)



    plt.show()
