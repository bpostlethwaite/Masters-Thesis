.f.o: ; gfortran $(FFLAGS) -c $*.f
WOBJS = cmg3_30_vel.o cmg3_360_vel.o corins.o day.o detren.o edit.o evres.o fft.o filter.o folder.o ftan.o gs13_vel.o idasta.o insinf.o intpol_log.o lac_ale2_acc.o lac_erm3_acc.o lac_esk3_acc.o lac_nna9_acc.o lac_pfo5_acc.o lac_rpn1_acc.o m3_1_coef_1.o m3_1_coef_2.o m3_1_coef_3.o m3_2_coef_1.o m3_2_coef_2.o m3_2_coef_3.o m3_3_coef_1.o m3_3_coef_2.o m3_3_coef_3.o m3_4_coef_1.o m3_4_coef_2.o m3_4_coef_3.o m3_4_coef_4.o m5_coef_1.o m5_coef_2.o m5_coef_3.o m5_coef_4.o m5_coef_5.o m5_coef_6.o m6_1_coef_1.o m6_1_coef_2.o m6_1_coef_3.o m6_1_coef_4.o m6_1_coef_5.o m6_1_coef_6.o main000.o norm.o nul.o option.o ortime.o parabs.o parb.o pha.o pzfill.o respo.o sacread.o search.o setter.o skipper.o spectrum.o spline.o sts1_10_vel.o sts1_5a_vel.o sts1_5b_vel.o sts1_mp_acc.o sts1_vel.o  window.o svanoutl.o bspline.o velnew2.o
SBIN = /Users/bostock/Bin
LIB = -L/geophys/lib/ -lsac
j2g:	j2g.o
	gfortran $(FFLAGS) day.o j2g.o -o ./j2g

g2j:	g2j.o day.o
	gfortran $(FFLAGS) g2j.o -o ./g2j

clean:
	rm -f *.o
