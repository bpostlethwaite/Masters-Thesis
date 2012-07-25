#include <mex.h>
#include <math.h>
#include <stdlib.h>
#include <matrix.h>


void gridSearch(double *rec, double *p2, double *Tps, double dt,
                int N, int nrecs, double *Vp, double *R, double *H,
                double *VpRx, double *Hx, int iter)
{

  // Grid parameters.
  double adjtpps = 0.7;
  double adjtpss = 0.3;
  int i, ir , iv, ih;

  // Setup bootstrap routine ///////////////////////////
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
  Vp[iter] = v[ ind[0] ];
  R[iter] = r[ ind[1] ];
  VpRx[iter] = max;

  // Perform gsearch for H
  for(ih = 0; ih < nh; ih++) {
    for(i = 0; i < nrecs; i++) {
      f1 = sqrt( R[iter]/Vp[iter] * R[iter]/Vp[iter] - p2[i]);
      f2 = sqrt( 1 / (Vp[iter] * Vp[iter]) - p2[i] );
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
  H[iter] = h[ ind[0] ];
  Hx[iter] = max;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{

  //declare variables
  mxArray *recIN, *pslowIN, *TpsIN, *A, *B, *C, *D;
  const mwSize *dims;
  double *rec, *pslow, *Tps, *Vp, *R, *H, *rrec, *rTps, *rp2, *ran;
  double *VpRx, *Hx;
  double dt;
  int niter, N, nrecs, k, rseed;
  mwSize i, j;

  //figure out dimensions
  dims = mxGetDimensions(prhs[0]);
  //numdims = mxGetNumberOfDimensions(prhs[0]);
  N = (int)dims[0];
  nrecs = (int)dims[1];

  // random matrices
  //  double rTps[ nrecs ];
  //double p2[ nrecs ] ;
  //double rrec[N * nrecs];
  //int ran[niter];

  //associate inputs
  recIN = mxDuplicateArray(prhs[0]);
  TpsIN = mxDuplicateArray(prhs[1]);
  dt = mxGetScalar(prhs[2]);
  pslowIN = mxDuplicateArray(prhs[3]);
  niter = mxGetScalar(prhs[4]);
  rseed = mxGetScalar(prhs[5]);

  // associate outputs
  plhs[0] = mxCreateDoubleMatrix(1, niter, mxREAL);
  plhs[1] = mxCreateDoubleMatrix(1, niter, mxREAL);
  plhs[2] = mxCreateDoubleMatrix(1, niter, mxREAL);
  plhs[3] = mxCreateDoubleMatrix(1, niter, mxREAL);
  plhs[4] = mxCreateDoubleMatrix(1, niter, mxREAL);

  //associate pointers
  rec = mxGetPr(recIN);
  pslow = mxGetPr(pslowIN);
  Tps = mxGetPr(TpsIN);
  Vp = mxGetPr( plhs[0] );
  R = mxGetPr( plhs[1] );
  H = mxGetPr( plhs[2] );
  VpRx = mxGetPr(plhs[3]);
  Hx = mxGetPr(plhs[4]);


  A = mxCreateDoubleMatrix(1, N * nrecs, mxREAL);
  B = mxCreateDoubleMatrix(1, nrecs, mxREAL);
  C = mxCreateDoubleMatrix(1, nrecs, mxREAL);
  D = mxCreateDoubleMatrix(1, nrecs, mxREAL);

  rrec = mxGetPr(A);
  rp2 = mxGetPr(B);
  rTps = mxGetPr(C);
  ran = mxGetPr(D);

  srand(rseed); // Seed with unique ID from matlab parloop

  for(k = 0; k < niter; k++) {
    // Build random index array
    for(i = 0; i < nrecs; i++) {
      ran[i] = ( (double)rand() / RAND_MAX * nrecs);
    }

    // Create new matrices from randomly selected columns of data
    for(j = 0; j < nrecs ; j++) {
      for( i = 0; i < N; i++) {
        *(rrec + j * N + i) = *(rec + (int) ran[j] * N + i );
      }
      rTps[j] = Tps[ (int) ran[j] ];
      rp2[j] = pslow[ (int) ran[j] ] * pslow[ (int) ran[j] ];
    }


    gridSearch(rrec, rp2, rTps, dt, N, nrecs, Vp, R, H, VpRx, Hx, k);

  }

  return;
}
