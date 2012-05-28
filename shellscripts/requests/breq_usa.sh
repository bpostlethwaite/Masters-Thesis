#!/bin/sh
# First line for comparison.
#  echo " ANTO   II   89   1   2    2   10   36.67   89   1    2    2   12   36.67   1   SH?"

# For each event.
  for event in `cat event.list | awk '{print $1}'`
  do
     line=`grep $event 2007_cul.baz`
     evla=`echo $line | awk '{print $3}'`
     evlo=`echo $line | awk '{print $4}'`
     evdp=`echo $line | awk '{print $5}'`

# Determine Julian day, hour, minute and second of event.
     yr=`echo $line | awk '{print 20substr($1,1,2)}'`
     mo=`echo $line | awk '{print substr($1,3,2)}'`
     da=`echo $line | awk '{print substr($1,5,2)}'`
     jd=`echo 20$yr $mo $da | g2j | awk '{print $2}'`
     hr=`echo $line | awk '{print substr($1,7,2)}'`
     mi=`echo $line | awk '{print substr($1,9,2)}'`
     se=`echo $line | awk '{print $2}'`
     tev=`echo $se $mi $hr $jd | awk '{print $1+$2*60+$3*3600+$4*86400}'`


# For each station.
     for sta in `cat USASTA.txt | awk '{print $3}'`
     do
        line=`grep $sta BKSTA.txt` 
        stla=`echo $line | awk '{print $4}'`
        stlo=`echo $line | awk '{print $5}'`
        stel=`echo $line | awk '{print $6}'`
        nw=`echo $line | awk '{print $1}'`

# Determine expected P-arrival time.
        dist=`azim -s $stlo $stla -e $evlo $evla |\
                   grep DELTA | awk '{print $2}'`
        tp=`get_tt -z $evdp -d $dist -p P | head -1 | awk '{print $3}'`
          
# Determine begin time (2 minutes early) and end time (8 minutes later).
        t1=`echo $tev $tp | awk '{print $1+int($2+0.5)-120}'`
        t2=`echo $tev $tp | awk '{print $1+int($2+0.5)+480}'`

# Translate back.
        jd1=`echo $t1 | awk '{print int($1/86400)}'` 
        hr1=`echo $t1 $jd1 | awk '{print substr(100+int(($1-$2*86400)/3600),2,2)}'`
        mi1=`echo $t1 $jd1 $hr1 | awk '{print substr(100+int(($1-$2*86400-$3*3600)/60),2,2)}'`
        se1=`echo $t1 $jd1 $hr1 $mi1 | awk '{print substr(100+$1-$2*86400-$3*3600-$4*60,2,2)}'`
        mo1=`echo 20$yr $jd1| j2g | awk '{print substr($1+100,2,2)}'` 
        da1=`echo 20$yr $jd1| j2g | awk '{print substr($2+100,2,2)}'`

        jd2=`echo $t2 | awk '{print int($1/86400)}'` 
        hr2=`echo $t2 $jd2 | awk '{print substr(100+int(($1-$2*86400)/3600),2,2)}'`
        mi2=`echo $t2 $jd2 $hr2 | awk '{print substr(100+int(($1-$2*86400-$3*3600)/60),2,2)}'`
        se2=`echo $t2 $jd2 $hr2 $mi2 | awk '{print substr(100+$1-$2*86400-$3*3600-$4*60,2,2)}'`
        mo2=`echo 20$yr $jd2| j2g | awk '{print substr($1+100,2,2)}'`
        da2=`echo 20$yr $jd2| j2g | awk '{print substr($2+100,2,2)}'`

# Construct BREQF line.
        if [ "$sta" = "ELW" -o  "$sta" = "ERW" -o "$sta" = "SP2" -o "$sta" = "SEA" ]
        then
          echo $yr $mo1 $da1 $hr1 $mi1 $se1 $mo2 $da2 $hr2 $mi2 $se2 $sta $nw |\
awk '{printf (" %s   %s   %s %s  %s   %s   %s   %5.2f   %s  %s   %s   %s   %s   %5.2f   1   HH?\n",$12,$13,$1,$2,$3,$4,$5,$6,$1,$7,$8,$9,$10,$11)}'
        else
          echo $yr $mo1 $da1 $hr1 $mi1 $se1 $mo2 $da2 $hr2 $mi2 $se2 $sta $nw |\
awk '{printf (" %s   %s   %s %s  %s   %s   %s   %5.2f   %s  %s   %s   %s   %s   %5.2f   1   BH?\n",$12,$13,$1,$2,$3,$4,$5,$6,$1,$7,$8,$9,$10,$11)}'
        fi
#                 
      done
  done
