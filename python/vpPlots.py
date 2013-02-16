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

def princomp(A,numpc=0):
     # computing eigenvalues and eigenvectors of covariance matrix
    M = (A - np.mean(A.T,axis=1)).T # subtract the mean (along columns)
    [latent,coeff] = np.linalg.eig( np.cov(M))
    p = np.size(coeff,axis=1)
    idx = np.argsort(latent) # sorting the eigenvalues
    idx = idx[::-1]       # in ascending order
    # sorting eigenvectors according to the sorted eigenvalues
    coeff = coeff[:,idx]
    latent = latent[idx] # sorting eigenvalues
    if numpc < p or numpc >= 0:
        coeff = coeff[:,range(numpc)] # cutting some PCs
        score = np.dot(coeff.T, M) # projection of the data in the new space
        return coeff, score, latent

if __name__  == "__main__":

    m = Params(stnfile, ["mb::H","mb::Vp", "mb::stdVp", "hk::stdR"])
    # m = Params(stnfile, ["hk::H","hk::R", "hk::stdR"])
    # m.mb_H = m.hk_H
    # m.mb_Vp = m.hk_R

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

    ###########################


    #############################################################################
    # Vp estimates against H
    ##############################################################################
    A = np.vstack( (m.mb_H, m.mb_Vp) )

    coeff, score, latent = princomp(A.T, 2)
    am = np.mean(A, axis = 1)

    var = np.sum(score * score, axis = 1)
    var /= np.sum(var)

    pc = coeff[0]
    yb = pc[1] + am[1]
    xb = pc[0] + am[0]

    slope = -pc[1] / pc[0]
    b = yb - slope * xb
    hmin = np.min(m.mb_H)
    hmax = np.max(m.mb_H)
    xpt = [hmin, hmax]
    ypt = np.array([slope * xpt[0] + b, slope * xpt[1] + b])

    fig = plt.figure( figsize = (figwidth, figheight) )
    plt.plot(m.mb_H, m.mb_Vp, 'ob', lw = lw, ms = ms, label = "Bostock (2010) Vp against H estimate")
    plt.plot(xpt, ypt,'--r', lw = lw, label="Principal Component Vector")
#    plt.plot([0, coeff[1,0] * 2] + am[0], [0, coeff[1,1]*2] + am[1],'--k', lw = 4)

    plt.title("Correlated Error in Dataset: Moving up the Vp, H Trade Off Curve", size = 18)
    plt.legend(loc= 2, prop={'size': leg})
    plt.ylabel("Station Vp [km/s]", size = label)
    plt.xlabel("Station Thickness H [km]", size = label)
    plt.grid(True)


    #############################################################################
    # Vp estimates and controlled source
    ##############################################################################

#    arg = Args().stations(["ALE","ALGO","ARVN","BANO","CBRQ","DAWY","DELO","FCC","FFC","HAL","KGNO","KSVO","LMN","MBC","MNT","MOBC","ORIO","PEMO","PGC","PLVO","PMB","PTCO","SJNN","SUNO","ULM","ULM2","WAPA ","WHY","WSLR ","YKW1","YOSQ"])
#    m.filter(arg)
    m.filter(Args().addQuery("mb::Vp", "gt", "5.5"))
    m.filter(Args().addQuery("mb::Vp", "lt", "7.0"))

    c = Params(csfile, ["H","Vp"])
    c.sync(m)

    stdVp = 2 * m.mb_stdVp # 2 stdError
    t = np.arange(len(m.mb_Vp))

    corr = pearsonr(m.mb_Vp, c.Vp)
    print "correlation = {}".format(corr[0])

    fig = plt.figure( figsize = (figwidth, figheight) )
    ax = plt.subplot(111)

    plt.plot(t, m.mb_Vp, '-ob', lw = lw, ms = ms, label = "Bostock (2010) Vp estimate")
    plt.errorbar(t, m.mb_Vp, yerr=stdVp, xerr=None, fmt=None, ecolor = 'blue',
                 elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std dev Bootstrap")
    plt.plot(t, c.Vp, '-og', lw = lw, ms = ms, label = "Proximal active source estimate")
#   plt.title("Active Source P-wave velocity comparison\n Correlation = {0:2.3f}".format(corr[0]), size = title)
    plt.legend(prop={'size': leg})
    plt.xlabel("Stations", size = label)
    plt.ylabel("Vp [km/s]", size = label)

    plt.axis("tight")

    for tick in ax.xaxis.get_major_ticks():
        tick.label.set_fontsize( ticks )
        # specify integer or one of preset strings, e.g.
        #tick.label.set_fontsize('x-small')
        tick.label.set_rotation('vertical')

    plt.xticks(t, c.stns, size = ticks)
    plt.grid(True)

    # #############################################################################
    # # Select Vp estimates against H
    # ##############################################################################
    # fig = plt.figure( figsize = (width, height) )
    # plt.plot(m.mb_Vp, m.mb_H, 'ob', lw = 4, ms = 12, label = "Bostock (2010) Vp against H estimate")
    # # plt.errorbar(t, m.mb_Vp, yerr=stdVp, xerr=None, fmt=None, ecolor = 'blue',
    # #              elinewidth = 2, capsize = 7, mew = 2, label = "2 std dev Bootstrap")
    # # plt.plot(t, c.Vp, '-og', lw = 4, ms = 12, label = "Proximal Controlled Source estimate")
    # plt.title("Correlated Error: Moving up the Vp, H Trade Off Curve", size = 18)
    # plt.legend()
    # plt.xlabel("Vp [km/s]")
    # plt.ylabel("Thickness H [km]")
    # plt.grid(True)

    # #############################################################################
    # # MB Vp/Vs versus Kan Vp/Vs
    # ##############################################################################
    m = Params(stnfile, ["mb::H","mb::R", "mb::stdR"])
    k = Params(stnfile, ["hk::H","hk::R", "hk::stdR"])

    maxerr = 0.01
    m.filter(Args().addQuery("mb::stdR", "lt", str(maxerr)))
#    k.filter

    k.sync(m)

    stdR = 2 * m.mb_stdR # 2 stdError
    t = np.arange(len(m.mb_R))

    corr = pearsonr(m.mb_R, k.hk_R)
    print "with stddev limit {} and {} stations, correlation = {}".format(maxerr, len(k.stns), corr[0])

    fig = plt.figure( figsize = (figwidth, figheight) )
    ax = plt.subplot(111)

    plt.plot(t, m.mb_R, '-ob', lw = lw, ms = ms, label = "Bostock (2010) Vp/Vs estimate")
    plt.errorbar(t, m.mb_R, yerr= stdR, xerr=None, fmt=None, ecolor = 'blue',
                 elinewidth = elw, capsize = caplen, mew = capwid, label = "2 std dev Bootstrap")
    plt.plot(t, k.hk_R, '-og', lw = lw, ms = ms, label = "Kanamori Vp/Vs estimate")
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



    plt.show()
