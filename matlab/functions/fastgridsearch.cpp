#include <mex.h>
#include <math.h>
#include <matrix.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{

  //declare variables
  mxArray *recIN, *pslowIN, *TpsIN;
  const mwSize *dims;
  double *rec, *pslow, *Tps, *Vp, *R, *H, *VpRx, *Hx;
  double dt;
  int nrecs;
  int N;

  //associate inputs
  recIN = mxDuplicateArray(prhs[0]);
  TpsIN = mxDuplicateArray(prhs[1]);
  dt = mxGetScalar(prhs[2]);
  pslowIN = mxDuplicateArray(prhs[3]);

  //figure out dimensions
  dims = mxGetDimensions(prhs[0]);
  //numdims = mxGetNumberOfDimensions(prhs[0]);
  N = (int)dims[0];
  nrecs = (int)dims[1];

  // associate outputs
  //    c_out_m = plhs[0] = mxCreateDoubleMatrix(dimy,dimx,mxREAL);
  //    d_out_m = plhs[1] = mxCreateDoubleMatrix(dimy,dimx,mxREAL);
  plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
  plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
  plhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL);
  plhs[3] = mxCreateDoubleMatrix(1, 1, mxREAL);
  plhs[4] = mxCreateDoubleMatrix(1, 1, mxREAL);

  //associate pointers
  rec = mxGetPr(recIN); // Receiver funcs
  pslow = mxGetPr(pslowIN); // slowness
  Tps = mxGetPr(TpsIN); // Main arrival Tps
  Vp = mxGetPr(plhs[0]);
  R = mxGetPr(plhs[1]);
  H = mxGetPr(plhs[2]);
  VpRx = mxGetPr(plhs[3]);
  Hx = mxGetPr(plhs[4]);


  // Grid parameters.
  double adjtpps = 0.7;
  double adjtpss = 0.3;
  int i, ir , iv, ih;

  // P-velocity limits
  int nv = 200;
  double v1 = 5.;
  double v2 = 8.;
  double dv = (v2-v1)/(nv-1);
  double v[nv];

  // R limits
  int nr = 200;
  double r1 = 1.65;
  double r2 = 1.95;
  double dr = (r2-r1)/(nr-1);
  double r[nr];

  // R limits
  int nh = 200;
  double h1 = 25.;
  double h2 = 45.;
  double dh = (h2-h1)/(nh-1);
  double h[nh];

  // Build 1-D arrays
  v[0] = v1;
  r[0] = r1;
  h[0] = h1;
  // This loop only works if nv = nr = nh.
  for(i = 1; i < nv; i++) {
    v[i] = v[i-1] + dv;
    r[i] = r[i-1] + dr;
    h[i] = h[i-1] + dh;
  }

  // Square slowness
  double p2[nrecs];
  for(i = 0; i < nrecs; i++) {
    p2[i] = pslow[i] * pslow[i];
  }

  double f1;
  double f2;
  double tps;
  double tpps;
  double tpss;
  double sumps = 0;
  double sumpps = 0.;
  double sumpss = 0.;
  double stackvr[nv][nr];
  double stackh[nh];

  for(iv = 0; iv < nv; iv++ ) {
    for(ir = 0; ir < nr; ir++ ) {
      for(i = 0; i < nrecs; i++ ) {

        f1 = sqrt( (r[ir]/v[iv]) * (r[ir]/v[iv]) - p2[i] );
        f2 = sqrt( (1/v[iv]) * (1/v[iv]) - p2[i] );
        // Following gets predicted travel times and converts into
        // index by dividing by dt and rounding.
        tpps = round( ( (f1 + f2) / (f1 - f2) ) * Tps[i] / dt );
        tpss = round( 2. * (f1 / (f1 - f2)) * Tps[i] / dt );
        sumpps = sumpps + rec[i * N + (int)tpps];
        sumpss = sumpss + rec[i * N + (int)tpss];

      }
      // add the mean of the two wieghted impulse estimate sums.
      stackvr[iv][ir] = (adjtpps * sumpps - adjtpss * sumpss) / nrecs;
      sumpps = sumpss = 0;

    }
  }

  // Find max value in array
  double max = stackvr[0][0];
  int ind[] = {0, 0};

  for( iv = 0; iv < nv; iv++ ) {
    for( ir = 0; ir < nr; ir++ ) {
      // If we find a value greater than the current max, update max
      if( stackvr[iv][ir] > max ) {
        max = stackvr[iv][ir];
        ind[0] = iv;
        ind[1] = ir;
      }
    }
  }

  // Pick winners
  Vp[0] = v[ ind[0] ];
  R[0] = r[ ind[1] ];
  VpRx[0] = max;


  // Perform gsearch for H
  for(ih = 0; ih < nh; ih++) {
    for(i = 0; i < nrecs; i++) {
      f1 = sqrt( R[0]/Vp[0] * R[0]/Vp[0] - p2[i]);
      f2 = sqrt( 1 / (Vp[0] * Vp[0]) - p2[i] );
      tps = round(h[ih] * (f1 - f2) / dt ) ;
      tpps = round( h[ih] * (f1 + f2) / dt );
      tpss = round( h[ih] * 2. * f1 / dt );
      sumps = sumps + rec[i * N + (int)tps];
      sumpps = sumpps + rec[i * N + (int)tpps];
      sumpss = sumpss + rec[i * N + (int)tpss];
    }
    stackh[ih] = (0.5*sumps + 0.3 * sumpps - 0.2 * sumpss) / nrecs;
    sumps = sumpps = sumpss = 0;
  }

  max = stackh[0];
  for (ih = 0; ih < nh; ih++) {
    if( stackh[ih] > max ) {
      max = stackh[ih];
      ind[0] = ih;
    }
  }

  // Pick winner
  H[0] = h[ ind[0] ];
  Hx[0] = max;

  return;

}
