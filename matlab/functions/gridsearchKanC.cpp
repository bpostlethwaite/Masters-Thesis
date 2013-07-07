#include <mex.h>
#include <math.h>
#include <matrix.h>


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{

  //declare variables
  mxArray *recIN, *pslowIN;
  const mwSize *dims;
  double *rec, *pslow, *Tps, *R, *H, *HRx;
  double dt, v;
  int nrecs;
  int N;

  //associate inputs
  recIN = mxDuplicateArray(prhs[0]);
  dt = mxGetScalar(prhs[1]);
  pslowIN = mxDuplicateArray(prhs[2]);
  v = mxGetScalar(prhs[3]);

  //figure out dimensions
  dims = mxGetDimensions(prhs[0]);
  //numdims = mxGetNumberOfDimensions(prhs[0]);
  N = (int)dims[0];
  nrecs = (int)dims[1];

  // associate outputs
  plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
  plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
  plhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL);

  //associate pointers
  rec = mxGetPr(recIN);

  pslow = mxGetPr(pslowIN);
  R = mxGetPr(plhs[0]);
  H = mxGetPr(plhs[1]);
  HRx = mxGetPr(plhs[2]); // Output actual value of gridsearch cell for setting contour level

  // Grid parameters.
  double adjtps = 0.5; // Weights chosen from Precambrian crustal evolution - D.A. Thompson
  double adjtpps = 0.3; // I.D. Bastow, G. Helffrich et al.
  double adjtpss = -0.2;
  int i, ir , ih;

  // R limits
  int nr = 200;
  double r1 = 1.65;
  double r2 = 1.95;
  double dr = (r2-r1)/(nr-1);
  double r[nr];

  // H limits
  int nh = 200;
  double h1 = 25.;
  double h2 = 50.;
  double dh = (h2-h1)/(nh-1);
  double h[nh];

  // Build 1-D arrays
  r[0] = r1;
  h[0] = h1;
  // This loop only works if nv = nr = nh.
  for(i = 1; i < nh; i++) {
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
  double Sps = 0;
  double Spps = 0.;
  double Spss = 0.;
  double stackhr[nh][nr];

  for(ih = 0; ih < nh; ih++ ) {
    for(ir = 0; ir < nr; ir++ ) {
      for(i = 0; i < nrecs; i++ ) {

        f1 = sqrt( (r[ir]/v) * (r[ir]/v) - p2[i] );
        f2 = sqrt( (1/v) * (1/v) - p2[i] );
        // Following gets predicted travel times and converts into
        // index by dividing by dt and rounding.
        tps = round( h[ih] * (f1 - f2) / dt );
        tpps = round( h[ih] * (f1 + f2) / dt );
        tpss = round( h[ih] * 2. * f1 / dt );
        sumps += rec[i * N + (int)tps];
        sumpps += rec[i * N + (int)tpps];
        sumpss += rec[i * N + (int)tpss];
        
        // Semblance Weighting
        Sps += rec[i * N + (int)tps] * rec[i * N + (int)tps];
        Spps += rec[i * N + (int)tpps] * rec[i * N + (int)tpps];
        Spss += rec[i * N + (int)tpss] * rec[i * N + (int)tpss];
         
      }
      
      Sps = sumps * sumps / Sps;
      Spps = sumpps * sumpps / Spps;
      Spss = sumpss * sumpss / Spss;
      
      // add the mean of the two wieghted impulse estimate sums.
      stackhr[ih][ir] = (Sps * adjtps * sumps +
                         Spps * adjtpps * sumpps +
                         Spss * adjtpss * sumpss) / nrecs;
      sumps = sumpps = sumpss = 0;
      Sps = Spps = Spss = 0;

    }
  }

  // Find max value in array
  double max = stackhr[0][0];
  int ind[] = {0, 0};

  for( ih = 0; ih < nh; ih++ ) {
    for( ir = 0; ir < nr; ir++ ) {
      // If we find a value greater than the current max, update max
      if( stackhr[ih][ir] > max ) {
        max = stackhr[ih][ir];
        ind[0] = ih;
        ind[1] = ir;
      }
    }
  }

  // Pick winners
  H[0] = h[ ind[0] ];
  R[0] = r[ ind[1] ];
  HRx[0] = max;

  return;

}
