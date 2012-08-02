#include <mex.h>
#include <math.h>
#include <stdlib.h>
#include <matrix.h>
#include <complex.h>


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
