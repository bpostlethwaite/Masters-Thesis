#! /bin/sh
# Shell script to build SAC macro to make a slowness section plot with
# travel times computed for specified Earth model.  Parameters:
#   1 - Name of travel time tables
#   2 - low slowness range (sec/degrees)
#   3 - high slowness range (sec/degrees)
#   4 - start time for plot (seconds relative to file zero)
#   5 - end time for plot (seconds relative to file zero)
#   6 - discontinuity depth moveout curves desired, e.g. P410s
#   7 - static time shift
#   8 - name of file with "addstack" commands to build up record section
#   9 - binning or picture parameters.
#       if slowness-averaging wanted "bin x fn" where x is
#          binning width and fn is the binned file name prefixes; 
#       if picture wanted, "picture x type n fn ..." where x is the slant stack
#          slowness increment, type is 'nthroot' or 'phaseweight' n is the
#          root index, fn is the output file name, and ... are the -slow
#          arguments.
#       if record section wanted, "sect ph xxx unit" or "sect hdr xxx unit" for
#          slowness information and unit.
#  10 - picture magnification parameters.
#  11 - "port" or "land" for orientation of display.

ttfile=/tmp/ttimes.$$ ofile="$8" tmp=/tmp/temp$$

if tty -s ; then
   tty=/dev/tty
else
   tty=/dev/null
fi
#echo "$*" > $tty
tables=`[ "$1" != "default" ] && echo -model $1`
phases="$6" pic=no

#(echo $0 debug:; head $ttfile) > /dev/tty
if expr "$9" : 'bin' > /dev/null ; then
   awk '/^[^#*]/{print $1}' | Pstimes -info ${tables} > $ttfile
   awk 'func abs(x){
      if (x<0) return -x ; else return x
      }
      BEGIN{
         n=split("'"$9"'",f); wid=f[2]; fpfx=f[3]; beg='$2'; end='$3'
      }
      {nf+=1; slow[nf]=$3; file[nf]=$1}
      END{nbin=0; 
         for(s=beg+wid/2; s<=end-wid/2; s+=wid) {
	    n=0; for(i=1;i<=nf;i++) {
	       cmd=sprintf("sacstack -xlim '"${4}"' '"${5}"' %s.%03d",fpfx,nbin)
	       if (abs(slow[i]-s) <=wid/2) {n+=1
#		  printf "%s in bin for %f\n",file[i],s > "/dev/tty"
		  print file[i],"0.0 1.0" | cmd
	       }
	    }
	    if (n>0) {
	       close(cmd)
	       printf "addstack %s.%03d delay %f distance %f\n",fpfx,nbin,'"${7}"',s*111.19493
	       printf "sc /bin/rm -f %s.%03d\n",fpfx,nbin
	       nbin+=1
	    }
	 }
      }' $ttfile > $ofile
elif expr "$9" : 'picture' > /dev/null ; then
   pic=yes
   awk '/^[^#*]/{print $0}' > $ttfile
   echo $9 | while read pic dslow type n f args ; do
      sacslantstack -picture sac -envelope -xlim $4 $5 -norm -slow $args \
         -model $1 -slant $2 $3 $dslow -$type $n $f < $ttfile > $tmp
      [ -z "${10}" ] || echo $f | sacxymag ${10} > $tmp.mag
   done
elif expr "$9" : 'sect' > /dev/null ; then
   awk '/^[^#*]/{print $1}' > $ttfile
   echo $9 | while read sec type var unit ; do
      case $unit in
         s/deg) un=1; rem=111.19493 ;;
         s/km) un=1 ;;
	 *) un=111.19493 ;;
      esac
      case $type in
      ph*)
         cat $ttfile | Pstimes -info ${tables} |
         awk '{printf "addstack %s delay 0.0 distance %f\n",$1,$3}' > $ofile
	 ;;
      hd*)
         cat $ttfile | sachdrinfo -s -input $var |
         awk '{printf "addstack %s delay 0.0 distance %f\n",$1,$2*'"${un}"'}' > $ofile
	 ;;
      *) echo "**Bad arguments to $0 ($sec $type $var)" > /dev/tty
         ;;
      esac
   done
else
   awk '/^[^#*]/{print $1}' | Pstimes -info ${tables} |
   awk '{printf "addstack %s delay 0.0 distance %f\n",$1,$3/111.19493}' > $ofile
fi
> $ttfile

# Check if any of the exotic discontinuity interaction phases are selected
pipe=""
for phase in $phases ; do
#  echo "Matching $phase" > /dev/tty
   if expr "$phase" : '[psS][KS]*[0-9][0-9]*[PSps]' > /dev/null ; then
      base_phase=`echo $phase | sed -e 's/\([^0-9]*\)[0-9]*\([^0-9]\)/\1\2/'`
      disc_depth=`expr match "$phase" '[^0-9]*\([0-9]*\)[^0-9]*'`
      pipe="$pipe | sh /usr/local/lib/geophy/SAC/macros/run-dsd.sh $base_phase $depth $disc_depth"
   fi
   if [ -f /home/george/seismo/tt.$phase ] ; then
      pipe="$pipe | sh /usr/local/lib/geophy/SAC/macros/run-dtt.sh $phase $depth"
   fi
done
# echo "$pipe" > /dev/tty

# Give maximum and minimum distances, and  compute travel times for all phases
# for 20 intermediate distances.
#                   
echo '[f3stvbhl]'
echo 't 0.15 0.08'
echo "$1 tables"
echo '[l4]'
if [ $pic = yes ]; then
#  This section for annotation of a XYZ picture of the slowness slant stack
   sref=`awk '/Array ref. slowness/{print $(NF)}' $tmp`
   if [ ! -z "${sref}" ]; then
      for ph in $phases ; do
	 echo $ph | awk 'BEGIN{s='"${sref}"'; ds=0.25}
	    /[PS][0-9]*[ps]/{len=length($1)
	       print substr($1,1,1) substr($1,len),s-ds,substr($1,2,len-2)
	       print substr($1,1,1) substr($1,len),s,substr($1,2,len-2)
	       print substr($1,1,1) substr($1,len),s+ds,substr($1,2,len-2)
	    }' | Pstimes -model $1 -nohead |
	 awk '\
	   NR==1{slo=$2; tlo=$4}
	   NR==2{ph=substr($1,1,1) sprintf("%d",0+$3) substr($1,2); t0=$4}
	   NR==3{shi=$2; thi=$4}
	   END{if (NR<3) exit
	      mo=(thi-tlo)/(shi-slo)
	      printf "Annotation %s %.3f %.3f\n",ph,t0,mo
	      #print ph," moveout, t:",mo,t0 >> "/dev/tty"
	   }' >> $tmp
      done
      [ -f $tmp.mag ] && cat $tmp.mag >> $tmp
   fi
   echo $2 $3 $4 $5 | cat - $tmp | 
   awk 'BEGIN {
      mach_xmin = 0.10; mach_xmax = 0.90
      mach_ymin = 0.15; mach_ymax = 0.90
   }
   function mach_x(x) {
      return mach_xmin + mach_xc * (x-sec_beg)
   }
   function mach_y(y) {
      return mach_ymin + mach_yc * (y-slo_beg)
   }
   NR==1{slo_beg=0.0+$1; slo_end=0.0+$2; sec_beg=0.0+$3; sec_end=0.0+$4; 
      mach_yc = (mach_ymax-mach_ymin)/(slo_end-slo_beg)
      mach_xc = (mach_xmax-mach_xmin)/(sec_end-sec_beg)
   }
   /Array ref. slowness/{
      slow=$(NF)
      printf("[l1f3smvbhc]\n")
      printf("t %f %f \nRef. p %.3f\n", mach_x(0.0), mach_ymax, 0.0+$4)
   }
   /Annotation/{
      xc=mach_x($3); yc=mach_y($4);
      dx=0.07*(mach_xmax-mach_xmin); dy=0.07*(mach_ymax-mach_ymin)
      printf("[l1w4]\n")
      printf("o %f %f \n", xc, yc+  dy/2)
      printf("l %f %f \n", xc, yc+3*dy/2)
      printf("o %f %f \n", xc, yc-  dy/2)
      printf("l %f %f \n", xc, yc-3*dy/2)
      printf("o %f %f \n", xc+  dx/2, yc)
      printf("l %f %f \n", xc+3*dx/2, yc)
      printf("o %f %f \n", xc-  dx/2, yc)
      printf("l %f %f \n", xc-3*dx/2, yc)
      printf("[l1f3smvchl]\n")
      printf("t %f %f \n %s\n", xc, yc+dy, $2)
   }
   /Mag. factor/{
      printf("[l1w4]\n")
      printf("o %f %f \n", mach_x($5), mach_ymin)
      printf("l %f %f \n", mach_x($5), mach_ymax)
      printf("o %f %f \n", mach_x($7), mach_ymin)
      printf("l %f %f \n", mach_x($7), mach_ymax)
      printf("[l1w1f3ssvbhl]\n")
      printf("t %f %f \n X %.2f\n", mach_x($5), 1.05*mach_ymin,0.0+$3)
   } 
   /Y mag. factor/{
      printf("[l1w4]\n")
      printf("o %f %f \n", mach_xmin, mach_y($6))
      printf("l %f %f \n", mach_xmax, mach_y($6))
      printf("o %f %f \n", mach_xmin, mach_y($8))
      printf("l %f %f \n", mach_xmax, mach_y($8))
      printf("[l1w1f3ssvbhl]\n")
      printf("t %f %f \n X %.2f\n", 1.05*mach_xmin, mach_y($6),0.0+$4)
   } 
   /X mag. factor/{
      printf("[l1w4]\n")
      printf("o %f %f \n", mach_x($6), mach_ymin)
      printf("l %f %f \n", mach_x($6), mach_ymax)
      printf("o %f %f \n", mach_x($8), mach_ymin)
      printf("l %f %f \n", mach_x($8), mach_ymax)
      printf("[l1w1f3ssvbhl]\n")
      printf("t %f %f \n X %.2f\n", mach_x($6), 1.05*mach_ymin,0.0+$4)
   }'
else
phsref=`echo $phases | awk '{print $1}'`
for phase in $phases ; do
#  echo "Examining ${phase}" > /dev/tty
   phs=`echo $phase |
      sed -e 's/[0-9][0-9]*//' -e 's/[PS]K//' -e 's/[abcdf]//g' -e 's/\/.* //'`
   disc=`echo $phase | sed -e 's/[PpSsKabcdf]//g'`
#  Syntax is Ps[,PsPs][,PpPs]/X,Y,Z; args are X=H, Y=Vp, Z=Vp/Vs
#  if expr \( "$phase" : 'Ps/' \)   \| \( "$phase" : 'PpPs/' \) \
#	\| \( "$phase" : 'PsPs/' \) \| \( "$phase" : 'PpSs/' \) \
   if expr \( "$phase" : 'P[ps][PSps,]*/' \) \
	> /dev/null ; then
#     echo "Processing $phase" > /dev/tty
      echo "$phase" $2 $3 | awk 'BEGIN{ref="'"${phsref}"'"}{
	 n=split($1,f,"/"); ph=f[1]
	 n=split(f[2],arg,","); H=arg[1]; Vp=arg[2]; Vs=arg[2]/arg[3]
	 n=split(ph,f,",")
	 for(i=1;i<=n;i++){
	    ph=f[i]; php=sprintf("%s%.0fkm",ph,H);
	    for(del=$2+0.0; del<=$3+0.001; del+=($3-$2)/20.) {
	       p = del/111.19;
	       if (ph == "Ps") t=H*(sqrt(1/Vs^2 - p^2) - sqrt(1/Vp^2 - p^2))
	       if (ph == "PpPs") t=H*(sqrt(1/Vs^2 - p^2) + sqrt(1/Vp^2 - p^2))
	       if (ph ~ /P((sP)|(pS))s/) t=H*2*sqrt(1/Vs^2 - p^2)
	       printf "%8.3f   1 %s 0.0 0.0 0.0 0.0 0.0 0.0\n",del,ref
	       printf "        2 %s %f 0.0 0.0 0.0 0.0\n",php,t
	    }
	    printf "phases=\"${phases} %s\"\n",php > "'"${tmp}"'"
	 }
      }' >> $ttfile
      [ -f $tmp ] && . $tmp
#     echo "phases becomes ${phases}" > /dev/tty
   elif [ ! -z $disc ] ; then
      echo $phs $disc $2 $3 |
         awk '{for(del=$3+0.0;del<=$4+0.001;del+=($4-$3)/20.) print $1,del,$2}'|
         Pstimes -nohead ${tables} |
	 awk 'BEGIN{phs="'"${phase}"'"; ref="'"${phsref}"'"}
	    {printf "%6s 1 %s 0.0 0.0 0.0 0.0 0.0 0.0\n",$2,ref
	     printf "        2 %s %s 0.0 0.0 0.0 0.0\n",phs,$4
	    }' >> $ttfile
   fi
done
#echo $2 $3 $4 $5 | cat - $ttfile | tee /dev/tty |
echo $2 $3 $4 $5 | cat - $ttfile | 
awk '
#
#	This awkscript maps the start and end times (sec_beg and sec_end) in 
#	seconds on the seismogram to plotting device units. 
#	The magic device settings (mach_[x,y][max,min]) are for the SAC 
#	devices "sun" and "sgf".
#	Methodology is to run through the ttimes output and save all phase
#	names and arrival times.  Then those of the specified phases
#	are output.  Comments are placed in the .pcf file for all phases for
#	error checking purposes.
#
#       mach_ymin = 0.154; mach_ymax = 0.845; mach_offset = 0.024
BEGIN { if ("'"${11}"'" == "land") {
	    mach_xmin = 0.11; mach_xmax = 0.89
	    mach_ymin = 0.15; mach_ymax = 0.80
	    oland = 1; ltol=0.02
	} else {
	    mach_xmin = 0.10; mach_xmax = 0.90
	    mach_ymin = 0.15; mach_ymax = 0.90
	    oland = 0; ltol=0.05
        }
	mach_offset = 0.024
	np = 0;   nd = 0; cp="'"'"'"
	nmaj=split("PP PPP SKKS PKJKP PcPPKPbc PKP2ab",phsmaj)
}
NR == 1 { del_beg=0.0+$1; del_end=0.0+$2; sec_beg=0.0+$3; sec_end=0.0+$4; 
	  if(oland){
	     mach_c = (mach_ymax-mach_ymin)/(sec_end-sec_beg)
	     mach_xinc = (mach_xmax - mach_xmin)/(del_end-del_beg)
	  } else {
	     mach_xinc = (mach_xmax-mach_xmin)/(sec_end-sec_beg)
	     mach_c = (mach_ymax - mach_ymin)/(del_end-del_beg)
          }
	  nphs = split("'"${phases}"'",phases)
	  if (phases[1] ~ /\//) {
	     if (2 != split(phases[1],f,"/")) \
	        printf "**Invalid alignment phase syntax: %s\n",phases[1] > "/dev/tty"
	     phases[1] = f[2]; # phases[++nphs] = f[1]
	  }
#      
#	  If phase name has no branch suffix, let it match any branch.
	  phase_match_any = "^("; phase_join = ""
	  for(i=1;i<=nmaj;i++) phsmajfnd[i] = 0
          for(i=1; i<=nphs; i++) {
	     for(j=1;j<=nmaj;j++) { # Check for any major arc phases
	        pat= "^" phsmaj[j] "((ab)|(bc)|(df)|(ac)|[gnb])?$"
		if (phases[i] ~ pat) phsmajfnd[j] = i
	     }
#	     if (phases[i] ~ "PP") phase_PP = i
#	     if (phases[i] ~ /^SKKS/) phase_SKKS = i
#	     if (phases[i] ~ /^PcPPKP/) phase_PcPPKP = i
#	     if (phases[i] ~ /^PKJKP/) phase_PcPPKP = i
	     if (phases[i] !~ /^.*((ab)|(bc)|(df)|(ac)|[gnb])$/)
		phases[i] = phases[i] "((ab)|(bc)|(df)|(ac)|[gnb])?"
      	     if (phases[i] !~ /diff?$/)
        	phases[i] = phases[i] "(diff?)?"
	     if (phases[i] ~ /^((PKKP)|(SKKP)|(PKKS)|(PKPPKP))/)
        	phases[i] = phases[i] "(maj)?"
	     if (phases[i] ~ /^PKPPKP/)
		phases[i]="P" cp "P" cp substr(phases[i],7)
	     phase_match_any = phase_match_any phase_join "(" phases[i] ")"
	     phase_join = "|"
	     phase_match[i] = "^" phases[i] "$"
	  }
	  # If any major arc phase found, add another phase to account for
	  #   the major arc arrival.
	  for(j=1;j<=nmaj;j++) {
	     if (phsmajfnd[j] != 0) {
#               print "Major arc phase",phases[phsmajfnd[j]] > "/dev/tty"
		nphs += 1; phase_match[nphs] = "^" phases[phsmajfnd[j]] "maj$"
		phases[nphs] = phases[phsmajfnd[j]] "maj"
	     } 
	  }
#	  if (phase_SKKS != 0) {
#	     # Major arc arrival of SKKS handled separately
#	     nphs += 1; phase_match[nphs] = "^" phases[phase_SKKS] "maj$"
#	     phases[nphs] = phases[phase_SKKS] "maj"
#	  }
#	  if (phase_PcPPKP != 0) {
#	     # Major arc arrival of PcPPKP handled separately
#	     nphs += 1; phase_match[nphs] = "^" phases[phase_PcPPKP] "maj$"
#	     phases[nphs] = phases[phase_PcPPKP] "maj"
#	  }
	  phase_match_any = phase_match_any ")$"
	  phase_match_ref = "^" phases[1] "$"
#	  print "Matching:",phase_match_any,",",nphs,"phases" > "/dev/tty"
#	  print "mach_c:",mach_c > "/dev/tty"
#177.00    1  PKPdf     1209.95  20   9.95     0.1788  -1.72E-01  -5.12E-03
#         Count of number of phases for this distance
}
($0 ~ /.*\..*\..*\..*\..*\./) && (NR > 1) {
   if ($2 == "1"){
#     print $0 > "/dev/tty"
      if (np>0) {
	 if (pref == 0) print "**No reference phase at ",delta > "'"${tty}"'"
	 else {
	    nd += 1; del[nd]=delta+0.0
	    for(i=1;i<=nphs;i++) dtt[nd,i] = 100000
	    for(i=1;i<=np;i++) {
	       for(j=1;j<=nphs;j++) if (pid[i] ~ phase_match[j]) break
	       if (j<=nphs) dtt[nd,j] = ptt[i] - ptt[pref]
#	       printf "%s-%s (%d): %f-%f = %f\n",pid[i],pid[pref],j,ptt[i],ptt[pref],dtt[nd,j] > "/dev/tty"
	    }
	 }
      }
      delta=$1; pref=0; np=0
   }
   if (NF==9) {phase=$3; tt=0.0+$4} else {phase=$2; tt=0.0+$3}
   sl = 0.0+substr($0,45,9); if (sl<0.0) sfx="maj"; else sfx=""
   if ( phase ~ phase_match_any ) {
#      print $0 > "/dev/tty"
#      print "Matched ",phase > "/dev/tty"
#      printf("* Matched %s\n",phase)
       np += 1; pid[np] = phase sfx; ptt[np] = tt
       if (phase ~ phase_match_ref) pref = np
#      printf("*  %s %s %f\n",phase,delta,ptt[np]) 
   }
}
END {
   if (np>0) {
      if (pref == 0) printf "**No reference phase at ",delta > "'"${tty}"'"
      else {
	 nd += 1; del[nd]=delta+0.0
	 for(i=1;i<=nphs;i++) dtt[nd,i] = 100000
	 for(i=1;i<=np;i++) {
	    for(j=1;j<=nphs;j++) if (pid[i] ~ phase_match[j]) break
	    if (j<=nphs) dtt[nd,j] = ptt[i] - ptt[pref]
#	    printf "%s-%s (%d): %f-%f = %f\n",pid[i],pid[pref],j,ptt[i],ptt[pref],dtt[nd,j] > "/dev/tty"
	 }
      }
   }
#
#      Draw lines for each phase relative to reference phase.
#      Go through each phase successively, then through each distance.
#
    for (ip=1;ip<=nphs;ip++) {
       printf("[l4w2] \n")
       first = 1; rightmost = 0
       for (id=1;id<=nd;id++) {
   	  printf "* Delta: %f, phase: %s, time: %f orient: %d\n",del[id],phases[ip],dtt[id,ip],oland
	  if ((dtt[id,ip] < sec_beg) || (dtt[id,ip] > sec_end)) continue
	  if(oland){
	     mach_y = mach_ymin + mach_c * (dtt[id,ip]-sec_beg)
	     mach_x = mach_xmin + mach_xinc * (del[id]-del_beg)
	  } else {
	     mach_x = mach_xmin + mach_xinc * (dtt[id,ip]-sec_beg)
	     mach_y = mach_ymax - mach_c * (del[id]-del_beg)
	  }
	  if (first) {
	     printf("o %f %f \n", mach_x, mach_y)
	     if(!oland) rightmost = mach_x
	  } else {
	     printf("l %f %f \n", mach_x, mach_y)
	     if(oland) rightmost = mach_y
	  }
	  first = 0
      }
      if (rightmost != 0) {
	 n=split(phases[ip],name,"(")
	 no=0
	 for(ph in tab){
	    if (abs(tab[ph]-rightmost)<ltol) no+=1
	 }
	 if(oland){
	    printf("[l1f3stvc] \n")
            printf("t %f %f \n%s\n[vb]\n", mach_xmax, rightmost+no*0.02, name[1])
	 } else {
	    printf("[l1f3ssvc] \n")
            printf("t %f %f \n%s\n[vb]\n", rightmost, mach_ymax*1.01+no*0.02, name[1])
	 }
      }
   }
}'
fi
echo '[l1]'
/bin/rm -f $ttfile $tmp $tmp.mag
exit
