#include <mex.h>
#include <math.h>
#include <matrix.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{

  //declare variables
  mxArray *recIN, *pslowIN;
  const mwSize *dims;
  double *rec, *pslow, *Tps, *R, *H, *V, *HRx;
  double dt, *stack3d;
  int nrecs, i, ir , ih, iv;
  int N, lim;

  //associate inputs
  recIN = mxDuplicateArray(prhs[0]);
  dt = mxGetScalar(prhs[1]);
  pslowIN = mxDuplicateArray(prhs[2]);
  lim = mxGetScalar(prhs[3]);

  //figure out dimensions
  dims = mxGetDimensions(prhs[0]);
  //numdims = mxGetNumberOfDimensions(prhs[0]);
  N = (int)dims[0];
  nrecs = (int)dims[1];

  // associate outputs
  plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
  plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
  plhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL);
  plhs[3] = mxCreateDoubleMatrix(1, 1, mxREAL);

  //associate pointers
  rec = mxGetPr(recIN);
  pslow = mxGetPr(pslowIN);

  V = mxGetPr(plhs[0]);
  R = mxGetPr(plhs[1]);
  H = mxGetPr(plhs[2]);
  HRx = mxGetPr(plhs[3]); // Output actual value of gridsearch cell for setting contour level


  // Grid parameters.
  double adjtps = 0.5; // Weights chosen from Precambrian crustal evolution - D.A. Thompson
  double adjtpps = 0.3; // I.D. Bastow, G. Helffrich et al.
  double adjtpss = -0.2;

  // R limits
  int nr = lim;
  double r1 = 1.65;
  double r2 = 1.95;
  double dr = (r2 - r1) / ((double) nr - 1.);
  double r[nr];

  // H limits
  int nh = lim;
  double h1 = 25.;
  double h2 = 50.;
  double dh = (h2 - h1) / ((double) nh - 1.);
  double h[nh];

  // V limits
  int nv = lim;
  double v1 = 5.;
  double v2 = 8.;
  double dv = (v2 - v1) / ((double) nv - 1.);
  double v[nv];

  // Build 1-D arrays
  r[0] = r1;
  h[0] = h1;
  v[0] = v1;
  // This loop only works if nv = nr = nh.
  for(i = 1; i < nh; i++) {
    r[i] = r[i-1] + dr;
    h[i] = h[i-1] + dh;
    v[i] = v[i-1] + dv;
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
  double Sps = 0;
  double Spps = 0.;
  double Spss = 0.;
  
  stack3d = (double*) mxMalloc( (nh * nr * nv + 1) * sizeof(double));

  for(ih = 0; ih < nh; ih++ ) {
    for(ir = 0; ir < nr; ir++ ) {
      for(iv = 0; iv < nv; iv++) {
        for(i = 0; i < nrecs; i++ ) {

          f1 = sqrt( (r[ir]/v[iv]) * (r[ir]/v[iv]) - p2[i] );
          f2 = sqrt( (1/v[iv]) * (1/v[iv]) - p2[i] );
          // Following gets predicted travel times and converts into
          // index by dividing by dt and rounding.
          tps = round( h[ih] * (f1 - f2) / dt );
          tpps = round( h[ih] * (f1 + f2) / dt );
          tpss = round( h[ih] * 2. * f1 / dt );
          sumps = sumps + rec[i * N + (int)tps];
          sumpps = sumpps + rec[i * N + (int)tpps];
          sumpss = sumpss + rec[i * N + (int)tpss];
          
          // Semblance Weighting
          Sps += rec[i * N + (int)tps] * rec[i * N + (int)tps];
          Spps += rec[i * N + (int)tpps] * rec[i * N + (int)tpps];
          Spss += rec[i * N + (int)tpss] * rec[i * N + (int)tpss];

        }
        
        Sps = sumps * sumps / Sps;
        Spps = sumpps * sumpps / Spps;
        Spss = sumpss * sumpss / Spss;
        // add the mean of the two wieghted impulse estimate sums.
        stack3d[ih+nr*ir + nr*nv*iv] = (Sps * adjtps * sumps +
                                        Spps * adjtpps * sumpps +
                                        Spss * adjtpss * sumpss) / nrecs;
                
        sumps = sumpps = sumpss = 0;
        Sps = Spps = Spss = 0;

      }
    }
  }

  // Find max value in array
  double max = stack3d[0];
  int ind[] = {0, 0, 0};

  for( ih = 0; ih < nh; ih++ ) {
    for( ir = 0; ir < nr; ir++ ) {
      for( iv = 0; iv < nv; iv++ ) {
        // If we find a value greater than the current max, update max
        if( stack3d[ih + nr * ir + nr * nv * iv] > max ) {
          max = stack3d[ih + nr * ir + nr * nv * iv];
          ind[0] = ih;
          ind[1] = ir;
          ind[2] = iv;
        }
      }
    }
  }

  // Pick winners
  H[0] = h[ ind[0] ];
  R[0] = r[ ind[1] ];
  V[0] = v[ ind[2] ];
  HRx[0] = max;

  mxFree(stack3d);

}
