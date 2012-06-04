#!/bin/bash

STATIONS='CHEG DRLN FCC GBN HAL SCHQ SJNN ULM ICQ NATG A11 A16 A21 A54 A61 A64 LMQ BATG GGN LMN KGNO OTT SADO GAC MNTQ VABQ VLDQ ATKO EPLO KAPO KILO MALO PKLO PNPO SILO SUNO VIMO '


while read event; do

  echo  "Processing event" $event
  echo "BEGIN" > $event"_request"
  echo "EMAIL post.ben.here@gmail.com" >> $event"_request"
  echo "OUT_FILE " $event".seed" >> $event"_request"
  echo "TITLE EVENT "$event  >> $event"_request"
# THESE ARE CNSN BH STATIONS.
  echo "CHAN_LIST *H*" >> $event"_request"
# Get Stations
  echo "STA_LIST " $STATIONS >> $event"_request"
  echo NET_LIST CNSN >> $event"_request"

  yr=`echo $event | awk '{print substr($1,1,2)}'`
  if test $yr -lt 18
  then
     cn=20
  else
     cn=19
  fi

  mo=`echo $event | awk '{print substr($1,3,2)}'`
  dy=`echo $event | awk '{print substr($1,5,2)}'`
  jd=`echo $cn$yr $mo $dy | g2j | awk '{print $2}'`
  hr=`echo $event | awk '{print substr($1,7,2)}'`
  mi=`echo $event | awk '{print substr($1,9,2)}'`
  se=`grep $event event.list | awk '{print $2}'`

###################################
#  START TIME CLOSER TO P ARRIVAL. 
####################################
#  tev=`echo $se $mi $hr $jd | awk '{print $1+$2*60+$3*3600+$4*86400}'`
#  dist=`grep $event event.list | awk '{print $7}'`
#  evdp=`grep $event event.list | awk '{print $5}'`
#  tp=`get_tt -z $evdp -d $dist -p P | grep P | head -1 | awk '{print $3}'`
#  t1=`echo $tev $tp | awk '{print $1+int($2+0.5)-240}'` #Note 240 seconds before crude P arrival

## Translate back.
#  jd1=`echo $t1 | awk '{print int($1/86400)}'`
#  mo1=`echo $cn$yr $jd1 | j2g | awk '{print substr($1+100,2,2)}'`
#  dy1=`echo $cn$yr $jd1 | j2g | awk '{print substr($2+100,2,2)}'`
#  hr1=`echo $t1 $jd1 | awk '{print substr(100+int(($1-$2*86400)/3600),2,2)}'`
#  mi1=`echo $t1 $jd1 $hr1 | awk '{print substr(100+int(($1-$2*86400-$3*3600)/60),2,2)}'`
#  se1=`echo $t1 $jd1 $hr1 $mi1 | awk '{print substr(100+$1-$2*86400-$3*3600-$4*60,2,2)}'`
  
#  echo "START_TIME "$cn$yr"/"$mo1"/"$dy1 $hr1":"$mi1":"$se1  >> $event"_request"
################################

  echo "START_TIME "$cn$yr"/"$mo"/"$dy $hr":"$mi":"$se  >> $event"_request"  
  echo "DURATION 1200" >> $event"_request"
  echo "WAVE SEED" >> $event"_request"
  echo "STOP" >> $event"_request"
  #mail autodrm@seismo.nrcan.gc.ca < $event"_request"

  cat $event"_request"
  rm $event"_request"
  sleep 15

done
