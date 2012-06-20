#!/bin/sh
#for event in `cat dum1 | awk '{print $1}' | sort`
for event in 0002290435 0002290831 0002292244 0003010421 
do 
  echo  "Processing event" $event
  echo "BEGIN" > $event"_request"
  echo "EMAIL bostock@eos.ubc.ca" >> $event"_request"
  echo "OUT_FILE " $event".seed" >> $event"_request"
  echo "TITLE EVENT "$event  >> $event"_request"
# THESE ARE CNSN BH STATIONS.
  echo "CHAN_LIST *H*" >> $event"_request"
# For "ETS" stations.
  echo "STA_LIST  AHCB BMSB BPCB CPLB SPLB SOKB GHNB PHYB PPSB SDH TOFB ACHB ATLB DHLB FCBC JRBB JRBC KHVB LCBC PPSB SHDB SHVB TASB TFRB THAB GLBC" >> $event"_request"
  echo NET_LIST ETS >> $event"_request"
# FOR REGULAR CNSN STATIONS
#  echo "STA_LIST KLNB PFB LZB VGZ OZB MGB SNB GOBB SNB HBDB MCBW MGCB OZB PGC FHRB TLCB TOFB SHB TWBB TWGB TWKB YOUB SILB TSJB WPB BIB BPBC BTB EDB ETB GDR HRMB MAYB NCRB NLLB TXB VDB WSLR SSIB KELB GOWB CLVB ENGB COQB HLSB PIMB GHNB ANMB" >> $event"_request"
#  echo NET_LIST CNSN >> $event"_request"

  yr=`echo $event | awk '{print substr($1,1,2)}'`
  if test $yr -lt 10
  then
     cn=20
  else
     cn=19
  fi

  mo=`echo $event | awk '{print substr($1,3,2)}'`
  dy=`echo $event | awk '{print substr($1,5,2)}'`
  jd=`echo $cn$yr $mo $dy | g2j | awk '{print $2}'`
  jd2=$jd
  hr=`echo $event | awk '{print substr($1,7,2)}'`
  hr2=$hr
  mi=`echo $event | awk '{print substr($1,9,2)}'`
#  se=`grep $event pkp_pgc.list | awk '{print $2}'`
  se=`grep $event pgc.list | awk '{print $2}'`
  tev=`echo $se $mi $hr $jd | awk '{print $1+$2*60+$3*3600+$4*86400}'`
  dist=`grep $event pgc.list | awk '{print $7}'`
  evdp=`grep $event pgc.list | awk '{print $5}'`
#  dist=`grep $event pkp_pgc.list | awk '{print $7}'`
#  evdp=`grep $event pkp_pgc.list | awk '{print $5}'`
#  tp=`get_tt -z $evdp -d $dist -p PKP | grep PKP | head -1 | awk '{print $3}'`
#  get_tt -z $evdp -d $dist -p PKP | grep PKP
  tp=`get_tt -z $evdp -d $dist -p P | grep P | head -1 | awk '{print $3}'`
#  get_tt -z $evdp -d $dist -p P | grep P
  t1=`echo $tev $tp | awk '{print $1+int($2+0.5)-120}'`
#  t2=`echo $tev $tp | awk '{print $1+int($2+0.5)+480}'`

# Translate back.
  jd1=`echo $t1 | awk '{print int($1/86400)}'`
  mo1=`echo $cn$yr $jd1 | j2g | awk '{print substr($1+100,2,2)}'`
  dy1=`echo $cn$yr $jd1 | j2g | awk '{print substr($2+100,2,2)}'`
  hr1=`echo $t1 $jd1 | awk '{print substr(100+int(($1-$2*86400)/3600),2,2)}'`
  mi1=`echo $t1 $jd1 $hr1 | awk '{print substr(100+int(($1-$2*86400-$3*3600)/60),2,2)}'`
  se1=`echo $t1 $jd1 $hr1 $mi1 | awk '{print substr(100+$1-$2*86400-$3*3600-$4*60,2,2)}'`
#  jd2=`echo $t2 | awk '{print int($1/86400)}'`
#  mo2=`echo $cn$yr $jd2 | j2g | awk '{print substr($1+100,2,2)}'`
#  dy2=`echo $cn$yr $jd2 | j2g | awk '{print substr($2+100,2,2)}'`
#  hr2=`echo $t2 $jd2 | awk '{print substr(100+int(($1-$2*86400)/3600),2,2)}'`
#  mi2=`echo $t2 $jd2 $hr2 | awk '{print substr(100+int(($1-$2*86400-$3*3600)/60),2,2)}'`
#  se2=`echo $t2 $jd2 $hr2 $mi2 | awk '{print substr(100+$1-$2*86400-$3*3600-$4*60,2,2)}'`

#  echo "TIME "$cn$yr"/"$mo1"/"$dy1 $hr1":"$mi1":"$se1 "TO "$cn$yr"/"$mo2"/"$dy2 $hr2":"$mi2":"$se2 >> $event"_request"
  echo "START_TIME "$cn$yr"/"$mo1"/"$dy1 $hr1":"$mi1":"$se1  >> $event"_request"
  echo "DURATION 600 >> $event"_request"
  echo "WAVE SEED" >> $event"_request"
  echo "STOP" >> $event"_request"
#  mail autodrm@seismo.nrcan.gc.ca < $event"_request"

done
