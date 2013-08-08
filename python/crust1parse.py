#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;
#
# Program to build mooney Crust 2.0 shapefile over Canada
#
###########################################################################
# IMPORTS
###########################################################################
import shapefile, os, json
import numpy as np

fbnds = os.environ['HOME'] + '/thesis/crust1/crust1.bnds'
fvp = os.environ['HOME'] + '/thesis/crust1/crust1.vp'
fvs = os.environ['HOME'] + '/thesis/crust1/crust1.vs'
shapef = os.environ['HOME'] + '/thesis/mapping/crust1/crust1'

def getLatLon():
    lat = np.arange(89.5, -90.5, -1.0)
    lon = np.arange(-179.5, 180.5)

    (Lon, Lat) = np.meshgrid(lon, lat)

    Lat = Lat.flatten()
    Lon = Lon.flatten()

    return (Lat, Lon)




def dotRows(A, B):

    nrows = A.shape[0]
    result = np.empty( (nrows, 1) )
    for i in range(nrows):
        result[i] = np.dot(A[i], B[i])

    return np.squeeze(result)



def toShape(shapef, latlon, H, Vp, R):

    w = shapefile.Writer( shapefile.POLYGON )
    # Set fields for attribute table

    d = 0.5

    w.field("cVp", 'N', 7, 4)
    w.field("cR", 'N', 7, 4)
    w.field("cH", 'N', 7, 4)


    for i in range(latlon.shape[1]):

        lat = latlon[0][i]
        lon = latlon[1][i]
        r = R[i]
        h = H[i]
        vp = Vp[i]

        w.poly( parts = [ [
                    [lon-d, lat+d],
                    [lon+d, lat+d],
                    [lon+d, lat-d],
                    [lon-d, lat-d],
                    [lon-d, lat+d]
                    ]] )

        w.record( "{0:2.4f}".format(vp),
                  "{0:2.4f}".format(r),
                  "{0:2.4f}".format(h))


    w.save(shapef)



class Canada():
    def __init__(self):
        self.latmin = 40.0
        self.latmax = 90.0
        self.lonmin = -150.0
        self.lonmax = -50.0


if __name__== '__main__' :

    cb = Canada()

    (Lat, Lon) = getLatLon()
    mask = np.logical_and( np.logical_and(Lat > cb.latmin , Lat < cb.latmax),
                           np.logical_and(Lon > cb.lonmin , Lon < cb.lonmax))

    latlon = np.vstack((Lat[mask], Lon[mask]))

    # We don't care about vp and vs last columns since it represents VPn
    cut = np.ones(9)
    cut[-1] = 0
    cut = np.array(cut, dtype=bool)

    bnds = np.loadtxt(fbnds, dtype=float)
    bnds = bnds[mask]

    thick = np.abs(np.diff(bnds))

    h = np.sum(thick[:, 2:], axis = 1) # sum without water and ice for (crust+sed thickness)

    thick = thick / np.sum(thick, axis=1)[:, np.newaxis] # turn thick into percentage

    vp = np.loadtxt(fvp, dtype=float)
    vp = vp[mask]
    vp = vp[: , cut]


    vs = np.loadtxt(fvs, dtype=float)
    vs = vs[mask]
    vs = vs[: , cut]


    vp = dotRows(vp, thick)
    vs = dotRows(vs, thick)

    r = vp / vs

    toShape( shapef, latlon, h, vp, r)

#    open(c2jfile,'w').write( json.dumps(jdict, indent = 2 ))
