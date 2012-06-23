/* all.f -- translated by f2c (version of 6 April 1990  7:19:31).
   You must link the resulting object file with the libraries:
	-lF77 -lI77 -lm -lc   (in that order)
*/

#include "f2c.h"

/* Common Block Declarations */

struct {
    complex u0[4096], w0[4096], u1[4096], w1[4096], tn[4096];
} cmparr_;

#define cmparr_1 cmparr_

struct {
    integer inunit, ounit;
} innout_;

#define innout_1 innout_

struct {
    complex alfa[45], beta[45];
    real qp[45], qs[45], rho[45], thik[45];
} model_;

#define model_1 model_

struct {
    complex rupp[45], rups[45], rusp[45], russ[45], rush[45], rdpp[45], rdps[
	    45], rdsp[45], rdss[45], rdsh[45], tupp[45], tups[45], tusp[45], 
	    tuss[45], tush[45], tdpp[45], tdps[45], tdsp[45], tdss[45], tdsh[
	    45], ruppfs, rupsfs, ruspfs, russfs, rushfs, dvpfs, dvsfs, drpfs, 
	    drsfs, dtshfs, xi[45], eta[45];
    shortint cnvrsn[46], reverb[45];
} rfltrn_;

#define rfltrn_1 rfltrn_

struct {
    complex mu11[45], mu12[45], mu21[45], mu22[45], md11[45], md12[45], md21[
	    45], md22[45], nu11[45], nu12[45], nu21[45], nu22[45], nd11[45], 
	    nd12[45], nd21[45], nd22[45], mu[45], epa[45], epb[45], zsh[45];
} invsav1_;

#define invsav1_1 invsav1_

struct {
    complex darupp[45], darups[45], darusp[45], daruss[45], darush[45], 
	    dardpp[45], dardps[45], dardsp[45], dardss[45], dardsh[45], 
	    datupp[45], datups[45], datusp[45], datuss[45], datush[45], 
	    datdpp[45], datdps[45], datdsp[45], datdss[45], datdsh[45], 
	    dbrupp[45], dbrups[45], dbrusp[45], dbruss[45], dbrush[45], 
	    dbrdpp[45], dbrdps[45], dbrdsp[45], dbrdss[45], dbrdsh[45], 
	    dbtupp[45], dbtups[45], dbtusp[45], dbtuss[45], dbtush[45], 
	    dbtdpp[45], dbtdps[45], dbtdsp[45], dbtdss[45], dbtdsh[45], dxi[
	    45], deta[45];
} invsav2_;

#define invsav2_1 invsav2_

struct {
    complex druppfs, drupsfs, druspfs, drussfs, drushfs, ddvpfs, ddvsfs, 
	    ddrpfs, ddrsfs, ddtshfs;
} invsav3_;

#define invsav3_1 invsav3_

struct {
    complex srndpp[43], srndps[43], srndsp[43], srndss[43], srndsh[43], 
	    stnupp[43], stnups[43], stnusp[43], stnuss[43], stnush[43], 
	    srnupp[43], srnups[43], srnusp[43], srnuss[43], srnush[43], sdvp[
	    43], sdvs[43], sdrp[43], sdrs[43], sdts[43];
} invsav4_;

#define invsav4_1 invsav4_

struct {
    complex mus11, mus12, mus21, mus22, mussh, nus11, nus12, nus21, nus22, 
	    nussh, mds11, mds12, mds21, mds22, mdssh, nds11, nds12, nds21, 
	    nds22, ndssh, pup0[5], pdn0[5], svup0[5], svdn0[5], shup0[5], 
	    shdn0[5], pupp1[5], pdnp1[5], svupp1[5], svdnp1[5], shupp1[5], 
	    shdnp1[5], pupm1[5], pdnm1[5], svupm1[5], svdnm1[5], shupm1[5], 
	    shdnm1[5], pupp2[5], pdnp2[5], svupp2[5], svdnp2[5], shupp2[5], 
	    shdnp2[5], pupm2[5], pdnm2[5], svupm2[5], svdnm2[5], shupm2[5], 
	    shdnm2[5];
    real mxx[5], mxy[5], mxz[5], myy[5], myz[5], mzz[5], rhos;
    complex alfas, betas;
    shortint srclyr;
} srctrm_;

#define srctrm_1 srctrm_

struct {
    complex dvpup, dvsup, drpup, drsup, dtsup, dvpdn, dvsdn, drpdn, drsdn, 
	    dtsdn;
} respns_;

#define respns_1 respns_

/* Table of constant values */

static integer c__9 = 9;
static integer c__1 = 1;
static integer c_n1 = -1;
static integer c__3 = 3;
static integer c__4 = 4;
static integer c__2 = 2;
static complex c_b51 = {(float)1.,(float)0.};
static real c_b67 = (float)0.;
static complex c_b86 = {(float)-.002,(float)-.002};

/* Main program */ MAIN__()
{
    /* Initialized data */

    static char comp[6*3+1] = "_sp.z _sp.r _sp.t ";

    /* System generated locals */
    address a_1[2];
    integer i_1, i_2[2], i_3, i_4, i_5;
    doublereal d_1;
    complex q_1, q_2;
    doublecomplex z_1, z_2, z_3;

    /* Builtin functions */
    double atan();
    /* Subroutine */ int s_copy();
    integer s_wsle(), do_lio(), e_wsle(), s_rsfe(), do_fio(), e_rsfe(), 
	    s_rsle(), e_rsle();
    /* Subroutine */ int s_cat(), s_stop();

    /* Local variables */
    static real delf, alfm[50];
    extern doublereal qabm_(), vabm_();
    static real betm[50];
    static char ofil[32];
    static real rhom[50];
    static integer nerr;
    extern /* Subroutine */ int wsac1_();
    static integer i, j;
    static complex p;
    static real t;
    extern integer blank_();
    extern /* Subroutine */ int ifmat_(), dfftr_();
    static char ofilr[32];
    static real thikm[50];
    static char ofilt[32], title[32], ofilz[32];
    static integer nfpts, ipors;
    static real twopi;
    static doublereal t1, t2;
    static integer nlyrs;
    static doublereal qa, qb;
    static real ta[50], tb[50];
    extern integer npowr2_();
    static complex fr;
    static real dt;
    static integer iblank;
    static char modela[32];
    static doublereal wq;
    static char modcnv[1], complt[1];
    extern /* Subroutine */ int inihdr_(), newhdr_(), rdlyrs_();
    static integer ier;
    static real pr;
    static complex drp;
    static shortint cnv;
    static complex drs, dvp, dts;
    static shortint rvb;
    static complex dvs;
    static real qpm[50], qsm[50];
    static integer numpts, nft;
    static real fny;
    extern /* Subroutine */ int rcvrfn_();
    static real dum1[100], dum2[100];

    /* Fortran I/O blocks */
    static cilist io__7 = { 0, 0, 0, 0, 0 };
    static cilist io__8 = { 0, 0, 0, "(a)", 0 };
    static cilist io__25 = { 0, 0, 0, 0, 0 };
    static cilist io__26 = { 0, 0, 0, 0, 0 };
    static cilist io__28 = { 0, 6, 0, 0, 0 };
    static cilist io__29 = { 0, 5, 0, 0, 0 };
    static cilist io__31 = { 0, 6, 0, 0, 0 };
    static cilist io__32 = { 0, 5, 0, 0, 0 };
    static cilist io__34 = { 0, 6, 0, 0, 0 };
    static cilist io__35 = { 0, 5, 0, 0, 0 };
    static cilist io__37 = { 0, 6, 0, 0, 0 };
    static cilist io__38 = { 0, 5, 0, "(a1)", 0 };
    static cilist io__40 = { 0, 6, 0, 0, 0 };
    static cilist io__41 = { 0, 5, 0, "(a1)", 0 };



/* 	model parameters */


/* 	interface reflection and transmission coefficients */


/* 	interface and layer matricies for perturbations */
/* 	used in partial derivative calculations for */
/* 	inversion process */


/* 	source parameters for moment tensor sources */


/* 	layered medium response for buried source */


    inihdr_();
    newhdr_();

    innout_1.inunit = 5;
    innout_1.ounit = 6;
    twopi = atan((float)1.) * (float)8.;
    s_copy(ofil, "                                ", 32L, 32L);
    s_copy(ofilr, "                                ", 32L, 32L);
    s_copy(ofilz, "                                ", 32L, 32L);
    s_copy(ofilt, "                                ", 32L, 32L);

    io__7.ciunit = innout_1.ounit;
    s_wsle(&io__7);
    do_lio(&c__9, &c__1, "Velocity Model Name", 19L);
    e_wsle();
    io__8.ciunit = innout_1.inunit;
    s_rsfe(&io__8);
    do_fio(&c__1, modela, 32L);
    e_rsfe();
    iblank = blank_(modela, 32L);
    s_copy(ofil, modela, iblank, iblank);
    rdlyrs_(modela, &nlyrs, title, alfm, betm, rhom, thikm, dum1, dum2, dum1, 
	    dum2, &c_n1, &ier, 32L, 32L);
    i_1 = nlyrs;
    for (i = 1; i <= i_1; ++i) {
/*      qpm(i) = 500. */
/*      qsm(i) = 225. */
	qpm[i - 1] = (float)125.;
	qsm[i - 1] = (float)62.5;
	ta[i - 1] = (float).16;
	tb[i - 1] = (float).26;
/* L1: */
    }

/*     terminal input */

    io__25.ciunit = innout_1.ounit;
    s_wsle(&io__25);
    do_lio(&c__9, &c__1, "incident P(1) or S(2) wave", 26L);
    e_wsle();
    io__26.ciunit = innout_1.inunit;
    s_rsle(&io__26);
    do_lio(&c__3, &c__1, (char *)&ipors, (ftnlen)sizeof(integer));
    e_rsle();
    s_wsle(&io__28);
    do_lio(&c__9, &c__1, "sampling interval", 17L);
    e_wsle();
    s_rsle(&io__29);
    do_lio(&c__4, &c__1, (char *)&dt, (ftnlen)sizeof(real));
    e_rsle();
    s_wsle(&io__31);
    do_lio(&c__9, &c__1, "signal duration", 15L);
    e_wsle();
    s_rsle(&io__32);
    do_lio(&c__4, &c__1, (char *)&t, (ftnlen)sizeof(real));
    e_rsle();
/*     write(6,*) 'incident delay' */
/*     read(5,*) tdelay */
/*     write(6,*) 'output file base name' */
/*     read(5,'(a)') ofil */
    s_wsle(&io__34);
    do_lio(&c__9, &c__1, " enter slowness: ", 17L);
    e_wsle();
    s_rsle(&io__35);
    do_lio(&c__4, &c__1, (char *)&pr, (ftnlen)sizeof(real));
    e_rsle();
    s_wsle(&io__37);
    do_lio(&c__9, &c__1, " partial(p) or full(f) : ", 25L);
    e_wsle();
    s_rsfe(&io__38);
    do_fio(&c__1, complt, 1L);
    e_rsfe();
    s_wsle(&io__40);
    do_lio(&c__9, &c__1, " mode conversions? (y or n) ", 28L);
    e_wsle();
    s_rsfe(&io__41);
    do_fio(&c__1, modcnv, 1L);
    e_rsfe();

/*     build output filenames */

/* Writing concatenation */
    i_2[0] = iblank, a_1[0] = ofil;
    i_2[1] = 6, a_1[1] = comp;
    s_cat(ofilz, a_1, i_2, &c__2, iblank + 6);
/* Writing concatenation */
    i_2[0] = iblank, a_1[0] = ofil;
    i_2[1] = 6, a_1[1] = comp + 6;
    s_cat(ofilr, a_1, i_2, &c__2, iblank + 6);
/* Writing concatenation */
    i_2[0] = iblank, a_1[0] = ofil;
    i_2[1] = 6, a_1[1] = comp + 12;
    s_cat(ofilt, a_1, i_2, &c__2, iblank + 6);

/*     set up the spectral parameters */

    numpts = (integer) (t / dt + (float)1.5);
    nft = npowr2_(&numpts);
    nfpts = nft / 2 + 1;
    fny = (float)1. / (dt * (float)2.);
    delf = fny * (float)2. / (real) nft;
    t = dt * nft;

/*     set up some computational parameters */
/*          specifying the type of response */
/*          requested. */

    q_1.r = pr, q_1.i = (float)0.;
    p.r = q_1.r, p.i = q_1.i;
    if (*complt == 'f') {
	rvb = -1;
    } else {
	rvb = 0;
    }
    if (*modcnv == 'n') {
	cnv = 1;
    } else {
	cnv = 0;
    }



/*     compute q, alfa, and beta at 1 hz for absorbtion band */

    t1 = 1e4;
    wq = twopi;
    i_1 = nlyrs;
    for (i = 1; i <= i_1; ++i) {
	qa = qpm[i - 1];
	qb = qsm[i - 1];
	t2 = ta[i - 1];
	i_3 = i - 1;
	d_1 = alfm[i - 1] * vabm_(&wq, &t1, &t2, &qa);
	model_1.alfa[i_3].r = d_1, model_1.alfa[i_3].i = (float)0.;
	t2 = tb[i - 1];
	i_3 = i - 1;
	d_1 = betm[i - 1] * vabm_(&wq, &t1, &t2, &qb);
	model_1.beta[i_3].r = d_1, model_1.beta[i_3].i = (float)0.;
	qa = qabm_(&wq, &t1, &t2, &qa);
	qb = qabm_(&wq, &t1, &t2, &qb);
	i_3 = i - 1;
	i_4 = i - 1;
	z_3.r = (float)0. / qa, z_3.i = (float).5 / qa;
	z_2.r = z_3.r + (float)1., z_2.i = z_3.i;
	z_1.r = model_1.alfa[i_4].r * z_2.r - model_1.alfa[i_4].i * z_2.i, 
		z_1.i = model_1.alfa[i_4].r * z_2.i + model_1.alfa[i_4].i * 
		z_2.r;
	model_1.alfa[i_3].r = z_1.r, model_1.alfa[i_3].i = z_1.i;
	i_3 = i - 1;
	i_4 = i - 1;
	z_3.r = (float)0. / qb, z_3.i = (float).5 / qb;
	z_2.r = z_3.r + (float)1., z_2.i = z_3.i;
	z_1.r = model_1.beta[i_4].r * z_2.r - model_1.beta[i_4].i * z_2.i, 
		z_1.i = model_1.beta[i_4].r * z_2.i + model_1.beta[i_4].i * 
		z_2.r;
	model_1.beta[i_3].r = z_1.r, model_1.beta[i_3].i = z_1.i;
	rfltrn_1.cnvrsn[i] = cnv;
	rfltrn_1.reverb[i - 1] = rvb;
	model_1.rho[i - 1] = rhom[i - 1];
/* L5: */
	model_1.thik[i - 1] = thikm[i - 1];
    }
    rfltrn_1.cnvrsn[0] = cnv;
    if (*complt != 'f') {
	rfltrn_1.reverb[0] = 1;
    }

    fr.r = (float)1., fr.i = (float)0.;
    ifmat_(&c__1, &p, &fr, &nlyrs);

    i_1 = nfpts - 1;
    for (i = 1; i <= i_1; ++i) {
	d_1 = delf * (i - 1);
	q_1.r = d_1, q_1.i = (float)0.;
	fr.r = q_1.r, fr.i = q_1.i;
	q_1.r = twopi * fr.r, q_1.i = twopi * fr.i;
	wq = q_1.r;
	i_3 = nlyrs;
	for (j = 1; j <= i_3; ++j) {
	    qa = qpm[j - 1];
	    qb = qsm[j - 1];
	    t2 = ta[j - 1];
	    i_4 = j - 1;
	    d_1 = alfm[j - 1] * vabm_(&wq, &t1, &t2, &qa);
	    model_1.alfa[i_4].r = d_1, model_1.alfa[i_4].i = (float)0.;
	    t2 = tb[j - 1];
	    i_4 = j - 1;
	    d_1 = betm[j - 1] * vabm_(&wq, &t1, &t2, &qb);
	    model_1.beta[i_4].r = d_1, model_1.beta[i_4].i = (float)0.;
	    qa = qabm_(&wq, &t1, &t2, &qa);
	    qb = qabm_(&wq, &t1, &t2, &qb);
	    i_4 = j - 1;
	    i_5 = j - 1;
	    z_3.r = (float)0. / qa, z_3.i = (float).5 / qa;
	    z_2.r = z_3.r + (float)1., z_2.i = z_3.i;
	    z_1.r = model_1.alfa[i_5].r * z_2.r - model_1.alfa[i_5].i * z_2.i,
		     z_1.i = model_1.alfa[i_5].r * z_2.i + model_1.alfa[i_5]
		    .i * z_2.r;
	    model_1.alfa[i_4].r = z_1.r, model_1.alfa[i_4].i = z_1.i;
	    i_4 = j - 1;
	    i_5 = j - 1;
	    z_3.r = (float)0. / qb, z_3.i = (float).5 / qb;
	    z_2.r = z_3.r + (float)1., z_2.i = z_3.i;
	    z_1.r = model_1.beta[i_5].r * z_2.r - model_1.beta[i_5].i * z_2.i,
		     z_1.i = model_1.beta[i_5].r * z_2.i + model_1.beta[i_5]
		    .i * z_2.r;
	    model_1.beta[i_4].r = z_1.r, model_1.beta[i_4].i = z_1.i;
/* L6: */
	}
	rcvrfn_(&p, &fr, &nlyrs, &dvp, &dvs, &drp, &drs, &dts);
	i_3 = i - 1;
	q_2.r = dvp.r * (float)0. - dvp.i * (float)-1., q_2.i = dvp.r * (
		float)-1. + dvp.i * (float)0.;
	q_1.r = q_2.r * (float)-1. - q_2.i * (float)0., q_1.i = q_2.r * (
		float)0. + q_2.i * (float)-1.;
	cmparr_1.u0[i_3].r = q_1.r, cmparr_1.u0[i_3].i = q_1.i;
	i_3 = i - 1;
	cmparr_1.w0[i_3].r = drp.r, cmparr_1.w0[i_3].i = drp.i;
	i_3 = i - 1;
	cmparr_1.u1[i_3].r = dvs.r, cmparr_1.u1[i_3].i = dvs.i;
	i_3 = i - 1;
	q_1.r = drs.r * (float)0. - drs.i * (float)1., q_1.i = drs.r * (float)
		1. + drs.i * (float)0.;
	cmparr_1.w1[i_3].r = q_1.r, cmparr_1.w1[i_3].i = q_1.i;
	i_3 = i - 1;
	cmparr_1.tn[i_3].r = dts.r, cmparr_1.tn[i_3].i = dts.i;
/* L10: */
    }
    i_1 = nfpts - 1;
    cmparr_1.u0[i_1].r = (float)0., cmparr_1.u0[i_1].i = (float)0.;
    i_1 = nfpts - 1;
    cmparr_1.w0[i_1].r = (float)0., cmparr_1.w0[i_1].i = (float)0.;
    i_1 = nfpts - 1;
    cmparr_1.u1[i_1].r = (float)0., cmparr_1.u1[i_1].i = (float)0.;
    i_1 = nfpts - 1;
    cmparr_1.w0[i_1].r = (float)0., cmparr_1.w0[i_1].i = (float)0.;
    i_1 = nfpts - 1;
    cmparr_1.tn[i_1].r = (float)0., cmparr_1.tn[i_1].i = (float)0.;

/*     output the responses */

    if (ipors == 1) {
	dfftr_(cmparr_1.u0, &nft, "inverse", &delf, 7L);
	dfftr_(cmparr_1.w0, &nft, "inverse", &delf, 7L);
	wsac1_(ofilz, cmparr_1.u0, &numpts, &c_b67, &dt, &nerr, 32L);
	wsac1_(ofilr, cmparr_1.w0, &numpts, &c_b67, &dt, &nerr, 32L);
    } else {
	dfftr_(cmparr_1.u1, &nft, "inverse", &delf, 7L);
	dfftr_(cmparr_1.w1, &nft, "inverse", &delf, 7L);
	dfftr_(cmparr_1.tn, &nft, "inverse", &delf, 7L);
	wsac1_(ofilz, cmparr_1.u1, &numpts, &c_b67, &dt, &nerr, 32L);
	wsac1_(ofilr, cmparr_1.w1, &numpts, &c_b67, &dt, &nerr, 32L);
	wsac1_(ofilt, cmparr_1.tn, &numpts, &c_b67, &dt, &nerr, 32L);
    }

    s_stop("", 0L);
} /* MAIN__ */

integer blank_(file, file_len)
char *file;
ftnlen file_len;
{
    /* Format strings */
    static char fmt_100[] = "(\002 no blanks found in \002,a32)";

    /* System generated locals */
    integer ret_val;

    /* Builtin functions */
    integer s_wsfe(), do_fio(), e_wsfe();

    /* Local variables */
    static integer i;

    /* Fortran I/O blocks */
    static cilist io__65 = { 0, 1, 0, fmt_100, 0 };


    for (i = 1; i <= 32; ++i) {
	if (file[i - 1] != ' ') {
	    goto L1;
	}
	ret_val = i - 1;
	return ret_val;
L1:
	;
    }
    s_wsfe(&io__65);
    do_fio(&c__1, file, 32L);
    e_wsfe();
    ret_val = 0;
    return ret_val;
} /* blank_ */

/* Subroutine */ int rcvrfn_(p, f, nlyrs, dvp, dvs, drp, drs, dts)
complex *p;
complex *f;
integer *nlyrs;
complex *dvp, *dvs, *drp, *drs, *dts;
{
    /* Initialized data */

    static real twopi = (float)6.2831853;
    static complex i = {(float)0.,(float)1.};
    static complex zero = {(float)0.,(float)0.};
    static complex one = {(float)1.,(float)0.};

    /* System generated locals */
    integer i_1, i_2;
    complex q_1, q_2, q_3, q_4, q_5;
    doublecomplex z_1, z_2;

    /* Builtin functions */
    void z_div(), c_div();

    /* Local variables */
    extern /* Complex */ int cphs_();
    static complex phtp, phts, w, rndpp, rndps, rndsp, rndss, rndsh, phtpp, 
	    tnush, phtps, phtss, tnupp, tnups, tnusp, tnuss, l11, l12, l21, 
	    l22, t11, t12, t21, t22, x11, x12, x21, x22, y11, y12, y21;
    static doublecomplex det;
    static complex y22;
    static integer nif, cnvnif;
    static complex tsh, lsh, xsh, ysh;
    static integer lyr;


/*        compute receiver function - free surface displacement from a */
/*        plane wave incident from below, on a stack of plane, parallel, 
*/
/*        homogeneous layers */
/*        for a p, sv or sh wave incident */
/*        interface 0 is top of layer 1, a free surface, */
/*        layer n is half space */
/*        given frequency and phase slowness. */

/*          arguments... */
/*        psvsh = 1,2,3 for an incident p, sv or sh wave. */

/*        f,p - prescribed freq (hz) & horizontal phase slowness (c is */
/*            not restricted to be greater than alfa or beta) */
/*            both may be complex */

/*        passed in common /model/ */
/*        alfa,beta,qp,qs,rho and thik contain the medium properties for 
*/

/*        nlyrs - total number of layers, layer nlyrs is */
/*            the half space */



/*        commons and declarations */



/*        complex declarations */


/* 	model parameters */


/* 	interface reflection and transmission coefficients */


/* 	interface and layer matricies for perturbations */
/* 	used in partial derivative calculations for */
/* 	inversion process */


/* 	source parameters for moment tensor sources */


/* 	layered medium response for buried source */



    q_1.r = twopi * f->r, q_1.i = twopi * f->i;
    w.r = q_1.r, w.i = q_1.i;

/*     handle the special case of a half space */

    if (*nlyrs == 1) {
	dvp->r = rfltrn_1.dvpfs.r, dvp->i = rfltrn_1.dvpfs.i;
	dvs->r = rfltrn_1.dvsfs.r, dvs->i = rfltrn_1.dvsfs.i;
	drp->r = rfltrn_1.drpfs.r, drp->i = rfltrn_1.drpfs.i;
	drs->r = rfltrn_1.drsfs.r, drs->i = rfltrn_1.drsfs.i;
	dts->r = rfltrn_1.dtshfs.r, dts->i = rfltrn_1.dtshfs.i;
	return 0;
    }

/*        initialize tup and rdown matricies for the stack with */
/*        bottom interface matricies */

    nif = *nlyrs - 1;
    cnvnif = rfltrn_1.cnvrsn[nif];
    if (cnvnif == 0) {
	i_1 = nif - 1;
	tnupp.r = rfltrn_1.tupp[i_1].r, tnupp.i = rfltrn_1.tupp[i_1].i;
	i_1 = nif - 1;
	tnuss.r = rfltrn_1.tuss[i_1].r, tnuss.i = rfltrn_1.tuss[i_1].i;
	i_1 = nif - 1;
	tnups.r = rfltrn_1.tups[i_1].r, tnups.i = rfltrn_1.tups[i_1].i;
	i_1 = nif - 1;
	tnusp.r = rfltrn_1.tusp[i_1].r, tnusp.i = rfltrn_1.tusp[i_1].i;
	i_1 = nif - 1;
	tnush.r = rfltrn_1.tush[i_1].r, tnush.i = rfltrn_1.tush[i_1].i;
	i_1 = nif - 1;
	rndpp.r = rfltrn_1.rdpp[i_1].r, rndpp.i = rfltrn_1.rdpp[i_1].i;
	i_1 = nif - 1;
	rndss.r = rfltrn_1.rdss[i_1].r, rndss.i = rfltrn_1.rdss[i_1].i;
	i_1 = nif - 1;
	rndps.r = rfltrn_1.rdps[i_1].r, rndps.i = rfltrn_1.rdps[i_1].i;
	i_1 = nif - 1;
	rndsp.r = rfltrn_1.rdsp[i_1].r, rndsp.i = rfltrn_1.rdsp[i_1].i;
	i_1 = nif - 1;
	rndsh.r = rfltrn_1.rdsh[i_1].r, rndsh.i = rfltrn_1.rdsh[i_1].i;
    } else if (cnvnif == 1) {
	i_1 = nif - 1;
	tnupp.r = rfltrn_1.tupp[i_1].r, tnupp.i = rfltrn_1.tupp[i_1].i;
	i_1 = nif - 1;
	tnuss.r = rfltrn_1.tuss[i_1].r, tnuss.i = rfltrn_1.tuss[i_1].i;
	tnups.r = zero.r, tnups.i = zero.i;
	tnusp.r = zero.r, tnusp.i = zero.i;
	i_1 = nif - 1;
	tnush.r = rfltrn_1.tush[i_1].r, tnush.i = rfltrn_1.tush[i_1].i;
	i_1 = nif - 1;
	rndpp.r = rfltrn_1.rdpp[i_1].r, rndpp.i = rfltrn_1.rdpp[i_1].i;
	i_1 = nif - 1;
	rndss.r = rfltrn_1.rdss[i_1].r, rndss.i = rfltrn_1.rdss[i_1].i;
	rndps.r = zero.r, rndps.i = zero.i;
	rndsp.r = zero.r, rndsp.i = zero.i;
	i_1 = nif - 1;
	rndsh.r = rfltrn_1.rdsh[i_1].r, rndsh.i = rfltrn_1.rdsh[i_1].i;
    } else if (cnvnif == -1) {
	i_1 = nif - 1;
	tnups.r = rfltrn_1.tups[i_1].r, tnups.i = rfltrn_1.tups[i_1].i;
	i_1 = nif - 1;
	tnusp.r = rfltrn_1.tusp[i_1].r, tnusp.i = rfltrn_1.tusp[i_1].i;
	tnupp.r = zero.r, tnupp.i = zero.i;
	tnuss.r = zero.r, tnuss.i = zero.i;
	i_1 = nif - 1;
	tnush.r = rfltrn_1.tush[i_1].r, tnush.i = rfltrn_1.tush[i_1].i;
	i_1 = nif - 1;
	rndps.r = rfltrn_1.rdps[i_1].r, rndps.i = rfltrn_1.rdps[i_1].i;
	i_1 = nif - 1;
	rndsp.r = rfltrn_1.rdsp[i_1].r, rndsp.i = rfltrn_1.rdsp[i_1].i;
	rndpp.r = zero.r, rndpp.i = zero.i;
	rndss.r = zero.r, rndss.i = zero.i;
	i_1 = nif - 1;
	rndsh.r = rfltrn_1.rdsh[i_1].r, rndsh.i = rfltrn_1.rdsh[i_1].i;
    }

/*        now do the  bottom up recursion for tup and rdown */

    for (lyr = *nlyrs - 1; lyr >= 2; --lyr) {
	nif = lyr - 1;

/*        use the two way phase delay through the layer */
/*        to/from the next interface */

	q_5.r = -(doublereal)i.r, q_5.i = -(doublereal)i.i;
	q_4.r = q_5.r * w.r - q_5.i * w.i, q_4.i = q_5.r * w.i + q_5.i * w.r;
	i_1 = lyr - 1;
	q_3.r = q_4.r * rfltrn_1.xi[i_1].r - q_4.i * rfltrn_1.xi[i_1].i, 
		q_3.i = q_4.r * rfltrn_1.xi[i_1].i + q_4.i * rfltrn_1.xi[i_1]
		.r;
	i_2 = lyr - 1;
	q_2.r = model_1.thik[i_2] * q_3.r, q_2.i = model_1.thik[i_2] * q_3.i;
	cphs_(&q_1, &q_2);
	phtp.r = q_1.r, phtp.i = q_1.i;
	q_5.r = -(doublereal)i.r, q_5.i = -(doublereal)i.i;
	q_4.r = q_5.r * w.r - q_5.i * w.i, q_4.i = q_5.r * w.i + q_5.i * w.r;
	i_1 = lyr - 1;
	q_3.r = q_4.r * rfltrn_1.eta[i_1].r - q_4.i * rfltrn_1.eta[i_1].i, 
		q_3.i = q_4.r * rfltrn_1.eta[i_1].i + q_4.i * rfltrn_1.eta[
		i_1].r;
	i_2 = lyr - 1;
	q_2.r = model_1.thik[i_2] * q_3.r, q_2.i = model_1.thik[i_2] * q_3.i;
	cphs_(&q_1, &q_2);
	phts.r = q_1.r, phts.i = q_1.i;
	q_1.r = phtp.r * phtp.r - phtp.i * phtp.i, q_1.i = phtp.r * phtp.i + 
		phtp.i * phtp.r;
	phtpp.r = q_1.r, phtpp.i = q_1.i;
	q_1.r = phtp.r * phts.r - phtp.i * phts.i, q_1.i = phtp.r * phts.i + 
		phtp.i * phts.r;
	phtps.r = q_1.r, phtps.i = q_1.i;
	q_1.r = phts.r * phts.r - phts.i * phts.i, q_1.i = phts.r * phts.i + 
		phts.i * phts.r;
	phtss.r = q_1.r, phtss.i = q_1.i;
	q_1.r = rndpp.r * phtpp.r - rndpp.i * phtpp.i, q_1.i = rndpp.r * 
		phtpp.i + rndpp.i * phtpp.r;
	rndpp.r = q_1.r, rndpp.i = q_1.i;
	q_1.r = rndss.r * phtss.r - rndss.i * phtss.i, q_1.i = rndss.r * 
		phtss.i + rndss.i * phtss.r;
	rndss.r = q_1.r, rndss.i = q_1.i;
	q_1.r = rndps.r * phtps.r - rndps.i * phtps.i, q_1.i = rndps.r * 
		phtps.i + rndps.i * phtps.r;
	rndps.r = q_1.r, rndps.i = q_1.i;
	q_1.r = rndsp.r * phtps.r - rndsp.i * phtps.i, q_1.i = rndsp.r * 
		phtps.i + rndsp.i * phtps.r;
	rndsp.r = q_1.r, rndsp.i = q_1.i;
	q_1.r = rndsh.r * phtss.r - rndsh.i * phtss.i, q_1.i = rndsh.r * 
		phtss.i + rndsh.i * phtss.r;
	rndsh.r = q_1.r, rndsh.i = q_1.i;
	q_1.r = tnupp.r * phtp.r - tnupp.i * phtp.i, q_1.i = tnupp.r * phtp.i 
		+ tnupp.i * phtp.r;
	tnupp.r = q_1.r, tnupp.i = q_1.i;
	q_1.r = tnuss.r * phts.r - tnuss.i * phts.i, q_1.i = tnuss.r * phts.i 
		+ tnuss.i * phts.r;
	tnuss.r = q_1.r, tnuss.i = q_1.i;
	q_1.r = tnups.r * phtp.r - tnups.i * phtp.i, q_1.i = tnups.r * phtp.i 
		+ tnups.i * phtp.r;
	tnups.r = q_1.r, tnups.i = q_1.i;
	q_1.r = tnusp.r * phts.r - tnusp.i * phts.i, q_1.i = tnusp.r * phts.i 
		+ tnusp.i * phts.r;
	tnusp.r = q_1.r, tnusp.i = q_1.i;
	q_1.r = tnush.r * phts.r - tnush.i * phts.i, q_1.i = tnush.r * phts.i 
		+ tnush.i * phts.r;
	tnush.r = q_1.r, tnush.i = q_1.i;
	i_1 = lyr - 2;
	invsav4_1.stnupp[i_1].r = tnupp.r, invsav4_1.stnupp[i_1].i = tnupp.i;
	i_1 = lyr - 2;
	invsav4_1.stnups[i_1].r = tnups.r, invsav4_1.stnups[i_1].i = tnups.i;
	i_1 = lyr - 2;
	invsav4_1.stnusp[i_1].r = tnusp.r, invsav4_1.stnusp[i_1].i = tnusp.i;
	i_1 = lyr - 2;
	invsav4_1.stnuss[i_1].r = tnuss.r, invsav4_1.stnuss[i_1].i = tnuss.i;
	i_1 = lyr - 2;
	invsav4_1.stnush[i_1].r = tnush.r, invsav4_1.stnush[i_1].i = tnush.i;
	i_1 = lyr - 2;
	invsav4_1.srndpp[i_1].r = rndpp.r, invsav4_1.srndpp[i_1].i = rndpp.i;
	i_1 = lyr - 2;
	invsav4_1.srndps[i_1].r = rndps.r, invsav4_1.srndps[i_1].i = rndps.i;
	i_1 = lyr - 2;
	invsav4_1.srndsp[i_1].r = rndsp.r, invsav4_1.srndsp[i_1].i = rndsp.i;
	i_1 = lyr - 2;
	invsav4_1.srndss[i_1].r = rndss.r, invsav4_1.srndss[i_1].i = rndss.i;
	i_1 = lyr - 2;
	invsav4_1.srndsh[i_1].r = rndsh.r, invsav4_1.srndsh[i_1].i = rndsh.i;

/*        form the reverberation operator for the layer */

	cnvnif = rfltrn_1.cnvrsn[nif];
	if (cnvnif == 0) {
	    i_1 = nif - 1;
	    t11.r = rfltrn_1.rupp[i_1].r, t11.i = rfltrn_1.rupp[i_1].i;
	    i_1 = nif - 1;
	    t22.r = rfltrn_1.russ[i_1].r, t22.i = rfltrn_1.russ[i_1].i;
	    i_1 = nif - 1;
	    t12.r = rfltrn_1.rups[i_1].r, t12.i = rfltrn_1.rups[i_1].i;
	    i_1 = nif - 1;
	    t21.r = rfltrn_1.rusp[i_1].r, t21.i = rfltrn_1.rusp[i_1].i;
	    i_1 = nif - 1;
	    tsh.r = rfltrn_1.rush[i_1].r, tsh.i = rfltrn_1.rush[i_1].i;
	} else if (cnvnif == 1) {
	    i_1 = nif - 1;
	    t11.r = rfltrn_1.rupp[i_1].r, t11.i = rfltrn_1.rupp[i_1].i;
	    i_1 = nif - 1;
	    t22.r = rfltrn_1.russ[i_1].r, t22.i = rfltrn_1.russ[i_1].i;
	    t12.r = zero.r, t12.i = zero.i;
	    t21.r = zero.r, t21.i = zero.i;
	    i_1 = nif - 1;
	    tsh.r = rfltrn_1.rush[i_1].r, tsh.i = rfltrn_1.rush[i_1].i;
	} else if (cnvnif == -1) {
	    i_1 = nif - 1;
	    t12.r = rfltrn_1.rups[i_1].r, t12.i = rfltrn_1.rups[i_1].i;
	    i_1 = nif - 1;
	    t21.r = rfltrn_1.rusp[i_1].r, t21.i = rfltrn_1.rusp[i_1].i;
	    t11.r = zero.r, t11.i = zero.i;
	    t22.r = zero.r, t22.i = zero.i;
	    i_1 = nif - 1;
	    tsh.r = rfltrn_1.rush[i_1].r, tsh.i = rfltrn_1.rush[i_1].i;
	}
	if (rfltrn_1.reverb[lyr - 1] == -1) {
	    q_3.r = rndpp.r * t11.r - rndpp.i * t11.i, q_3.i = rndpp.r * 
		    t11.i + rndpp.i * t11.r;
	    q_4.r = rndps.r * t21.r - rndps.i * t21.i, q_4.i = rndps.r * 
		    t21.i + rndps.i * t21.r;
	    q_2.r = q_3.r + q_4.r, q_2.i = q_3.i + q_4.i;
	    q_1.r = one.r - q_2.r, q_1.i = one.i - q_2.i;
	    l11.r = q_1.r, l11.i = q_1.i;
	    q_3.r = rndsp.r * t12.r - rndsp.i * t12.i, q_3.i = rndsp.r * 
		    t12.i + rndsp.i * t12.r;
	    q_4.r = rndss.r * t22.r - rndss.i * t22.i, q_4.i = rndss.r * 
		    t22.i + rndss.i * t22.r;
	    q_2.r = q_3.r + q_4.r, q_2.i = q_3.i + q_4.i;
	    q_1.r = one.r - q_2.r, q_1.i = one.i - q_2.i;
	    l22.r = q_1.r, l22.i = q_1.i;
	    q_3.r = rndpp.r * t12.r - rndpp.i * t12.i, q_3.i = rndpp.r * 
		    t12.i + rndpp.i * t12.r;
	    q_4.r = rndps.r * t22.r - rndps.i * t22.i, q_4.i = rndps.r * 
		    t22.i + rndps.i * t22.r;
	    q_2.r = q_3.r + q_4.r, q_2.i = q_3.i + q_4.i;
	    q_1.r = -(doublereal)q_2.r, q_1.i = -(doublereal)q_2.i;
	    l12.r = q_1.r, l12.i = q_1.i;
	    q_3.r = rndsp.r * t11.r - rndsp.i * t11.i, q_3.i = rndsp.r * 
		    t11.i + rndsp.i * t11.r;
	    q_4.r = rndss.r * t21.r - rndss.i * t21.i, q_4.i = rndss.r * 
		    t21.i + rndss.i * t21.r;
	    q_2.r = q_3.r + q_4.r, q_2.i = q_3.i + q_4.i;
	    q_1.r = -(doublereal)q_2.r, q_1.i = -(doublereal)q_2.i;
	    l21.r = q_1.r, l21.i = q_1.i;
	    q_2.r = l11.r * l22.r - l11.i * l22.i, q_2.i = l11.r * l22.i + 
		    l11.i * l22.r;
	    q_3.r = l12.r * l21.r - l12.i * l21.i, q_3.i = l12.r * l21.i + 
		    l12.i * l21.r;
	    q_1.r = q_2.r - q_3.r, q_1.i = q_2.i - q_3.i;
	    det.r = q_1.r, det.i = q_1.i;
	    q_1.r = -(doublereal)l12.r, q_1.i = -(doublereal)l12.i;
	    z_2.r = q_1.r, z_2.i = q_1.i;
	    z_div(&z_1, &z_2, &det);
	    l12.r = z_1.r, l12.i = z_1.i;
	    q_1.r = -(doublereal)l21.r, q_1.i = -(doublereal)l21.i;
	    z_2.r = q_1.r, z_2.i = q_1.i;
	    z_div(&z_1, &z_2, &det);
	    l21.r = z_1.r, l21.i = z_1.i;
	    z_2.r = l11.r, z_2.i = l11.i;
	    z_div(&z_1, &z_2, &det);
	    t11.r = z_1.r, t11.i = z_1.i;
	    z_2.r = l22.r, z_2.i = l22.i;
	    z_div(&z_1, &z_2, &det);
	    l11.r = z_1.r, l11.i = z_1.i;
	    l22.r = t11.r, l22.i = t11.i;
	    q_3.r = rndsh.r * tsh.r - rndsh.i * tsh.i, q_3.i = rndsh.r * 
		    tsh.i + rndsh.i * tsh.r;
	    q_2.r = one.r - q_3.r, q_2.i = one.i - q_3.i;
	    c_div(&q_1, &one, &q_2);
	    lsh.r = q_1.r, lsh.i = q_1.i;
	} else if (rfltrn_1.reverb[lyr - 1] == 1) {
	    q_3.r = rndpp.r * t11.r - rndpp.i * t11.i, q_3.i = rndpp.r * 
		    t11.i + rndpp.i * t11.r;
	    q_4.r = rndps.r * t21.r - rndps.i * t21.i, q_4.i = rndps.r * 
		    t21.i + rndps.i * t21.r;
	    q_2.r = q_3.r + q_4.r, q_2.i = q_3.i + q_4.i;
	    q_1.r = one.r + q_2.r, q_1.i = one.i + q_2.i;
	    l11.r = q_1.r, l11.i = q_1.i;
	    q_3.r = rndsp.r * t12.r - rndsp.i * t12.i, q_3.i = rndsp.r * 
		    t12.i + rndsp.i * t12.r;
	    q_4.r = rndss.r * t22.r - rndss.i * t22.i, q_4.i = rndss.r * 
		    t22.i + rndss.i * t22.r;
	    q_2.r = q_3.r + q_4.r, q_2.i = q_3.i + q_4.i;
	    q_1.r = one.r + q_2.r, q_1.i = one.i + q_2.i;
	    l22.r = q_1.r, l22.i = q_1.i;
	    q_2.r = rndpp.r * t12.r - rndpp.i * t12.i, q_2.i = rndpp.r * 
		    t12.i + rndpp.i * t12.r;
	    q_3.r = rndps.r * t22.r - rndps.i * t22.i, q_3.i = rndps.r * 
		    t22.i + rndps.i * t22.r;
	    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	    l12.r = q_1.r, l12.i = q_1.i;
	    q_2.r = rndsp.r * t11.r - rndsp.i * t11.i, q_2.i = rndsp.r * 
		    t11.i + rndsp.i * t11.r;
	    q_3.r = rndss.r * t21.r - rndss.i * t21.i, q_3.i = rndss.r * 
		    t21.i + rndss.i * t21.r;
	    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	    l21.r = q_1.r, l21.i = q_1.i;
	    q_2.r = rndsh.r * tsh.r - rndsh.i * tsh.i, q_2.i = rndsh.r * 
		    tsh.i + rndsh.i * tsh.r;
	    q_1.r = one.r + q_2.r, q_1.i = one.i + q_2.i;
	    lsh.r = q_1.r, lsh.i = q_1.i;
	} else if (rfltrn_1.reverb[lyr - 1] == 0) {
	    l11.r = one.r, l11.i = one.i;
	    l22.r = one.r, l22.i = one.i;
	    l12.r = zero.r, l12.i = zero.i;
	    l21.r = zero.r, l21.i = zero.i;
	    lsh.r = one.r, lsh.i = one.i;
	}

/*        now finish the recursion, adding the next interface */

	if (cnvnif == 0) {
	    i_1 = nif - 1;
	    x11.r = rfltrn_1.tupp[i_1].r, x11.i = rfltrn_1.tupp[i_1].i;
	    i_1 = nif - 1;
	    x22.r = rfltrn_1.tuss[i_1].r, x22.i = rfltrn_1.tuss[i_1].i;
	    i_1 = nif - 1;
	    x12.r = rfltrn_1.tups[i_1].r, x12.i = rfltrn_1.tups[i_1].i;
	    i_1 = nif - 1;
	    x21.r = rfltrn_1.tusp[i_1].r, x21.i = rfltrn_1.tusp[i_1].i;
	    i_1 = nif - 1;
	    xsh.r = rfltrn_1.tush[i_1].r, xsh.i = rfltrn_1.tush[i_1].i;
	    i_1 = nif - 1;
	    y11.r = rfltrn_1.rdpp[i_1].r, y11.i = rfltrn_1.rdpp[i_1].i;
	    i_1 = nif - 1;
	    y22.r = rfltrn_1.rdss[i_1].r, y22.i = rfltrn_1.rdss[i_1].i;
	    i_1 = nif - 1;
	    y12.r = rfltrn_1.rdps[i_1].r, y12.i = rfltrn_1.rdps[i_1].i;
	    i_1 = nif - 1;
	    y21.r = rfltrn_1.rdsp[i_1].r, y21.i = rfltrn_1.rdsp[i_1].i;
	    i_1 = nif - 1;
	    ysh.r = rfltrn_1.rdsh[i_1].r, ysh.i = rfltrn_1.rdsh[i_1].i;
	} else if (cnvnif == 1) {
	    i_1 = nif - 1;
	    x11.r = rfltrn_1.tupp[i_1].r, x11.i = rfltrn_1.tupp[i_1].i;
	    i_1 = nif - 1;
	    x22.r = rfltrn_1.tuss[i_1].r, x22.i = rfltrn_1.tuss[i_1].i;
	    x12.r = zero.r, x12.i = zero.i;
	    x21.r = zero.r, x21.i = zero.i;
	    i_1 = nif - 1;
	    xsh.r = rfltrn_1.tush[i_1].r, xsh.i = rfltrn_1.tush[i_1].i;
	    i_1 = nif - 1;
	    y11.r = rfltrn_1.rdpp[i_1].r, y11.i = rfltrn_1.rdpp[i_1].i;
	    i_1 = nif - 1;
	    y22.r = rfltrn_1.rdss[i_1].r, y22.i = rfltrn_1.rdss[i_1].i;
	    y12.r = zero.r, y12.i = zero.i;
	    y21.r = zero.r, y21.i = zero.i;
	    i_1 = nif - 1;
	    ysh.r = rfltrn_1.rdsh[i_1].r, ysh.i = rfltrn_1.rdsh[i_1].i;
	} else if (cnvnif == -1) {
	    i_1 = nif - 1;
	    x12.r = rfltrn_1.tups[i_1].r, x12.i = rfltrn_1.tups[i_1].i;
	    i_1 = nif - 1;
	    x21.r = rfltrn_1.tusp[i_1].r, x21.i = rfltrn_1.tusp[i_1].i;
	    x11.r = zero.r, x11.i = zero.i;
	    x22.r = zero.r, x22.i = zero.i;
	    i_1 = nif - 1;
	    xsh.r = rfltrn_1.tush[i_1].r, xsh.i = rfltrn_1.tush[i_1].i;
	    i_1 = nif - 1;
	    y12.r = rfltrn_1.rdps[i_1].r, y12.i = rfltrn_1.rdps[i_1].i;
	    i_1 = nif - 1;
	    y21.r = rfltrn_1.rdsp[i_1].r, y21.i = rfltrn_1.rdsp[i_1].i;
	    y11.r = zero.r, y11.i = zero.i;
	    y22.r = zero.r, y22.i = zero.i;
	    i_1 = nif - 1;
	    ysh.r = rfltrn_1.rdsh[i_1].r, ysh.i = rfltrn_1.rdsh[i_1].i;
	}

	q_2.r = l11.r * tnupp.r - l11.i * tnupp.i, q_2.i = l11.r * tnupp.i + 
		l11.i * tnupp.r;
	q_3.r = l12.r * tnusp.r - l12.i * tnusp.i, q_3.i = l12.r * tnusp.i + 
		l12.i * tnusp.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	t11.r = q_1.r, t11.i = q_1.i;
	q_2.r = l21.r * tnups.r - l21.i * tnups.i, q_2.i = l21.r * tnups.i + 
		l21.i * tnups.r;
	q_3.r = l22.r * tnuss.r - l22.i * tnuss.i, q_3.i = l22.r * tnuss.i + 
		l22.i * tnuss.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	t22.r = q_1.r, t22.i = q_1.i;
	q_2.r = l21.r * tnupp.r - l21.i * tnupp.i, q_2.i = l21.r * tnupp.i + 
		l21.i * tnupp.r;
	q_3.r = l22.r * tnusp.r - l22.i * tnusp.i, q_3.i = l22.r * tnusp.i + 
		l22.i * tnusp.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	t21.r = q_1.r, t21.i = q_1.i;
	q_2.r = l11.r * tnups.r - l11.i * tnups.i, q_2.i = l11.r * tnups.i + 
		l11.i * tnups.r;
	q_3.r = l12.r * tnuss.r - l12.i * tnuss.i, q_3.i = l12.r * tnuss.i + 
		l12.i * tnuss.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	t12.r = q_1.r, t12.i = q_1.i;
	q_1.r = lsh.r * tnush.r - lsh.i * tnush.i, q_1.i = lsh.r * tnush.i + 
		lsh.i * tnush.r;
	tsh.r = q_1.r, tsh.i = q_1.i;

/*        tnupp = tupp(nif)*t11 + tups(nif)*t21 */
/*        tnuss = tusp(nif)*t12 + tuss(nif)*t22 */
/*        tnups = tupp(nif)*t12 + tups(nif)*t22 */
/*        tnusp = tusp(nif)*t11 + tuss(nif)*t21 */
	q_2.r = x11.r * t11.r - x11.i * t11.i, q_2.i = x11.r * t11.i + x11.i *
		 t11.r;
	q_3.r = x12.r * t21.r - x12.i * t21.i, q_3.i = x12.r * t21.i + x12.i *
		 t21.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	tnupp.r = q_1.r, tnupp.i = q_1.i;
	q_2.r = x21.r * t12.r - x21.i * t12.i, q_2.i = x21.r * t12.i + x21.i *
		 t12.r;
	q_3.r = x22.r * t22.r - x22.i * t22.i, q_3.i = x22.r * t22.i + x22.i *
		 t22.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	tnuss.r = q_1.r, tnuss.i = q_1.i;
	q_2.r = x11.r * t12.r - x11.i * t12.i, q_2.i = x11.r * t12.i + x11.i *
		 t12.r;
	q_3.r = x12.r * t22.r - x12.i * t22.i, q_3.i = x12.r * t22.i + x12.i *
		 t22.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	tnups.r = q_1.r, tnups.i = q_1.i;
	q_2.r = x21.r * t11.r - x21.i * t11.i, q_2.i = x21.r * t11.i + x21.i *
		 t11.r;
	q_3.r = x22.r * t21.r - x22.i * t21.i, q_3.i = x22.r * t21.i + x22.i *
		 t21.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	tnusp.r = q_1.r, tnusp.i = q_1.i;
	q_1.r = xsh.r * tsh.r - xsh.i * tsh.i, q_1.i = xsh.r * tsh.i + xsh.i *
		 tsh.r;
	tnush.r = q_1.r, tnush.i = q_1.i;

/*        t11 = l11*tdpp(nif) + l21*tdsp(nif) */
/*        t12 = l11*tdps(nif) + l21*tdss(nif) */
/*        t21 = l12*tdpp(nif) + l22*tdsp(nif) */
/*        t22 = l12*tdps(nif) + l22*tdss(nif) */
	q_2.r = l11.r * x11.r - l11.i * x11.i, q_2.i = l11.r * x11.i + l11.i *
		 x11.r;
	q_3.r = l21.r * x12.r - l21.i * x12.i, q_3.i = l21.r * x12.i + l21.i *
		 x12.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	t11.r = q_1.r, t11.i = q_1.i;
	q_2.r = l11.r * x21.r - l11.i * x21.i, q_2.i = l11.r * x21.i + l11.i *
		 x21.r;
	q_3.r = l21.r * x22.r - l21.i * x22.i, q_3.i = l21.r * x22.i + l21.i *
		 x22.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	t12.r = q_1.r, t12.i = q_1.i;
	q_2.r = l12.r * x11.r - l12.i * x11.i, q_2.i = l12.r * x11.i + l12.i *
		 x11.r;
	q_3.r = l22.r * x12.r - l22.i * x12.i, q_3.i = l22.r * x12.i + l22.i *
		 x12.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	t21.r = q_1.r, t21.i = q_1.i;
	q_2.r = l12.r * x21.r - l12.i * x21.i, q_2.i = l12.r * x21.i + l12.i *
		 x21.r;
	q_3.r = l22.r * x22.r - l22.i * x22.i, q_3.i = l22.r * x22.i + l22.i *
		 x22.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	t22.r = q_1.r, t22.i = q_1.i;
	q_1.r = lsh.r * xsh.r - lsh.i * xsh.i, q_1.i = lsh.r * xsh.i + lsh.i *
		 xsh.r;
	tsh.r = q_1.r, tsh.i = q_1.i;
	q_2.r = rndpp.r * t11.r - rndpp.i * t11.i, q_2.i = rndpp.r * t11.i + 
		rndpp.i * t11.r;
	q_3.r = rndps.r * t21.r - rndps.i * t21.i, q_3.i = rndps.r * t21.i + 
		rndps.i * t21.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	l11.r = q_1.r, l11.i = q_1.i;
	q_2.r = rndpp.r * t12.r - rndpp.i * t12.i, q_2.i = rndpp.r * t12.i + 
		rndpp.i * t12.r;
	q_3.r = rndps.r * t22.r - rndps.i * t22.i, q_3.i = rndps.r * t22.i + 
		rndps.i * t22.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	l12.r = q_1.r, l12.i = q_1.i;
	q_2.r = rndsp.r * t11.r - rndsp.i * t11.i, q_2.i = rndsp.r * t11.i + 
		rndsp.i * t11.r;
	q_3.r = rndss.r * t21.r - rndss.i * t21.i, q_3.i = rndss.r * t21.i + 
		rndss.i * t21.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	l21.r = q_1.r, l21.i = q_1.i;
	q_2.r = rndsp.r * t12.r - rndsp.i * t12.i, q_2.i = rndsp.r * t12.i + 
		rndsp.i * t12.r;
	q_3.r = rndss.r * t22.r - rndss.i * t22.i, q_3.i = rndss.r * t22.i + 
		rndss.i * t22.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	l22.r = q_1.r, l22.i = q_1.i;
	q_1.r = rndsh.r * tsh.r - rndsh.i * tsh.i, q_1.i = rndsh.r * tsh.i + 
		rndsh.i * tsh.r;
	lsh.r = q_1.r, lsh.i = q_1.i;
/*        rndpp = rdpp(nif) + tupp(nif)*l11 + tups(nif)*l21 */
/*        rndss = rdss(nif) + tusp(nif)*l12 + tuss(nif)*l22 */
/*        rndps = rdps(nif) + tupp(nif)*l12 + tups(nif)*l22 */
/*        rndsp = rdsp(nif) + tusp(nif)*l11 + tuss(nif)*l21 */
	q_3.r = x11.r * l11.r - x11.i * l11.i, q_3.i = x11.r * l11.i + x11.i *
		 l11.r;
	q_2.r = y11.r + q_3.r, q_2.i = y11.i + q_3.i;
	q_4.r = x12.r * l21.r - x12.i * l21.i, q_4.i = x12.r * l21.i + x12.i *
		 l21.r;
	q_1.r = q_2.r + q_4.r, q_1.i = q_2.i + q_4.i;
	rndpp.r = q_1.r, rndpp.i = q_1.i;
	q_3.r = x21.r * l12.r - x21.i * l12.i, q_3.i = x21.r * l12.i + x21.i *
		 l12.r;
	q_2.r = y22.r + q_3.r, q_2.i = y22.i + q_3.i;
	q_4.r = x22.r * l22.r - x22.i * l22.i, q_4.i = x22.r * l22.i + x22.i *
		 l22.r;
	q_1.r = q_2.r + q_4.r, q_1.i = q_2.i + q_4.i;
	rndss.r = q_1.r, rndss.i = q_1.i;
	q_3.r = x11.r * l12.r - x11.i * l12.i, q_3.i = x11.r * l12.i + x11.i *
		 l12.r;
	q_2.r = y12.r + q_3.r, q_2.i = y12.i + q_3.i;
	q_4.r = x12.r * l22.r - x12.i * l22.i, q_4.i = x12.r * l22.i + x12.i *
		 l22.r;
	q_1.r = q_2.r + q_4.r, q_1.i = q_2.i + q_4.i;
	rndps.r = q_1.r, rndps.i = q_1.i;
	q_3.r = x21.r * l11.r - x21.i * l11.i, q_3.i = x21.r * l11.i + x21.i *
		 l11.r;
	q_2.r = y21.r + q_3.r, q_2.i = y21.i + q_3.i;
	q_4.r = x22.r * l21.r - x22.i * l21.i, q_4.i = x22.r * l21.i + x22.i *
		 l21.r;
	q_1.r = q_2.r + q_4.r, q_1.i = q_2.i + q_4.i;
	rndsp.r = q_1.r, rndsp.i = q_1.i;
	q_2.r = xsh.r * lsh.r - xsh.i * lsh.i, q_2.i = xsh.r * lsh.i + xsh.i *
		 lsh.r;
	q_1.r = ysh.r + q_2.r, q_1.i = ysh.i + q_2.i;
	rndsh.r = q_1.r, rndsh.i = q_1.i;

/* L10: */
    }

/*        use the two way phase delay through the top layer */

    q_5.r = -(doublereal)i.r, q_5.i = -(doublereal)i.i;
    q_4.r = q_5.r * w.r - q_5.i * w.i, q_4.i = q_5.r * w.i + q_5.i * w.r;
    i_1 = lyr - 1;
    q_3.r = q_4.r * rfltrn_1.xi[i_1].r - q_4.i * rfltrn_1.xi[i_1].i, q_3.i = 
	    q_4.r * rfltrn_1.xi[i_1].i + q_4.i * rfltrn_1.xi[i_1].r;
    i_2 = lyr - 1;
    q_2.r = model_1.thik[i_2] * q_3.r, q_2.i = model_1.thik[i_2] * q_3.i;
    cphs_(&q_1, &q_2);
    phtp.r = q_1.r, phtp.i = q_1.i;
    q_5.r = -(doublereal)i.r, q_5.i = -(doublereal)i.i;
    q_4.r = q_5.r * w.r - q_5.i * w.i, q_4.i = q_5.r * w.i + q_5.i * w.r;
    i_1 = lyr - 1;
    q_3.r = q_4.r * rfltrn_1.eta[i_1].r - q_4.i * rfltrn_1.eta[i_1].i, q_3.i =
	     q_4.r * rfltrn_1.eta[i_1].i + q_4.i * rfltrn_1.eta[i_1].r;
    i_2 = lyr - 1;
    q_2.r = model_1.thik[i_2] * q_3.r, q_2.i = model_1.thik[i_2] * q_3.i;
    cphs_(&q_1, &q_2);
    phts.r = q_1.r, phts.i = q_1.i;
    q_1.r = phtp.r * phtp.r - phtp.i * phtp.i, q_1.i = phtp.r * phtp.i + 
	    phtp.i * phtp.r;
    phtpp.r = q_1.r, phtpp.i = q_1.i;
    q_1.r = phtp.r * phts.r - phtp.i * phts.i, q_1.i = phtp.r * phts.i + 
	    phtp.i * phts.r;
    phtps.r = q_1.r, phtps.i = q_1.i;
    q_1.r = phts.r * phts.r - phts.i * phts.i, q_1.i = phts.r * phts.i + 
	    phts.i * phts.r;
    phtss.r = q_1.r, phtss.i = q_1.i;
    q_1.r = tnupp.r * phtp.r - tnupp.i * phtp.i, q_1.i = tnupp.r * phtp.i + 
	    tnupp.i * phtp.r;
    tnupp.r = q_1.r, tnupp.i = q_1.i;
    q_1.r = tnuss.r * phts.r - tnuss.i * phts.i, q_1.i = tnuss.r * phts.i + 
	    tnuss.i * phts.r;
    tnuss.r = q_1.r, tnuss.i = q_1.i;
    q_1.r = tnups.r * phtp.r - tnups.i * phtp.i, q_1.i = tnups.r * phtp.i + 
	    tnups.i * phtp.r;
    tnups.r = q_1.r, tnups.i = q_1.i;
    q_1.r = tnusp.r * phts.r - tnusp.i * phts.i, q_1.i = tnusp.r * phts.i + 
	    tnusp.i * phts.r;
    tnusp.r = q_1.r, tnusp.i = q_1.i;
    q_1.r = tnush.r * phts.r - tnush.i * phts.i, q_1.i = tnush.r * phts.i + 
	    tnush.i * phts.r;
    tnush.r = q_1.r, tnush.i = q_1.i;
    q_1.r = rndpp.r * phtpp.r - rndpp.i * phtpp.i, q_1.i = rndpp.r * phtpp.i 
	    + rndpp.i * phtpp.r;
    rndpp.r = q_1.r, rndpp.i = q_1.i;
    q_1.r = rndss.r * phtss.r - rndss.i * phtss.i, q_1.i = rndss.r * phtss.i 
	    + rndss.i * phtss.r;
    rndss.r = q_1.r, rndss.i = q_1.i;
    q_1.r = rndps.r * phtps.r - rndps.i * phtps.i, q_1.i = rndps.r * phtps.i 
	    + rndps.i * phtps.r;
    rndps.r = q_1.r, rndps.i = q_1.i;
    q_1.r = rndsp.r * phtps.r - rndsp.i * phtps.i, q_1.i = rndsp.r * phtps.i 
	    + rndsp.i * phtps.r;
    rndsp.r = q_1.r, rndsp.i = q_1.i;
    q_1.r = rndsh.r * phtss.r - rndsh.i * phtss.i, q_1.i = rndsh.r * phtss.i 
	    + rndsh.i * phtss.r;
    rndsh.r = q_1.r, rndsh.i = q_1.i;

/*        form the reverberation operator for the top layer */

    cnvnif = rfltrn_1.cnvrsn[0];
    if (cnvnif == 0) {
	t11.r = rfltrn_1.ruppfs.r, t11.i = rfltrn_1.ruppfs.i;
	t22.r = rfltrn_1.russfs.r, t22.i = rfltrn_1.russfs.i;
	t12.r = rfltrn_1.rupsfs.r, t12.i = rfltrn_1.rupsfs.i;
	t21.r = rfltrn_1.ruspfs.r, t21.i = rfltrn_1.ruspfs.i;
	tsh.r = rfltrn_1.rushfs.r, tsh.i = rfltrn_1.rushfs.i;
    } else if (cnvnif == 1) {
	t11.r = rfltrn_1.ruppfs.r, t11.i = rfltrn_1.ruppfs.i;
	t22.r = rfltrn_1.russfs.r, t22.i = rfltrn_1.russfs.i;
	t12.r = zero.r, t12.i = zero.i;
	t21.r = zero.r, t21.i = zero.i;
	tsh.r = rfltrn_1.rushfs.r, tsh.i = rfltrn_1.rushfs.i;
    } else if (cnvnif == -1) {
	t12.r = rfltrn_1.rupsfs.r, t12.i = rfltrn_1.rupsfs.i;
	t21.r = rfltrn_1.ruspfs.r, t21.i = rfltrn_1.ruspfs.i;
	t11.r = zero.r, t11.i = zero.i;
	t22.r = zero.r, t22.i = zero.i;
	tsh.r = rfltrn_1.rushfs.r, tsh.i = rfltrn_1.rushfs.i;
    }
    if (rfltrn_1.reverb[lyr - 1] == -1) {
	q_3.r = rndpp.r * t11.r - rndpp.i * t11.i, q_3.i = rndpp.r * t11.i + 
		rndpp.i * t11.r;
	q_4.r = rndps.r * t21.r - rndps.i * t21.i, q_4.i = rndps.r * t21.i + 
		rndps.i * t21.r;
	q_2.r = q_3.r + q_4.r, q_2.i = q_3.i + q_4.i;
	q_1.r = one.r - q_2.r, q_1.i = one.i - q_2.i;
	l11.r = q_1.r, l11.i = q_1.i;
	q_3.r = rndsp.r * t12.r - rndsp.i * t12.i, q_3.i = rndsp.r * t12.i + 
		rndsp.i * t12.r;
	q_4.r = rndss.r * t22.r - rndss.i * t22.i, q_4.i = rndss.r * t22.i + 
		rndss.i * t22.r;
	q_2.r = q_3.r + q_4.r, q_2.i = q_3.i + q_4.i;
	q_1.r = one.r - q_2.r, q_1.i = one.i - q_2.i;
	l22.r = q_1.r, l22.i = q_1.i;
	q_3.r = rndpp.r * t12.r - rndpp.i * t12.i, q_3.i = rndpp.r * t12.i + 
		rndpp.i * t12.r;
	q_4.r = rndps.r * t22.r - rndps.i * t22.i, q_4.i = rndps.r * t22.i + 
		rndps.i * t22.r;
	q_2.r = q_3.r + q_4.r, q_2.i = q_3.i + q_4.i;
	q_1.r = -(doublereal)q_2.r, q_1.i = -(doublereal)q_2.i;
	l12.r = q_1.r, l12.i = q_1.i;
	q_3.r = rndsp.r * t11.r - rndsp.i * t11.i, q_3.i = rndsp.r * t11.i + 
		rndsp.i * t11.r;
	q_4.r = rndss.r * t21.r - rndss.i * t21.i, q_4.i = rndss.r * t21.i + 
		rndss.i * t21.r;
	q_2.r = q_3.r + q_4.r, q_2.i = q_3.i + q_4.i;
	q_1.r = -(doublereal)q_2.r, q_1.i = -(doublereal)q_2.i;
	l21.r = q_1.r, l21.i = q_1.i;
	q_2.r = l11.r * l22.r - l11.i * l22.i, q_2.i = l11.r * l22.i + l11.i *
		 l22.r;
	q_3.r = l12.r * l21.r - l12.i * l21.i, q_3.i = l12.r * l21.i + l12.i *
		 l21.r;
	q_1.r = q_2.r - q_3.r, q_1.i = q_2.i - q_3.i;
	det.r = q_1.r, det.i = q_1.i;
	q_1.r = -(doublereal)l12.r, q_1.i = -(doublereal)l12.i;
	z_2.r = q_1.r, z_2.i = q_1.i;
	z_div(&z_1, &z_2, &det);
	l12.r = z_1.r, l12.i = z_1.i;
	q_1.r = -(doublereal)l21.r, q_1.i = -(doublereal)l21.i;
	z_2.r = q_1.r, z_2.i = q_1.i;
	z_div(&z_1, &z_2, &det);
	l21.r = z_1.r, l21.i = z_1.i;
	z_2.r = l11.r, z_2.i = l11.i;
	z_div(&z_1, &z_2, &det);
	t11.r = z_1.r, t11.i = z_1.i;
	z_2.r = l22.r, z_2.i = l22.i;
	z_div(&z_1, &z_2, &det);
	l11.r = z_1.r, l11.i = z_1.i;
	l22.r = t11.r, l22.i = t11.i;
	q_3.r = rndsh.r * tsh.r - rndsh.i * tsh.i, q_3.i = rndsh.r * tsh.i + 
		rndsh.i * tsh.r;
	q_2.r = one.r - q_3.r, q_2.i = one.i - q_3.i;
	c_div(&q_1, &one, &q_2);
	lsh.r = q_1.r, lsh.i = q_1.i;
    } else if (rfltrn_1.reverb[lyr - 1] == 1) {
	q_3.r = rndpp.r * t11.r - rndpp.i * t11.i, q_3.i = rndpp.r * t11.i + 
		rndpp.i * t11.r;
	q_4.r = rndps.r * t21.r - rndps.i * t21.i, q_4.i = rndps.r * t21.i + 
		rndps.i * t21.r;
	q_2.r = q_3.r + q_4.r, q_2.i = q_3.i + q_4.i;
	q_1.r = one.r + q_2.r, q_1.i = one.i + q_2.i;
	l11.r = q_1.r, l11.i = q_1.i;
	q_3.r = rndsp.r * t12.r - rndsp.i * t12.i, q_3.i = rndsp.r * t12.i + 
		rndsp.i * t12.r;
	q_4.r = rndss.r * t22.r - rndss.i * t22.i, q_4.i = rndss.r * t22.i + 
		rndss.i * t22.r;
	q_2.r = q_3.r + q_4.r, q_2.i = q_3.i + q_4.i;
	q_1.r = one.r + q_2.r, q_1.i = one.i + q_2.i;
	l22.r = q_1.r, l22.i = q_1.i;
	q_2.r = rndpp.r * t12.r - rndpp.i * t12.i, q_2.i = rndpp.r * t12.i + 
		rndpp.i * t12.r;
	q_3.r = rndps.r * t22.r - rndps.i * t22.i, q_3.i = rndps.r * t22.i + 
		rndps.i * t22.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	l12.r = q_1.r, l12.i = q_1.i;
	q_2.r = rndsp.r * t11.r - rndsp.i * t11.i, q_2.i = rndsp.r * t11.i + 
		rndsp.i * t11.r;
	q_3.r = rndss.r * t21.r - rndss.i * t21.i, q_3.i = rndss.r * t21.i + 
		rndss.i * t21.r;
	q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
	l21.r = q_1.r, l21.i = q_1.i;
	q_2.r = rndsh.r * tsh.r - rndsh.i * tsh.i, q_2.i = rndsh.r * tsh.i + 
		rndsh.i * tsh.r;
	q_1.r = one.r + q_2.r, q_1.i = one.i + q_2.i;
	lsh.r = q_1.r, lsh.i = q_1.i;
    } else if (rfltrn_1.reverb[lyr - 1] == 0) {
	l11.r = one.r, l11.i = one.i;
	l22.r = one.r, l22.i = one.i;
	l12.r = zero.r, l12.i = zero.i;
	l21.r = zero.r, l21.i = zero.i;
	lsh.r = one.r, lsh.i = one.i;
    }

/*        now add the free surface displacement */

    q_2.r = l11.r * tnupp.r - l11.i * tnupp.i, q_2.i = l11.r * tnupp.i + 
	    l11.i * tnupp.r;
    q_3.r = l12.r * tnusp.r - l12.i * tnusp.i, q_3.i = l12.r * tnusp.i + 
	    l12.i * tnusp.r;
    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
    t11.r = q_1.r, t11.i = q_1.i;
    q_2.r = l21.r * tnups.r - l21.i * tnups.i, q_2.i = l21.r * tnups.i + 
	    l21.i * tnups.r;
    q_3.r = l22.r * tnuss.r - l22.i * tnuss.i, q_3.i = l22.r * tnuss.i + 
	    l22.i * tnuss.r;
    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
    t22.r = q_1.r, t22.i = q_1.i;
    q_2.r = l21.r * tnupp.r - l21.i * tnupp.i, q_2.i = l21.r * tnupp.i + 
	    l21.i * tnupp.r;
    q_3.r = l22.r * tnusp.r - l22.i * tnusp.i, q_3.i = l22.r * tnusp.i + 
	    l22.i * tnusp.r;
    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
    t21.r = q_1.r, t21.i = q_1.i;
    q_2.r = l11.r * tnups.r - l11.i * tnups.i, q_2.i = l11.r * tnups.i + 
	    l11.i * tnups.r;
    q_3.r = l12.r * tnuss.r - l12.i * tnuss.i, q_3.i = l12.r * tnuss.i + 
	    l12.i * tnuss.r;
    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
    t12.r = q_1.r, t12.i = q_1.i;
    q_1.r = lsh.r * tnush.r - lsh.i * tnush.i, q_1.i = lsh.r * tnush.i + 
	    lsh.i * tnush.r;
    tsh.r = q_1.r, tsh.i = q_1.i;
    q_2.r = rfltrn_1.dvpfs.r * t11.r - rfltrn_1.dvpfs.i * t11.i, q_2.i = 
	    rfltrn_1.dvpfs.r * t11.i + rfltrn_1.dvpfs.i * t11.r;
    q_3.r = rfltrn_1.dvsfs.r * t21.r - rfltrn_1.dvsfs.i * t21.i, q_3.i = 
	    rfltrn_1.dvsfs.r * t21.i + rfltrn_1.dvsfs.i * t21.r;
    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
    dvp->r = q_1.r, dvp->i = q_1.i;
    q_2.r = rfltrn_1.dvpfs.r * t12.r - rfltrn_1.dvpfs.i * t12.i, q_2.i = 
	    rfltrn_1.dvpfs.r * t12.i + rfltrn_1.dvpfs.i * t12.r;
    q_3.r = rfltrn_1.dvsfs.r * t22.r - rfltrn_1.dvsfs.i * t22.i, q_3.i = 
	    rfltrn_1.dvsfs.r * t22.i + rfltrn_1.dvsfs.i * t22.r;
    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
    dvs->r = q_1.r, dvs->i = q_1.i;
    q_2.r = rfltrn_1.drpfs.r * t11.r - rfltrn_1.drpfs.i * t11.i, q_2.i = 
	    rfltrn_1.drpfs.r * t11.i + rfltrn_1.drpfs.i * t11.r;
    q_3.r = rfltrn_1.drsfs.r * t21.r - rfltrn_1.drsfs.i * t21.i, q_3.i = 
	    rfltrn_1.drsfs.r * t21.i + rfltrn_1.drsfs.i * t21.r;
    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
    drp->r = q_1.r, drp->i = q_1.i;
    q_2.r = rfltrn_1.drpfs.r * t12.r - rfltrn_1.drpfs.i * t12.i, q_2.i = 
	    rfltrn_1.drpfs.r * t12.i + rfltrn_1.drpfs.i * t12.r;
    q_3.r = rfltrn_1.drsfs.r * t22.r - rfltrn_1.drsfs.i * t22.i, q_3.i = 
	    rfltrn_1.drsfs.r * t22.i + rfltrn_1.drsfs.i * t22.r;
    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
    drs->r = q_1.r, drs->i = q_1.i;
    q_1.r = rfltrn_1.dtshfs.r * tsh.r - rfltrn_1.dtshfs.i * tsh.i, q_1.i = 
	    rfltrn_1.dtshfs.r * tsh.i + rfltrn_1.dtshfs.i * tsh.r;
    dts->r = q_1.r, dts->i = q_1.i;



    return 0;
} /* rcvrfn_ */

/* Complex */ int vslow_(ret_val, v, p, f)
complex *ret_val;
complex *v, *p, *f;
{
    /* System generated locals */
    real r_1, r_2;
    complex q_1, q_2, q_3, q_4, q_5;

    /* Builtin functions */
    void c_div(), c_sqrt();
    double r_imag();

    /* Local variables */
    static real t;

    q_4.r = v->r * v->r - v->i * v->i, q_4.i = v->r * v->i + v->i * v->r;
    c_div(&q_3, &c_b51, &q_4);
    q_5.r = p->r * p->r - p->i * p->i, q_5.i = p->r * p->i + p->i * p->r;
    q_2.r = q_3.r - q_5.r, q_2.i = q_3.i - q_5.i;
    c_sqrt(&q_1, &q_2);
    ret_val->r = q_1.r, ret_val->i = q_1.i;
    t = (r_1 = ret_val->r, dabs(r_1)) + (r_2 = r_imag(ret_val), dabs(r_2));
    if (t < (float).001) {
	c_div(&q_2, &c_b86, v);
	c_sqrt(&q_1, &q_2);
	ret_val->r = q_1.r, ret_val->i = q_1.i;
    }
    q_1.r = f->r * ret_val->r - f->i * ret_val->i, q_1.i = f->r * ret_val->i 
	    + f->i * ret_val->r;
    if (r_imag(&q_1) > (float)0.) {
	q_2.r = -(doublereal)ret_val->r, q_2.i = -(doublereal)ret_val->i;
	ret_val->r = q_2.r, ret_val->i = q_2.i;
    }
    return ;
} /* vslow_ */

/* Complex */ int cphs_(ret_val, arg)
complex *ret_val;
complex *arg;
{
    /* System generated locals */
    complex q_1;

    /* Builtin functions */
    void c_exp();

    if (arg->r < (float)-20.) {
	ret_val->r = (float)0., ret_val->i = (float)0.;
    } else {
	c_exp(&q_1, arg);
	ret_val->r = q_1.r, ret_val->i = q_1.i;
    }
    return ;
} /* cphs_ */

/* Subroutine */ int ifmat_(psvsh, p, f, nlyrs)
integer *psvsh;
complex *p, *f;
integer *nlyrs;
{
    /* Initialized data */

    static real twopi = (float)6.2831853;
    static complex i = {(float)0.,(float)1.};
    static complex one = {(float)1.,(float)0.};
    static complex two = {(float)2.,(float)0.};

    /* System generated locals */
    integer i_1, i_2, i_3;
    complex q_1, q_2, q_3, q_4, q_5, q_6, q_7;

    /* Builtin functions */
    void c_sqrt(), c_div();

    /* Local variables */
    static complex mdm11, mdm12, mdm21, mdm22, mdp11, mdp12, mdp21, mdp22, 
	    mum11, mum12, mum21, mum22, mup11, mup12, mup21, mup22, num11, 
	    num12, num21, num22, nup11, nup12, nup21, nup22, ndm11, ndm12, 
	    ndm21, ndm22, ndp11, ndp12, ndp21, ndp22, etap, etam, epap, epam, 
	    epbp, epbm, alfam, rhom, alfap, rhop, betam, w, zshp, betap, zshm,
	     t1, t2;
    extern /* Complex */ int vslow_();
    static complex l11, l12, l21, l22, t11, t12, t21, t22;
    static logical shwave, psvwav;
    static complex det, xim, mum, xip, mup;
    static integer lyr;


/*           compute kennett's interface matricies for n layer model */
/*        for a p, sv or sh wave incident */
/*        interface 0 is top of layer 1, a free surface, compute */
/*        reflection operator, and free surface displacement operator */
/*        layer n is half space */
/*        compute ru, rd, tu, td at interfaces */
/*        given frequency and phase slowness. */

/*          arguments... */
/*        psvsh = 1,2,3 for an incident p, sv or sh wave. */

/*        f,p - prescribed freq (hz) & horizontal phase slowness (c is */
/*            not restricted to be greater than alfa or beta) */
/*            both may be complex */

/*        passed in common /model/ */
/*        alfa,beta,qp,qs,rho and thik contain the medium properties for 
*/
/*            layers 1 thru nlyrs (the halfspace) */

/*        nlyrs - total number of layers, layer nlyrs is */
/*            the half space */



/*        commons and declarations */



/*        complex declarations */


/* 	model parameters */


/* 	interface reflection and transmission coefficients */


/* 	interface and layer matricies for perturbations */
/* 	used in partial derivative calculations for */
/* 	inversion process */


/* 	source parameters for moment tensor sources */


/* 	layered medium response for buried source */




    q_1.r = twopi * f->r, q_1.i = twopi * f->i;
    w.r = q_1.r, w.i = q_1.i;
/*     if(f .eq. (0.,0.)) w = (1.0e-6,0.) */
    shwave = *psvsh == 3;
    psvwav = *psvsh <= 2;



    alfam.r = model_1.alfa[0].r, alfam.i = model_1.alfa[0].i;
    betam.r = model_1.beta[0].r, betam.i = model_1.beta[0].i;
    rhom.r = model_1.rho[0], rhom.i = (float)0.;
    q_2.r = betam.r * betam.r - betam.i * betam.i, q_2.i = betam.r * betam.i 
	    + betam.i * betam.r;
    q_1.r = q_2.r * rhom.r - q_2.i * rhom.i, q_1.i = q_2.r * rhom.i + q_2.i * 
	    rhom.r;
    mum.r = q_1.r, mum.i = q_1.i;
    vslow_(&q_1, &alfam, p, f);
    xim.r = q_1.r, xim.i = q_1.i;
    vslow_(&q_1, &betam, p, f);
    etam.r = q_1.r, etam.i = q_1.i;
    rfltrn_1.xi[0].r = xim.r, rfltrn_1.xi[0].i = xim.i;
    rfltrn_1.eta[0].r = etam.r, rfltrn_1.eta[0].i = etam.i;
    q_4.r = two.r * rhom.r - two.i * rhom.i, q_4.i = two.r * rhom.i + two.i * 
	    rhom.r;
    q_3.r = q_4.r * xim.r - q_4.i * xim.i, q_3.i = q_4.r * xim.i + q_4.i * 
	    xim.r;
    c_sqrt(&q_2, &q_3);
    c_div(&q_1, &one, &q_2);
    epam.r = q_1.r, epam.i = q_1.i;
    q_4.r = two.r * rhom.r - two.i * rhom.i, q_4.i = two.r * rhom.i + two.i * 
	    rhom.r;
    q_3.r = q_4.r * etam.r - q_4.i * etam.i, q_3.i = q_4.r * etam.i + q_4.i * 
	    etam.r;
    c_sqrt(&q_2, &q_3);
    c_div(&q_1, &one, &q_2);
    epbm.r = q_1.r, epbm.i = q_1.i;
    q_2.r = two.r * mum.r - two.i * mum.i, q_2.i = two.r * mum.i + two.i * 
	    mum.r;
    q_1.r = q_2.r * p->r - q_2.i * p->i, q_1.i = q_2.r * p->i + q_2.i * p->r;
    t1.r = q_1.r, t1.i = q_1.i;
    q_2.r = t1.r * p->r - t1.i * p->i, q_2.i = t1.r * p->i + t1.i * p->r;
    q_1.r = q_2.r - rhom.r, q_1.i = q_2.i - rhom.i;
    t2.r = q_1.r, t2.i = q_1.i;

/*        form layer 1 matricies for free surface and interface 1 */

    q_2.r = i.r * xim.r - i.i * xim.i, q_2.i = i.r * xim.i + i.i * xim.r;
    q_1.r = q_2.r * epam.r - q_2.i * epam.i, q_1.i = q_2.r * epam.i + q_2.i * 
	    epam.r;
    mdm11.r = q_1.r, mdm11.i = q_1.i;
    q_1.r = -(doublereal)mdm11.r, q_1.i = -(doublereal)mdm11.i;
    mum11.r = q_1.r, mum11.i = q_1.i;
    q_1.r = p->r * epbm.r - p->i * epbm.i, q_1.i = p->r * epbm.i + p->i * 
	    epbm.r;
    mdm12.r = q_1.r, mdm12.i = q_1.i;
    mum12.r = mdm12.r, mum12.i = mdm12.i;
    q_1.r = p->r * epam.r - p->i * epam.i, q_1.i = p->r * epam.i + p->i * 
	    epam.r;
    mdm21.r = q_1.r, mdm21.i = q_1.i;
    mum21.r = mdm21.r, mum21.i = mdm21.i;
    q_2.r = i.r * etam.r - i.i * etam.i, q_2.i = i.r * etam.i + i.i * etam.r;
    q_1.r = q_2.r * epbm.r - q_2.i * epbm.i, q_1.i = q_2.r * epbm.i + q_2.i * 
	    epbm.r;
    mdm22.r = q_1.r, mdm22.i = q_1.i;
    q_1.r = -(doublereal)mdm22.r, q_1.i = -(doublereal)mdm22.i;
    mum22.r = q_1.r, mum22.i = q_1.i;
    q_1.r = t2.r * epam.r - t2.i * epam.i, q_1.i = t2.r * epam.i + t2.i * 
	    epam.r;
    ndm11.r = q_1.r, ndm11.i = q_1.i;
    num11.r = ndm11.r, num11.i = ndm11.i;
    q_1.r = t1.r * mdm22.r - t1.i * mdm22.i, q_1.i = t1.r * mdm22.i + t1.i * 
	    mdm22.r;
    ndm12.r = q_1.r, ndm12.i = q_1.i;
    q_1.r = -(doublereal)ndm12.r, q_1.i = -(doublereal)ndm12.i;
    num12.r = q_1.r, num12.i = q_1.i;
    q_1.r = t1.r * mdm11.r - t1.i * mdm11.i, q_1.i = t1.r * mdm11.i + t1.i * 
	    mdm11.r;
    ndm21.r = q_1.r, ndm21.i = q_1.i;
    q_1.r = -(doublereal)ndm21.r, q_1.i = -(doublereal)ndm21.i;
    num21.r = q_1.r, num21.i = q_1.i;
    q_1.r = t2.r * epbm.r - t2.i * epbm.i, q_1.i = t2.r * epbm.i + t2.i * 
	    epbm.r;
    ndm22.r = q_1.r, ndm22.i = q_1.i;
    num22.r = ndm22.r, num22.i = ndm22.i;
    q_1.r = mum.r * etam.r - mum.i * etam.i, q_1.i = mum.r * etam.i + mum.i * 
	    etam.r;
    zshm.r = q_1.r, zshm.i = q_1.i;

/*        calculate the free surface reflection matrix, and free surface 
*/
/*        free surface displacement operator. */

    q_2.r = ndm11.r * ndm22.r - ndm11.i * ndm22.i, q_2.i = ndm11.r * ndm22.i 
	    + ndm11.i * ndm22.r;
    q_3.r = ndm12.r * ndm21.r - ndm12.i * ndm21.i, q_3.i = ndm12.r * ndm21.i 
	    + ndm12.i * ndm21.r;
    q_1.r = q_2.r - q_3.r, q_1.i = q_2.i - q_3.i;
    det.r = q_1.r, det.i = q_1.i;
    c_div(&q_1, &one, &det);
    det.r = q_1.r, det.i = q_1.i;
    q_2.r = -(doublereal)ndm22.r, q_2.i = -(doublereal)ndm22.i;
    q_1.r = q_2.r * det.r - q_2.i * det.i, q_1.i = q_2.r * det.i + q_2.i * 
	    det.r;
    t11.r = q_1.r, t11.i = q_1.i;
    q_2.r = -(doublereal)ndm11.r, q_2.i = -(doublereal)ndm11.i;
    q_1.r = q_2.r * det.r - q_2.i * det.i, q_1.i = q_2.r * det.i + q_2.i * 
	    det.r;
    t22.r = q_1.r, t22.i = q_1.i;
    q_1.r = ndm12.r * det.r - ndm12.i * det.i, q_1.i = ndm12.r * det.i + 
	    ndm12.i * det.r;
    t12.r = q_1.r, t12.i = q_1.i;
    q_1.r = ndm21.r * det.r - ndm21.i * det.i, q_1.i = ndm21.r * det.i + 
	    ndm21.i * det.r;
    t21.r = q_1.r, t21.i = q_1.i;
    q_2.r = t11.r * num11.r - t11.i * num11.i, q_2.i = t11.r * num11.i + 
	    t11.i * num11.r;
    q_3.r = t12.r * num21.r - t12.i * num21.i, q_3.i = t12.r * num21.i + 
	    t12.i * num21.r;
    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
    rfltrn_1.ruppfs.r = q_1.r, rfltrn_1.ruppfs.i = q_1.i;
    q_2.r = t11.r * num12.r - t11.i * num12.i, q_2.i = t11.r * num12.i + 
	    t11.i * num12.r;
    q_3.r = t12.r * num22.r - t12.i * num22.i, q_3.i = t12.r * num22.i + 
	    t12.i * num22.r;
    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
    rfltrn_1.rupsfs.r = q_1.r, rfltrn_1.rupsfs.i = q_1.i;
    q_2.r = t21.r * num11.r - t21.i * num11.i, q_2.i = t21.r * num11.i + 
	    t21.i * num11.r;
    q_3.r = t22.r * num21.r - t22.i * num21.i, q_3.i = t22.r * num21.i + 
	    t22.i * num21.r;
    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
    rfltrn_1.ruspfs.r = q_1.r, rfltrn_1.ruspfs.i = q_1.i;
    q_2.r = t21.r * num12.r - t21.i * num12.i, q_2.i = t21.r * num12.i + 
	    t21.i * num12.r;
    q_3.r = t22.r * num22.r - t22.i * num22.i, q_3.i = t22.r * num22.i + 
	    t22.i * num22.r;
    q_1.r = q_2.r + q_3.r, q_1.i = q_2.i + q_3.i;
    rfltrn_1.russfs.r = q_1.r, rfltrn_1.russfs.i = q_1.i;
    rfltrn_1.rushfs.r = one.r, rfltrn_1.rushfs.i = one.i;
    q_3.r = mdm11.r * rfltrn_1.ruppfs.r - mdm11.i * rfltrn_1.ruppfs.i, q_3.i =
	     mdm11.r * rfltrn_1.ruppfs.i + mdm11.i * rfltrn_1.ruppfs.r;
    q_2.r = mum11.r + q_3.r, q_2.i = mum11.i + q_3.i;
    q_4.r = mdm12.r * rfltrn_1.ruspfs.r - mdm12.i * rfltrn_1.ruspfs.i, q_4.i =
	     mdm12.r * rfltrn_1.ruspfs.i + mdm12.i * rfltrn_1.ruspfs.r;
    q_1.r = q_2.r + q_4.r, q_1.i = q_2.i + q_4.i;
    rfltrn_1.dvpfs.r = q_1.r, rfltrn_1.dvpfs.i = q_1.i;
    q_3.r = mdm21.r * rfltrn_1.ruppfs.r - mdm21.i * rfltrn_1.ruppfs.i, q_3.i =
	     mdm21.r * rfltrn_1.ruppfs.i + mdm21.i * rfltrn_1.ruppfs.r;
    q_2.r = mum21.r + q_3.r, q_2.i = mum21.i + q_3.i;
    q_4.r = mdm22.r * rfltrn_1.ruspfs.r - mdm22.i * rfltrn_1.ruspfs.i, q_4.i =
	     mdm22.r * rfltrn_1.ruspfs.i + mdm22.i * rfltrn_1.ruspfs.r;
    q_1.r = q_2.r + q_4.r, q_1.i = q_2.i + q_4.i;
    rfltrn_1.drpfs.r = q_1.r, rfltrn_1.drpfs.i = q_1.i;
    q_3.r = mdm11.r * rfltrn_1.rupsfs.r - mdm11.i * rfltrn_1.rupsfs.i, q_3.i =
	     mdm11.r * rfltrn_1.rupsfs.i + mdm11.i * rfltrn_1.rupsfs.r;
    q_2.r = mum12.r + q_3.r, q_2.i = mum12.i + q_3.i;
    q_4.r = mdm12.r * rfltrn_1.russfs.r - mdm12.i * rfltrn_1.russfs.i, q_4.i =
	     mdm12.r * rfltrn_1.russfs.i + mdm12.i * rfltrn_1.russfs.r;
    q_1.r = q_2.r + q_4.r, q_1.i = q_2.i + q_4.i;
    rfltrn_1.dvsfs.r = q_1.r, rfltrn_1.dvsfs.i = q_1.i;
    q_3.r = mdm21.r * rfltrn_1.rupsfs.r - mdm21.i * rfltrn_1.rupsfs.i, q_3.i =
	     mdm21.r * rfltrn_1.rupsfs.i + mdm21.i * rfltrn_1.rupsfs.r;
    q_2.r = mum22.r + q_3.r, q_2.i = mum22.i + q_3.i;
    q_4.r = mdm22.r * rfltrn_1.russfs.r - mdm22.i * rfltrn_1.russfs.i, q_4.i =
	     mdm22.r * rfltrn_1.russfs.i + mdm22.i * rfltrn_1.russfs.r;
    q_1.r = q_2.r + q_4.r, q_1.i = q_2.i + q_4.i;
    rfltrn_1.drsfs.r = q_1.r, rfltrn_1.drsfs.i = q_1.i;
    rfltrn_1.dtshfs.r = two.r, rfltrn_1.dtshfs.i = two.i;

/*       now do the interfaces, and save below matrices into above 
matricies*/
/*        before starting next interface */


    i_1 = *nlyrs - 1;
    for (lyr = 1; lyr <= i_1; ++lyr) {

	i_2 = lyr;
	alfap.r = model_1.alfa[i_2].r, alfap.i = model_1.alfa[i_2].i;
	i_2 = lyr;
	betap.r = model_1.beta[i_2].r, betap.i = model_1.beta[i_2].i;
	i_2 = lyr;
	rhop.r = model_1.rho[i_2], rhop.i = (float)0.;
	q_2.r = betap.r * betap.r - betap.i * betap.i, q_2.i = betap.r * 
		betap.i + betap.i * betap.r;
	q_1.r = q_2.r * rhop.r - q_2.i * rhop.i, q_1.i = q_2.r * rhop.i + 
		q_2.i * rhop.r;
	mup.r = q_1.r, mup.i = q_1.i;
	vslow_(&q_1, &alfap, p, f);
	xip.r = q_1.r, xip.i = q_1.i;
	vslow_(&q_1, &betap, p, f);
	etap.r = q_1.r, etap.i = q_1.i;
	i_2 = lyr;
	rfltrn_1.xi[i_2].r = xip.r, rfltrn_1.xi[i_2].i = xip.i;
	i_2 = lyr;
	rfltrn_1.eta[i_2].r = etap.r, rfltrn_1.eta[i_2].i = etap.i;
	q_4.r = two.r * rhop.r - two.i * rhop.i, q_4.i = two.r * rhop.i + 
		two.i * rhop.r;
	q_3.r = q_4.r * xip.r - q_4.i * xip.i, q_3.i = q_4.r * xip.i + q_4.i *
		 xip.r;
	c_sqrt(&q_2, &q_3);
	c_div(&q_1, &one, &q_2);
	epap.r = q_1.r, epap.i = q_1.i;
	q_4.r = two.r * rhop.r - two.i * rhop.i, q_4.i = two.r * rhop.i + 
		two.i * rhop.r;
	q_3.r = q_4.r * etap.r - q_4.i * etap.i, q_3.i = q_4.r * etap.i + 
		q_4.i * etap.r;
	c_sqrt(&q_2, &q_3);
	c_div(&q_1, &one, &q_2);
	epbp.r = q_1.r, epbp.i = q_1.i;
	q_2.r = two.r * mup.r - two.i * mup.i, q_2.i = two.r * mup.i + two.i *
		 mup.r;
	q_1.r = q_2.r * p->r - q_2.i * p->i, q_1.i = q_2.r * p->i + q_2.i * 
		p->r;
	t1.r = q_1.r, t1.i = q_1.i;
	q_2.r = t1.r * p->r - t1.i * p->i, q_2.i = t1.r * p->i + t1.i * p->r;
	q_1.r = q_2.r - rhop.r, q_1.i = q_2.i - rhop.i;
	t2.r = q_1.r, t2.i = q_1.i;

	q_2.r = i.r * xip.r - i.i * xip.i, q_2.i = i.r * xip.i + i.i * xip.r;
	q_1.r = q_2.r * epap.r - q_2.i * epap.i, q_1.i = q_2.r * epap.i + 
		q_2.i * epap.r;
	mdp11.r = q_1.r, mdp11.i = q_1.i;
	q_1.r = -(doublereal)mdp11.r, q_1.i = -(doublereal)mdp11.i;
	mup11.r = q_1.r, mup11.i = q_1.i;
	q_1.r = p->r * epbp.r - p->i * epbp.i, q_1.i = p->r * epbp.i + p->i * 
		epbp.r;
	mdp12.r = q_1.r, mdp12.i = q_1.i;
	mup12.r = mdp12.r, mup12.i = mdp12.i;
	q_1.r = p->r * epap.r - p->i * epap.i, q_1.i = p->r * epap.i + p->i * 
		epap.r;
	mdp21.r = q_1.r, mdp21.i = q_1.i;
	mup21.r = mdp21.r, mup21.i = mdp21.i;
	q_2.r = i.r * etap.r - i.i * etap.i, q_2.i = i.r * etap.i + i.i * 
		etap.r;
	q_1.r = q_2.r * epbp.r - q_2.i * epbp.i, q_1.i = q_2.r * epbp.i + 
		q_2.i * epbp.r;
	mdp22.r = q_1.r, mdp22.i = q_1.i;
	q_1.r = -(doublereal)mdp22.r, q_1.i = -(doublereal)mdp22.i;
	mup22.r = q_1.r, mup22.i = q_1.i;
	q_1.r = t2.r * epap.r - t2.i * epap.i, q_1.i = t2.r * epap.i + t2.i * 
		epap.r;
	ndp11.r = q_1.r, ndp11.i = q_1.i;
	nup11.r = ndp11.r, nup11.i = ndp11.i;
	q_1.r = t1.r * mdp22.r - t1.i * mdp22.i, q_1.i = t1.r * mdp22.i + 
		t1.i * mdp22.r;
	ndp12.r = q_1.r, ndp12.i = q_1.i;
	q_1.r = -(doublereal)ndp12.r, q_1.i = -(doublereal)ndp12.i;
	nup12.r = q_1.r, nup12.i = q_1.i;
	q_1.r = t1.r * mdp11.r - t1.i * mdp11.i, q_1.i = t1.r * mdp11.i + 
		t1.i * mdp11.r;
	ndp21.r = q_1.r, ndp21.i = q_1.i;
	q_1.r = -(doublereal)ndp21.r, q_1.i = -(doublereal)ndp21.i;
	nup21.r = q_1.r, nup21.i = q_1.i;
	q_1.r = t2.r * epbp.r - t2.i * epbp.i, q_1.i = t2.r * epbp.i + t2.i * 
		epbp.r;
	ndp22.r = q_1.r, ndp22.i = q_1.i;
	nup22.r = ndp22.r, nup22.i = ndp22.i;
	q_1.r = mup.r * etap.r - mup.i * etap.i, q_1.i = mup.r * etap.i + 
		mup.i * etap.r;
	zshp.r = q_1.r, zshp.i = q_1.i;

	q_4.r = mum11.r * ndp11.r - mum11.i * ndp11.i, q_4.i = mum11.r * 
		ndp11.i + mum11.i * ndp11.r;
	q_5.r = mum21.r * ndp21.r - mum21.i * ndp21.i, q_5.i = mum21.r * 
		ndp21.i + mum21.i * ndp21.r;
	q_3.r = q_4.r + q_5.r, q_3.i = q_4.i + q_5.i;
	q_6.r = num11.r * mdp11.r - num11.i * mdp11.i, q_6.i = num11.r * 
		mdp11.i + num11.i * mdp11.r;
	q_2.r = q_3.r - q_6.r, q_2.i = q_3.i - q_6.i;
	q_7.r = num21.r * mdp21.r - num21.i * mdp21.i, q_7.i = num21.r * 
		mdp21.i + num21.i * mdp21.r;
	q_1.r = q_2.r - q_7.r, q_1.i = q_2.i - q_7.i;
	t11.r = q_1.r, t11.i = q_1.i;
	q_4.r = mum12.r * ndp11.r - mum12.i * ndp11.i, q_4.i = mum12.r * 
		ndp11.i + mum12.i * ndp11.r;
	q_5.r = mum22.r * ndp21.r - mum22.i * ndp21.i, q_5.i = mum22.r * 
		ndp21.i + mum22.i * ndp21.r;
	q_3.r = q_4.r + q_5.r, q_3.i = q_4.i + q_5.i;
	q_6.r = num12.r * mdp11.r - num12.i * mdp11.i, q_6.i = num12.r * 
		mdp11.i + num12.i * mdp11.r;
	q_2.r = q_3.r - q_6.r, q_2.i = q_3.i - q_6.i;
	q_7.r = num22.r * mdp21.r - num22.i * mdp21.i, q_7.i = num22.r * 
		mdp21.i + num22.i * mdp21.r;
	q_1.r = q_2.r - q_7.r, q_1.i = q_2.i - q_7.i;
	t21.r = q_1.r, t21.i = q_1.i;
	q_4.r = mum11.r * ndp12.r - mum11.i * ndp12.i, q_4.i = mum11.r * 
		ndp12.i + mum11.i * ndp12.r;
	q_5.r = mum21.r * ndp22.r - mum21.i * ndp22.i, q_5.i = mum21.r * 
		ndp22.i + mum21.i * ndp22.r;
	q_3.r = q_4.r + q_5.r, q_3.i = q_4.i + q_5.i;
	q_6.r = num11.r * mdp12.r - num11.i * mdp12.i, q_6.i = num11.r * 
		mdp12.i + num11.i * mdp12.r;
	q_2.r = q_3.r - q_6.r, q_2.i = q_3.i - q_6.i;
	q_7.r = num21.r * mdp22.r - num21.i * mdp22.i, q_7.i = num21.r * 
		mdp22.i + num21.i * mdp22.r;
	q_1.r = q_2.r - q_7.r, q_1.i = q_2.i - q_7.i;
	t12.r = q_1.r, t12.i = q_1.i;
	q_4.r = mum12.r * ndp12.r - mum12.i * ndp12.i, q_4.i = mum12.r * 
		ndp12.i + mum12.i * ndp12.r;
	q_5.r = mum22.r * ndp22.r - mum22.i * ndp22.i, q_5.i = mum22.r * 
		ndp22.i + mum22.i * ndp22.r;
	q_3.r = q_4.r + q_5.r, q_3.i = q_4.i + q_5.i;
	q_6.r = num12.r * mdp12.r - num12.i * mdp12.i, q_6.i = num12.r * 
		mdp12.i + num12.i * mdp12.r;
	q_2.r = q_3.r - q_6.r, q_2.i = q_3.i - q_6.i;
	q_7.r = num22.r * mdp22.r - num22.i * mdp22.i, q_7.i = num22.r * 
		mdp22.i + num22.i * mdp22.r;
	q_1.r = q_2.r - q_7.r, q_1.i = q_2.i - q_7.i;
	t22.r = q_1.r, t22.i = q_1.i;
	q_2.r = t11.r * t22.r - t11.i * t22.i, q_2.i = t11.r * t22.i + t11.i *
		 t22.r;
	q_3.r = t12.r * t21.r - t12.i * t21.i, q_3.i = t12.r * t21.i + t12.i *
		 t21.r;
	q_1.r = q_2.r - q_3.r, q_1.i = q_2.i - q_3.i;
	det.r = q_1.r, det.i = q_1.i;
	c_div(&q_1, &one, &det);
	det.r = q_1.r, det.i = q_1.i;
	q_2.r = -(doublereal)t12.r, q_2.i = -(doublereal)t12.i;
	q_1.r = q_2.r * det.r - q_2.i * det.i, q_1.i = q_2.r * det.i + q_2.i *
		 det.r;
	l12.r = q_1.r, l12.i = q_1.i;
	q_2.r = -(doublereal)t21.r, q_2.i = -(doublereal)t21.i;
	q_1.r = q_2.r * det.r - q_2.i * det.i, q_1.i = q_2.r * det.i + q_2.i *
		 det.r;
	l21.r = q_1.r, l21.i = q_1.i;
	q_1.r = t11.r * det.r - t11.i * det.i, q_1.i = t11.r * det.i + t11.i *
		 det.r;
	l22.r = q_1.r, l22.i = q_1.i;
	q_1.r = t22.r * det.r - t22.i * det.i, q_1.i = t22.r * det.i + t22.i *
		 det.r;
	l11.r = q_1.r, l11.i = q_1.i;


	i_2 = lyr - 1;
	q_1.r = i.r * l11.r - i.i * l11.i, q_1.i = i.r * l11.i + i.i * l11.r;
	rfltrn_1.tdpp[i_2].r = q_1.r, rfltrn_1.tdpp[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_1.r = i.r * l12.r - i.i * l12.i, q_1.i = i.r * l12.i + i.i * l12.r;
	rfltrn_1.tdps[i_2].r = q_1.r, rfltrn_1.tdps[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_1.r = i.r * l21.r - i.i * l21.i, q_1.i = i.r * l21.i + i.i * l21.r;
	rfltrn_1.tdsp[i_2].r = q_1.r, rfltrn_1.tdsp[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_1.r = i.r * l22.r - i.i * l22.i, q_1.i = i.r * l22.i + i.i * l22.r;
	rfltrn_1.tdss[i_2].r = q_1.r, rfltrn_1.tdss[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_1.r = i.r * l11.r - i.i * l11.i, q_1.i = i.r * l11.i + i.i * l11.r;
	rfltrn_1.tupp[i_2].r = q_1.r, rfltrn_1.tupp[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_1.r = i.r * l21.r - i.i * l21.i, q_1.i = i.r * l21.i + i.i * l21.r;
	rfltrn_1.tups[i_2].r = q_1.r, rfltrn_1.tups[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_1.r = i.r * l12.r - i.i * l12.i, q_1.i = i.r * l12.i + i.i * l12.r;
	rfltrn_1.tusp[i_2].r = q_1.r, rfltrn_1.tusp[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_1.r = i.r * l22.r - i.i * l22.i, q_1.i = i.r * l22.i + i.i * l22.r;
	rfltrn_1.tuss[i_2].r = q_1.r, rfltrn_1.tuss[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_4.r = zshp.r * zshm.r - zshp.i * zshm.i, q_4.i = zshp.r * zshm.i + 
		zshp.i * zshm.r;
	c_sqrt(&q_3, &q_4);
	q_2.r = two.r * q_3.r - two.i * q_3.i, q_2.i = two.r * q_3.i + two.i *
		 q_3.r;
	q_5.r = zshp.r + zshm.r, q_5.i = zshp.i + zshm.i;
	c_div(&q_1, &q_2, &q_5);
	rfltrn_1.tush[i_2].r = q_1.r, rfltrn_1.tush[i_2].i = q_1.i;
	i_2 = lyr - 1;
	i_3 = lyr - 1;
	rfltrn_1.tdsh[i_2].r = rfltrn_1.tush[i_3].r, rfltrn_1.tdsh[i_2].i = 
		rfltrn_1.tush[i_3].i;

	q_4.r = mdm11.r * ndp11.r - mdm11.i * ndp11.i, q_4.i = mdm11.r * 
		ndp11.i + mdm11.i * ndp11.r;
	q_5.r = mdm21.r * ndp21.r - mdm21.i * ndp21.i, q_5.i = mdm21.r * 
		ndp21.i + mdm21.i * ndp21.r;
	q_3.r = q_4.r + q_5.r, q_3.i = q_4.i + q_5.i;
	q_6.r = ndm11.r * mdp11.r - ndm11.i * mdp11.i, q_6.i = ndm11.r * 
		mdp11.i + ndm11.i * mdp11.r;
	q_2.r = q_3.r - q_6.r, q_2.i = q_3.i - q_6.i;
	q_7.r = ndm21.r * mdp21.r - ndm21.i * mdp21.i, q_7.i = ndm21.r * 
		mdp21.i + ndm21.i * mdp21.r;
	q_1.r = q_2.r - q_7.r, q_1.i = q_2.i - q_7.i;
	t11.r = q_1.r, t11.i = q_1.i;
	q_4.r = mdm12.r * ndp11.r - mdm12.i * ndp11.i, q_4.i = mdm12.r * 
		ndp11.i + mdm12.i * ndp11.r;
	q_5.r = mdm22.r * ndp21.r - mdm22.i * ndp21.i, q_5.i = mdm22.r * 
		ndp21.i + mdm22.i * ndp21.r;
	q_3.r = q_4.r + q_5.r, q_3.i = q_4.i + q_5.i;
	q_6.r = ndm12.r * mdp11.r - ndm12.i * mdp11.i, q_6.i = ndm12.r * 
		mdp11.i + ndm12.i * mdp11.r;
	q_2.r = q_3.r - q_6.r, q_2.i = q_3.i - q_6.i;
	q_7.r = ndm22.r * mdp21.r - ndm22.i * mdp21.i, q_7.i = ndm22.r * 
		mdp21.i + ndm22.i * mdp21.r;
	q_1.r = q_2.r - q_7.r, q_1.i = q_2.i - q_7.i;
	t21.r = q_1.r, t21.i = q_1.i;
	q_4.r = mdm11.r * ndp12.r - mdm11.i * ndp12.i, q_4.i = mdm11.r * 
		ndp12.i + mdm11.i * ndp12.r;
	q_5.r = mdm21.r * ndp22.r - mdm21.i * ndp22.i, q_5.i = mdm21.r * 
		ndp22.i + mdm21.i * ndp22.r;
	q_3.r = q_4.r + q_5.r, q_3.i = q_4.i + q_5.i;
	q_6.r = ndm11.r * mdp12.r - ndm11.i * mdp12.i, q_6.i = ndm11.r * 
		mdp12.i + ndm11.i * mdp12.r;
	q_2.r = q_3.r - q_6.r, q_2.i = q_3.i - q_6.i;
	q_7.r = ndm21.r * mdp22.r - ndm21.i * mdp22.i, q_7.i = ndm21.r * 
		mdp22.i + ndm21.i * mdp22.r;
	q_1.r = q_2.r - q_7.r, q_1.i = q_2.i - q_7.i;
	t12.r = q_1.r, t12.i = q_1.i;
	q_4.r = mdm12.r * ndp12.r - mdm12.i * ndp12.i, q_4.i = mdm12.r * 
		ndp12.i + mdm12.i * ndp12.r;
	q_5.r = mdm22.r * ndp22.r - mdm22.i * ndp22.i, q_5.i = mdm22.r * 
		ndp22.i + mdm22.i * ndp22.r;
	q_3.r = q_4.r + q_5.r, q_3.i = q_4.i + q_5.i;
	q_6.r = ndm12.r * mdp12.r - ndm12.i * mdp12.i, q_6.i = ndm12.r * 
		mdp12.i + ndm12.i * mdp12.r;
	q_2.r = q_3.r - q_6.r, q_2.i = q_3.i - q_6.i;
	q_7.r = ndm22.r * mdp22.r - ndm22.i * mdp22.i, q_7.i = ndm22.r * 
		mdp22.i + ndm22.i * mdp22.r;
	q_1.r = q_2.r - q_7.r, q_1.i = q_2.i - q_7.i;
	t22.r = q_1.r, t22.i = q_1.i;
	i_2 = lyr - 1;
	q_3.r = -(doublereal)t11.r, q_3.i = -(doublereal)t11.i;
	q_2.r = q_3.r * l11.r - q_3.i * l11.i, q_2.i = q_3.r * l11.i + q_3.i *
		 l11.r;
	q_4.r = t12.r * l21.r - t12.i * l21.i, q_4.i = t12.r * l21.i + t12.i *
		 l21.r;
	q_1.r = q_2.r - q_4.r, q_1.i = q_2.i - q_4.i;
	rfltrn_1.rdpp[i_2].r = q_1.r, rfltrn_1.rdpp[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_3.r = -(doublereal)t11.r, q_3.i = -(doublereal)t11.i;
	q_2.r = q_3.r * l12.r - q_3.i * l12.i, q_2.i = q_3.r * l12.i + q_3.i *
		 l12.r;
	q_4.r = t12.r * l22.r - t12.i * l22.i, q_4.i = t12.r * l22.i + t12.i *
		 l22.r;
	q_1.r = q_2.r - q_4.r, q_1.i = q_2.i - q_4.i;
	rfltrn_1.rdps[i_2].r = q_1.r, rfltrn_1.rdps[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_3.r = -(doublereal)t21.r, q_3.i = -(doublereal)t21.i;
	q_2.r = q_3.r * l11.r - q_3.i * l11.i, q_2.i = q_3.r * l11.i + q_3.i *
		 l11.r;
	q_4.r = t22.r * l21.r - t22.i * l21.i, q_4.i = t22.r * l21.i + t22.i *
		 l21.r;
	q_1.r = q_2.r - q_4.r, q_1.i = q_2.i - q_4.i;
	rfltrn_1.rdsp[i_2].r = q_1.r, rfltrn_1.rdsp[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_3.r = -(doublereal)t21.r, q_3.i = -(doublereal)t21.i;
	q_2.r = q_3.r * l12.r - q_3.i * l12.i, q_2.i = q_3.r * l12.i + q_3.i *
		 l12.r;
	q_4.r = t22.r * l22.r - t22.i * l22.i, q_4.i = t22.r * l22.i + t22.i *
		 l22.r;
	q_1.r = q_2.r - q_4.r, q_1.i = q_2.i - q_4.i;
	rfltrn_1.rdss[i_2].r = q_1.r, rfltrn_1.rdss[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_2.r = zshm.r - zshp.r, q_2.i = zshm.i - zshp.i;
	q_3.r = zshm.r + zshp.r, q_3.i = zshm.i + zshp.i;
	c_div(&q_1, &q_2, &q_3);
	rfltrn_1.rdsh[i_2].r = q_1.r, rfltrn_1.rdsh[i_2].i = q_1.i;

	q_4.r = mum11.r * nup11.r - mum11.i * nup11.i, q_4.i = mum11.r * 
		nup11.i + mum11.i * nup11.r;
	q_5.r = mum21.r * nup21.r - mum21.i * nup21.i, q_5.i = mum21.r * 
		nup21.i + mum21.i * nup21.r;
	q_3.r = q_4.r + q_5.r, q_3.i = q_4.i + q_5.i;
	q_6.r = num11.r * mup11.r - num11.i * mup11.i, q_6.i = num11.r * 
		mup11.i + num11.i * mup11.r;
	q_2.r = q_3.r - q_6.r, q_2.i = q_3.i - q_6.i;
	q_7.r = num21.r * mup21.r - num21.i * mup21.i, q_7.i = num21.r * 
		mup21.i + num21.i * mup21.r;
	q_1.r = q_2.r - q_7.r, q_1.i = q_2.i - q_7.i;
	t11.r = q_1.r, t11.i = q_1.i;
	q_4.r = mum12.r * nup11.r - mum12.i * nup11.i, q_4.i = mum12.r * 
		nup11.i + mum12.i * nup11.r;
	q_5.r = mum22.r * nup21.r - mum22.i * nup21.i, q_5.i = mum22.r * 
		nup21.i + mum22.i * nup21.r;
	q_3.r = q_4.r + q_5.r, q_3.i = q_4.i + q_5.i;
	q_6.r = num12.r * mup11.r - num12.i * mup11.i, q_6.i = num12.r * 
		mup11.i + num12.i * mup11.r;
	q_2.r = q_3.r - q_6.r, q_2.i = q_3.i - q_6.i;
	q_7.r = num22.r * mup21.r - num22.i * mup21.i, q_7.i = num22.r * 
		mup21.i + num22.i * mup21.r;
	q_1.r = q_2.r - q_7.r, q_1.i = q_2.i - q_7.i;
	t21.r = q_1.r, t21.i = q_1.i;
	q_4.r = mum11.r * nup12.r - mum11.i * nup12.i, q_4.i = mum11.r * 
		nup12.i + mum11.i * nup12.r;
	q_5.r = mum21.r * nup22.r - mum21.i * nup22.i, q_5.i = mum21.r * 
		nup22.i + mum21.i * nup22.r;
	q_3.r = q_4.r + q_5.r, q_3.i = q_4.i + q_5.i;
	q_6.r = num11.r * mup12.r - num11.i * mup12.i, q_6.i = num11.r * 
		mup12.i + num11.i * mup12.r;
	q_2.r = q_3.r - q_6.r, q_2.i = q_3.i - q_6.i;
	q_7.r = num21.r * mup22.r - num21.i * mup22.i, q_7.i = num21.r * 
		mup22.i + num21.i * mup22.r;
	q_1.r = q_2.r - q_7.r, q_1.i = q_2.i - q_7.i;
	t12.r = q_1.r, t12.i = q_1.i;
	q_4.r = mum12.r * nup12.r - mum12.i * nup12.i, q_4.i = mum12.r * 
		nup12.i + mum12.i * nup12.r;
	q_5.r = mum22.r * nup22.r - mum22.i * nup22.i, q_5.i = mum22.r * 
		nup22.i + mum22.i * nup22.r;
	q_3.r = q_4.r + q_5.r, q_3.i = q_4.i + q_5.i;
	q_6.r = num12.r * mup12.r - num12.i * mup12.i, q_6.i = num12.r * 
		mup12.i + num12.i * mup12.r;
	q_2.r = q_3.r - q_6.r, q_2.i = q_3.i - q_6.i;
	q_7.r = num22.r * mup22.r - num22.i * mup22.i, q_7.i = num22.r * 
		mup22.i + num22.i * mup22.r;
	q_1.r = q_2.r - q_7.r, q_1.i = q_2.i - q_7.i;
	t22.r = q_1.r, t22.i = q_1.i;
	i_2 = lyr - 1;
	q_3.r = -(doublereal)l11.r, q_3.i = -(doublereal)l11.i;
	q_2.r = q_3.r * t11.r - q_3.i * t11.i, q_2.i = q_3.r * t11.i + q_3.i *
		 t11.r;
	q_4.r = l12.r * t21.r - l12.i * t21.i, q_4.i = l12.r * t21.i + l12.i *
		 t21.r;
	q_1.r = q_2.r - q_4.r, q_1.i = q_2.i - q_4.i;
	rfltrn_1.rupp[i_2].r = q_1.r, rfltrn_1.rupp[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_3.r = -(doublereal)l11.r, q_3.i = -(doublereal)l11.i;
	q_2.r = q_3.r * t12.r - q_3.i * t12.i, q_2.i = q_3.r * t12.i + q_3.i *
		 t12.r;
	q_4.r = l12.r * t22.r - l12.i * t22.i, q_4.i = l12.r * t22.i + l12.i *
		 t22.r;
	q_1.r = q_2.r - q_4.r, q_1.i = q_2.i - q_4.i;
	rfltrn_1.rups[i_2].r = q_1.r, rfltrn_1.rups[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_3.r = -(doublereal)l21.r, q_3.i = -(doublereal)l21.i;
	q_2.r = q_3.r * t11.r - q_3.i * t11.i, q_2.i = q_3.r * t11.i + q_3.i *
		 t11.r;
	q_4.r = l22.r * t21.r - l22.i * t21.i, q_4.i = l22.r * t21.i + l22.i *
		 t21.r;
	q_1.r = q_2.r - q_4.r, q_1.i = q_2.i - q_4.i;
	rfltrn_1.rusp[i_2].r = q_1.r, rfltrn_1.rusp[i_2].i = q_1.i;
	i_2 = lyr - 1;
	q_3.r = -(doublereal)l21.r, q_3.i = -(doublereal)l21.i;
	q_2.r = q_3.r * t12.r - q_3.i * t12.i, q_2.i = q_3.r * t12.i + q_3.i *
		 t12.r;
	q_4.r = l22.r * t22.r - l22.i * t22.i, q_4.i = l22.r * t22.i + l22.i *
		 t22.r;
	q_1.r = q_2.r - q_4.r, q_1.i = q_2.i - q_4.i;
	rfltrn_1.russ[i_2].r = q_1.r, rfltrn_1.russ[i_2].i = q_1.i;
	i_2 = lyr - 1;
	i_3 = lyr - 1;
	q_1.r = -(doublereal)rfltrn_1.rdsh[i_3].r, q_1.i = -(doublereal)
		rfltrn_1.rdsh[i_3].i;
	rfltrn_1.rush[i_2].r = q_1.r, rfltrn_1.rush[i_2].i = q_1.i;

/* 	 copy the above values to storage for  inversion */
/*        copy the below values to above values for next interface */

	i_2 = lyr - 1;
	invsav1_1.mu[i_2].r = mum.r, invsav1_1.mu[i_2].i = mum.i;
	i_2 = lyr - 1;
	invsav1_1.epa[i_2].r = epam.r, invsav1_1.epa[i_2].i = epam.i;
	i_2 = lyr - 1;
	invsav1_1.epb[i_2].r = epbm.r, invsav1_1.epb[i_2].i = epbm.i;
	i_2 = lyr - 1;
	invsav1_1.nu11[i_2].r = num11.r, invsav1_1.nu11[i_2].i = num11.i;
	i_2 = lyr - 1;
	invsav1_1.nu12[i_2].r = num12.r, invsav1_1.nu12[i_2].i = num12.i;
	i_2 = lyr - 1;
	invsav1_1.nu21[i_2].r = num21.r, invsav1_1.nu21[i_2].i = num21.i;
	i_2 = lyr - 1;
	invsav1_1.nu22[i_2].r = num22.r, invsav1_1.nu22[i_2].i = num22.i;
	i_2 = lyr - 1;
	invsav1_1.nd11[i_2].r = ndm11.r, invsav1_1.nd11[i_2].i = ndm11.i;
	i_2 = lyr - 1;
	invsav1_1.nd12[i_2].r = ndm12.r, invsav1_1.nd12[i_2].i = ndm12.i;
	i_2 = lyr - 1;
	invsav1_1.nd21[i_2].r = ndm21.r, invsav1_1.nd21[i_2].i = ndm21.i;
	i_2 = lyr - 1;
	invsav1_1.nd22[i_2].r = ndm22.r, invsav1_1.nd22[i_2].i = ndm22.i;
	i_2 = lyr - 1;
	invsav1_1.mu11[i_2].r = mum11.r, invsav1_1.mu11[i_2].i = mum11.i;
	i_2 = lyr - 1;
	invsav1_1.mu12[i_2].r = mum12.r, invsav1_1.mu12[i_2].i = mum12.i;
	i_2 = lyr - 1;
	invsav1_1.mu21[i_2].r = mum21.r, invsav1_1.mu21[i_2].i = mum21.i;
	i_2 = lyr - 1;
	invsav1_1.mu22[i_2].r = mum22.r, invsav1_1.mu22[i_2].i = mum22.i;
	i_2 = lyr - 1;
	invsav1_1.md11[i_2].r = mdm11.r, invsav1_1.md11[i_2].i = mdm11.i;
	i_2 = lyr - 1;
	invsav1_1.md12[i_2].r = mdm12.r, invsav1_1.md12[i_2].i = mdm12.i;
	i_2 = lyr - 1;
	invsav1_1.md21[i_2].r = mdm21.r, invsav1_1.md21[i_2].i = mdm21.i;
	i_2 = lyr - 1;
	invsav1_1.md22[i_2].r = mdm22.r, invsav1_1.md22[i_2].i = mdm22.i;
	i_2 = lyr - 1;
	invsav1_1.zsh[i_2].r = zshm.r, invsav1_1.zsh[i_2].i = zshm.i;
	alfam.r = alfap.r, alfam.i = alfap.i;
	betam.r = betap.r, betam.i = betap.i;
	rhom.r = rhop.r, rhom.i = rhop.i;
	mum.r = mup.r, mum.i = mup.i;
	xim.r = xip.r, xim.i = xip.i;
	etam.r = etap.r, etam.i = etap.i;
	epam.r = epap.r, epam.i = epap.i;
	epbm.r = epbp.r, epbm.i = epbp.i;
	num11.r = nup11.r, num11.i = nup11.i;
	num12.r = nup12.r, num12.i = nup12.i;
	num21.r = nup21.r, num21.i = nup21.i;
	num22.r = nup22.r, num22.i = nup22.i;
	ndm11.r = ndp11.r, ndm11.i = ndp11.i;
	ndm12.r = ndp12.r, ndm12.i = ndp12.i;
	ndm21.r = ndp21.r, ndm21.i = ndp21.i;
	ndm22.r = ndp22.r, ndm22.i = ndp22.i;
	mum11.r = mup11.r, mum11.i = mup11.i;
	mum12.r = mup12.r, mum12.i = mup12.i;
	mum21.r = mup21.r, mum21.i = mup21.i;
	mum22.r = mup22.r, mum22.i = mup22.i;
	mdm11.r = mdp11.r, mdm11.i = mdp11.i;
	mdm12.r = mdp12.r, mdm12.i = mdp12.i;
	mdm21.r = mdp21.r, mdm21.i = mdp21.i;
	mdm22.r = mdp22.r, mdm22.i = mdp22.i;
	zshm.r = zshp.r, zshm.i = zshp.i;

/*     copy the n and m matrices if this is source layer */

	if (lyr == srctrm_1.srclyr) {
	    srctrm_1.nus11.r = num11.r, srctrm_1.nus11.i = num11.i;
	    srctrm_1.nus12.r = num12.r, srctrm_1.nus12.i = num12.i;
	    srctrm_1.nus21.r = num21.r, srctrm_1.nus21.i = num21.i;
	    srctrm_1.nus22.r = num22.r, srctrm_1.nus22.i = num22.i;
	    q_5.r = -(doublereal)i.r, q_5.i = -(doublereal)i.i;
	    q_4.r = q_5.r * rhom.r - q_5.i * rhom.i, q_4.i = q_5.r * rhom.i + 
		    q_5.i * rhom.r;
	    q_3.r = q_4.r * betam.r - q_4.i * betam.i, q_3.i = q_4.r * 
		    betam.i + q_4.i * betam.r;
	    q_2.r = q_3.r * etam.r - q_3.i * etam.i, q_2.i = q_3.r * etam.i + 
		    q_3.i * etam.r;
	    q_1.r = q_2.r * epbm.r - q_2.i * epbm.i, q_1.i = q_2.r * epbm.i + 
		    q_2.i * epbm.r;
	    srctrm_1.nussh.r = q_1.r, srctrm_1.nussh.i = q_1.i;
	    srctrm_1.nds11.r = ndm11.r, srctrm_1.nds11.i = ndm11.i;
	    srctrm_1.nds12.r = ndm12.r, srctrm_1.nds12.i = ndm12.i;
	    srctrm_1.nds21.r = ndm21.r, srctrm_1.nds21.i = ndm21.i;
	    srctrm_1.nds22.r = ndm22.r, srctrm_1.nds22.i = ndm22.i;
	    q_1.r = -(doublereal)srctrm_1.nussh.r, q_1.i = -(doublereal)
		    srctrm_1.nussh.i;
	    srctrm_1.ndssh.r = q_1.r, srctrm_1.ndssh.i = q_1.i;
	    srctrm_1.mus11.r = mum11.r, srctrm_1.mus11.i = mum11.i;
	    srctrm_1.mus12.r = mum12.r, srctrm_1.mus12.i = mum12.i;
	    srctrm_1.mus21.r = mum21.r, srctrm_1.mus21.i = mum21.i;
	    srctrm_1.mus22.r = mum22.r, srctrm_1.mus22.i = mum22.i;
	    c_div(&q_1, &epbm, &betam);
	    srctrm_1.mussh.r = q_1.r, srctrm_1.mussh.i = q_1.i;
	    srctrm_1.mds11.r = mdm11.r, srctrm_1.mds11.i = mdm11.i;
	    srctrm_1.mds12.r = mdm12.r, srctrm_1.mds12.i = mdm12.i;
	    srctrm_1.mds21.r = mdm21.r, srctrm_1.mds21.i = mdm21.i;
	    srctrm_1.mds22.r = mdm22.r, srctrm_1.mds22.i = mdm22.i;
	    srctrm_1.mdssh.r = srctrm_1.mussh.r, srctrm_1.mdssh.i = 
		    srctrm_1.mussh.i;
	    srctrm_1.rhos = rhom.r;
	    srctrm_1.alfas.r = alfam.r, srctrm_1.alfas.i = alfam.i;
	    srctrm_1.betas.r = betam.r, srctrm_1.betas.i = betam.i;
	}
/* L10: */
    }

/* 	copy the layer matrices for halfspace to inversion storage */

    i_1 = *nlyrs - 1;
    invsav1_1.mu[i_1].r = mup.r, invsav1_1.mu[i_1].i = mup.i;
    i_1 = *nlyrs - 1;
    invsav1_1.epa[i_1].r = epam.r, invsav1_1.epa[i_1].i = epam.i;
    i_1 = *nlyrs - 1;
    invsav1_1.epb[i_1].r = epbm.r, invsav1_1.epb[i_1].i = epbm.i;
    i_1 = *nlyrs - 1;
    invsav1_1.nu11[i_1].r = nup11.r, invsav1_1.nu11[i_1].i = nup11.i;
    i_1 = *nlyrs - 1;
    invsav1_1.nu12[i_1].r = nup12.r, invsav1_1.nu12[i_1].i = nup12.i;
    i_1 = *nlyrs - 1;
    invsav1_1.nu21[i_1].r = nup21.r, invsav1_1.nu21[i_1].i = nup21.i;
    i_1 = *nlyrs - 1;
    invsav1_1.nu22[i_1].r = nup22.r, invsav1_1.nu22[i_1].i = nup22.i;
    i_1 = *nlyrs - 1;
    invsav1_1.nd11[i_1].r = ndp11.r, invsav1_1.nd11[i_1].i = ndp11.i;
    i_1 = *nlyrs - 1;
    invsav1_1.nd12[i_1].r = ndp12.r, invsav1_1.nd12[i_1].i = ndp12.i;
    i_1 = *nlyrs - 1;
    invsav1_1.nd21[i_1].r = ndp21.r, invsav1_1.nd21[i_1].i = ndp21.i;
    i_1 = *nlyrs - 1;
    invsav1_1.nd22[i_1].r = ndp22.r, invsav1_1.nd22[i_1].i = ndp22.i;
    i_1 = *nlyrs - 1;
    invsav1_1.mu11[i_1].r = mup11.r, invsav1_1.mu11[i_1].i = mup11.i;
    i_1 = *nlyrs - 1;
    invsav1_1.mu12[i_1].r = mup12.r, invsav1_1.mu12[i_1].i = mup12.i;
    i_1 = *nlyrs - 1;
    invsav1_1.mu21[i_1].r = mup21.r, invsav1_1.mu21[i_1].i = mup21.i;
    i_1 = *nlyrs - 1;
    invsav1_1.mu22[i_1].r = mup22.r, invsav1_1.mu22[i_1].i = mup22.i;
    i_1 = *nlyrs - 1;
    invsav1_1.md11[i_1].r = mdp11.r, invsav1_1.md11[i_1].i = mdp11.i;
    i_1 = *nlyrs - 1;
    invsav1_1.md12[i_1].r = mdp12.r, invsav1_1.md12[i_1].i = mdp12.i;
    i_1 = *nlyrs - 1;
    invsav1_1.md21[i_1].r = mdp21.r, invsav1_1.md21[i_1].i = mdp21.i;
    i_1 = *nlyrs - 1;
    invsav1_1.md22[i_1].r = mdp22.r, invsav1_1.md22[i_1].i = mdp22.i;
    i_1 = *nlyrs - 1;
    invsav1_1.zsh[i_1].r = zshp.r, invsav1_1.zsh[i_1].i = zshp.i;


    return 0;
} /* ifmat_ */

doublereal qabm_(w, t1, t2, qm)
doublereal *w, *t1, *t2, *qm;
{
    /* System generated locals */
    doublereal ret_val;

    /* Builtin functions */
    double atan();

    /* Local variables */
    static doublereal c, arg;

    arg = *w * (*t1 - *t2) / (*w * *w * *t1 * *t2 + (float)1.);
/*     c=2/(pi*qm) */
    c = (float).6366198 / *qm;
    ret_val = c * atan(arg);
    if (ret_val == 0.) {
	ret_val = 1e-5;
    }
    ret_val = (float)1. / ret_val;
    return ret_val;
} /* qabm_ */

doublereal vabm_(w, t1, t2, qm)
doublereal *w, *t1, *t2, *qm;
{
    /* System generated locals */
    doublereal ret_val;

    /* Builtin functions */
    double log();

    /* Local variables */
    static doublereal c, w2, t12, t22, w12, arg, arg1;

/*     vabm calculates dispersion due to anelasticity */
/*     c=2/(pi*qm) */
    c = (float).6366198 / *qm;
    c /= (float)4.;
    w2 = *w * *w;
    t12 = *t1 * *t1;
    t22 = *t2 * *t2;
    arg = (w2 * t12 + (float)1.) / (w2 * t22 + (float)1.);
/*     normalize to 1 hz (w12 = (2*pi*1)**2 */
    w12 = (float)39.478418;
    arg1 = (w12 * t12 + (float)1.) / (w12 * t22 + (float)1.);
    ret_val = (c * log(arg) + (float)1.) / (c * log(arg1) + (float)1.);
    return ret_val;
} /* vabm_ */

