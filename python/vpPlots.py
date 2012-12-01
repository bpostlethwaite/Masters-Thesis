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

    m = Params(stnfile, ["mb::H","mb::Vp", "mb::stdVp"])
    # m = Params(stnfile, ["hk::H","hk::R", "hk::stdR"])
    # m.mb_H = m.hk_H
    # m.mb_Vp = m.hk_R

    ## Figure Properties #######
    width = 12
    height = 9
    legsize = width + 3
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


    #print xpt, ypt

    fig = plt.figure( figsize = (width, height) )
    plt.plot(m.mb_H, m.mb_Vp, 'ob', lw = 4, ms = 12, label = "Bostock (2010) Vp against H estimate")
    plt.plot(xpt, ypt,'--r', lw = 4, label="Principal Component Vector")
#    plt.plot([0, coeff[1,0] * 2] + am[0], [0, coeff[1,1]*2] + am[1],'--k', lw = 4)

    plt.title("Correlated Error in Dataset: Moving up the Vp, H Trade Off Curve", size = 18)
    plt.legend(loc= 2)
    plt.ylabel("Station Vp [km/s]")
    plt.xlabel("Station Thickness H [km]")
    plt.grid(True)


    #############################################################################
    # Vp estimates and controlled source
    ##############################################################################
    arg = Args().stations(["ALE","ALGO","ARVN","BANO","CBRQ","DAWY","DELO","FCC","FFC","HAL","KGNO","KSVO","LMN","MBC","MNT","MOBC","ORIO","PEMO","PGC","PLVO","PMB","PTCO","SJNN","SUNO","ULM","ULM2","WAPA ","WHY","WSLR ","YKW1","YOSQ"])
    m.filter(arg)
    m.filter(Args().addQuery("mb::Vp", "gt", "5.5"))
    m.filter(Args().addQuery("mb::stdVp", "lt", "0.8"))

    c = Params(csfile, ["H","Vp"])
    c.sync(m)

    stdVp = 2 * m.mb_stdVp # 2 stdError
    t = np.arange(len(m.mb_Vp[0:11]))

    corr = spearmanr(m.mb_Vp[0:11], c.Vp[0:11])
    fig = plt.figure( figsize = (width, height) )
    plt.plot(t, m.mb_Vp[0:11], '-ob', lw = 4, ms = 12, label = "Bostock (2010) Vp estimate")
    plt.errorbar(t, m.mb_Vp[0:11], yerr=stdVp[0:11], xerr=None, fmt=None, ecolor = 'blue',
                 elinewidth = 2, capsize = 7, mew = 2, label = "2 std dev Bootstrap")
    plt.plot(t, c.Vp[0:11], '-og', lw = 4, ms = 12, label = "Proximal active source estimate")
    plt.title("Active Source P-wave velocity comparison\n Correlation = {0:2.3f}".format(corr[0]), size = 18)
    plt.legend()
    plt.xlabel("Stations")
    plt.ylabel("Vp [km/s]")
    plt.xticks(t, c.stns[0:11], size = 12)
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



    plt.show()
