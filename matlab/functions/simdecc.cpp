#include <mex.h>
#include <math.h>
#include <matrix.h>

/* computational subroutine */
void decon( double *wr, double *wi,
            double *vr, double *vi,
            double *rr, double *ri,
            double *xr, double *xi,
            size_t n,  size_t m, double *betax)

{
  mwSize i, j, k, ind;
  double *wwr, *wwi, *vwr, *vwi;
  double *nr, *ni, *beta, *gcvf;
  double betaMin, betaMax, betai, norm;
  double denom, misfit, ming, inf;
  size_t betaRange;

  // Beta range paramters
  betaRange = 111;
  betaMax = 50.0;
  betaMin = -5.0;
  betai = (betaMax - betaMin) / (double) betaRange;
  inf = mxGetInf();

  // Allocate memory to arrays
  wwr = (double*) mxMalloc( (n) * sizeof(double));
  wwi = (double*) mxMalloc( (n) * sizeof(double));
  vwr = (double*) mxMalloc( (n) * sizeof(double));
  vwi = (double*) mxMalloc( (n) * sizeof(double));
  nr = (double*) mxMalloc( (n) * sizeof(double));
  ni = (double*) mxMalloc( (n) * sizeof(double));
  beta = (double*) mxMalloc( (betaRange) * sizeof(double));
  gcvf = (double*) mxMalloc( (betaRange) * sizeof(double));

  // Initialize arrays
  for( j = 0; j < n; j++) {
    wwr[j] = wwi[j] = vwr[j] = vwi[j] = 0;
  }

  // Set up Beta Value
  for ( i = 0; i < betaRange; i++ ) {
    beta[i] = exp( betaMin + (double) i * betai );
  }
  // Take complex conjugate to get denominators of GCV
  // y = z * conj(z)
  for( i = 0; i < m; i++) {
    for( j = 0; j < n; j++) {
      wwr[j] += wr[i*n + j] * wr[i*n + j] + wi[i*n + j] * wi[i*n + j]; //x^2 + y^2
      //wwi[j] += 0's
      vwr[j] += vr[i*n + j] * wr[i*n + j] + vi[i*n + j] * wi[i*n + j]; // xa + by
      vwi[j] += wr[i*n + j] * vi[i*n + j] + -(wi[i*n + j]) * vr[i*n + j]; // xb + ya
    }
  }

  // Define operator W W* / (W W* + B) and deconvolve to get impulse response in
  // frequency domain.
  // Main loop through all beta values
  for( k = 0; k < betaRange; k++) {
    misfit = 0;

    for( i = 0; i < n; i++) {
      rr[i] = vwr[i] / ( wwr[i] + beta[k] );
      ri[i] = vwi[i] / ( wwi[i] );
      xr[i] = wwr[i] / ( wwr[i] + beta[k] );
      xi[i] = wwi[i] / ( wwi[i] );
    }

    // Compute norm and misfit
    // Note misfit is also NUMERATOR of GCV
    for (i = 0; i < m; i++) {
      norm = 0;
      for (j = 0; j < n; j++) {
        nr[j] = vr[i * n + j] - wr[i * n + j] * rr[j] + wi[i * n + j] * ri[j];
        ni[j] = vi[i * n + j];
        norm += nr[j] * nr[j] + ni[j] * ni[j];
      }
      misfit += norm;
    }

    // Compute GCV
    denom = double (n * m);
    for (i = 0; i < n; i++) {
      denom -= xr[i];
    }
    denom *= denom;

    gcvf[k] = misfit / denom;
  } // End Beta Loop

  // Compute best beta = betax by finding minimum
  ming = gcvf[0];
  for(i = 0; i < betaRange; i++) {
    if( gcvf[i] < ming ) {
      ming = gcvf[i];
      ind = i;
    }
  }

  if( ind == 0 ) {
    *betax = -(inf);
  }
  else if ( ind == (betaRange - 1) ) {
    *betax = inf;
  }
  else {
    *betax = beta[ind];
    for( i = 0; i < n; i++) {
      rr[i] = vwr[i] / ( wwr[i] + *betax );
      ri[i] = vwi[i] / ( wwi[i] );
      xr[i] = wwr[i] / ( wwr[i] + *betax );
      xi[i] = wwi[i] / ( wwi[i] );
    }
  }

  mxFree(wwr);
  mxFree(wwi);
  mxFree(vwr);
  mxFree(vwi);
  mxFree(nr);
  mxFree(ni);
  mxFree(beta);
  mxFree(gcvf);
}

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[] )
{

  // SIMDECC Simultaneous deconvolution of multiple seismograms in
  // the frequency domain. Inputs are complex wavelet estimates WR WI,
  // complex data VR (both in frequency domain and of dimension M X N where
  // M is number of seismograms and N is number of frequencies).
  // An optimum parameter BETAx is sought using Generalized Cross
  // Validation and used to produce impulse response RFT, and model
  // resolution kernel XFT. If BETAx is set to INF, it means no minimum
  // was found.


  //declare variables
  double *wr, *wi, *vr, *vi;
  double *rr, *ri, *xr, *xi;
  double *betax;
  size_t m, n;

  /* check for the proper number of arguments */
  if(nrhs != 2)
    mexErrMsgIdAndTxt( "MATLAB:simdecc:invalidNumInputs",
                       "Two inputs required.");
  if(nlhs > 3)
    mexErrMsgIdAndTxt( "MATLAB:simdecc:maxlhs",
                       "Too many output arguments.");
  /* Check that both inputs are complex*/
  if( !mxIsComplex(prhs[0]) || !mxIsComplex(prhs[1]) )
    mexErrMsgIdAndTxt( "MATLAB:simdecc:inputsNotComplex",
                       "Inputs must be complex.\n");
  /* Check sizes of input matrices, ensure same size */
  if( (mxGetM(prhs[0]) != mxGetM(prhs[1])) ||
      (mxGetN(prhs[0]) != mxGetN(prhs[1])) )
    mexErrMsgIdAndTxt( "MATLAB:simdecc:inputsNotEqual",
                       "wft and vft input vectors must both be mxn");
  /* Make sure number of traces is ROWS and number of freqs is COLS */
  if( (mxGetM(prhs[0]) > mxGetN(prhs[0])) )
    mexErrMsgIdAndTxt( "MATLAB:simdecc:inputsWrongDim",
                       "Rows = num traces, Cols = number frequencies");

  /* get pointers to the real and imaginary parts of the inputs */
  wr = mxGetPr(prhs[0]);
  wi = mxGetPi(prhs[0]);
  vr = mxGetPr(prhs[1]);
  vi = mxGetPi(prhs[1]);

  /* get the size of each input vector */
  m = mxGetM(prhs[0]);
  n = mxGetN(prhs[1]);

  /* create a new array and set the output pointer to it */
  plhs[0] = mxCreateDoubleMatrix( (mwSize)1, (mwSize)n, mxCOMPLEX);
  plhs[1] = mxCreateDoubleMatrix( (mwSize)1, (mwSize)n, mxCOMPLEX);
  plhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL);
  rr = mxGetPr(plhs[0]);
  ri = mxGetPi(plhs[0]);
  xr = mxGetPr(plhs[1]);
  xi = mxGetPi(plhs[1]);
  betax = mxGetPr(plhs[2]);

  /* call the C subroutine */
  decon(wr, wi, vr, vi, rr, ri, xr, xi, m, n, betax);

  return;
}
