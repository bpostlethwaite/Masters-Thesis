#!/bin/sh

# Eastern
#STATIONS='CHEG DRLN FCC GBN HAL SCHQ SJNN ULM ICQ NATG A11 A16 A21 A54 A61 A64 LMQ BATG GGN LMN KGNO OTT SADO GAC MNTQ VABQ VLDQ ATKO EPLO KAPO KILO MALO PKLO PNPO SILO SUNO VIMO '

# Northern
#STATIONS='EUNU BVCY DAWY HYT INK PLBC WHY YUK1 YUK2 YUK3 YUK4 YUK5 YUK6 YUK7 CLRN FRB RES'

#Cluster ID:  NE
#Cluster Lon / Lat:  -82.629555628 67.4848823627
#STATIONS='NUNN MRYN KUGN JOSN CMBN SBNU ARVN IGLN AP3N B2NU WAGN LAIN AKVQ SEDN KNGQ CDKN BULN GIFN TULEG QILN INUQ SRLN SMLN KRSQ YRTN MCMN UPNG IVKQ STLN ILON B1NU GFNU YBKN PINU'

#Cluster ID: NW
#Cluster Lon / Lat:  -119.125289508 63.8850950385
#STATIONS='CLVN HMNT COWN YKW4 GLWN DVKN LGSN LDBN MANA DSMN SNPN CTLN NODN YKW5 YKW1 BOXN MGTN JERN MLON YKW2 HILA YMBN YNEN GDLN IHLN FSMA SMPN RDEA EKTN DLBC SNLN ROMN MCKN HPLN KUKN DHRN KNDN GALN GBLN WHFN'
#STATIONS='EDZN ILKN LUPN FNBB FNBC ACKN MBC CAMN COKN YKW3 HFRN LDGN'

# Cluster ID:  East Coast
#Cluster Lon / Lat:  -65.2107601448 49.199844889
#STATIONS='WBHL HAL NWRL CODG GASG SCH MADG MALG SABG YOSQ MKVL QCQ NANL TIGG DMCQ KAJQ'

#Cluster ID:  Central
#Cluster Lon / Lat:  -80.1393215565 47.173313008
#STATIONS='ORIO STCO PKRO KJKQ LINO SNQN BWLO ORHO CLWO KASO MPPO DREO BASO MUMO LATQ HGVO LDIO WEMQ PLVO BRCO ACTO MRHQ BMRO BELQ SSNO RDLO OTRO NSKO MNT WLVO PECO DRCO KLBO HSMO BUKO MEDO'
#STATIONS='SNKN BRPO ELGO RLKO PTCO TYNO DRWO PLIO LSQQ ALFO KSVO NEMQ MATQ VDBQ MSNO DSNO DPQ UWOO CLPO CHGQ CBRQ DELO I10H1 BANO TOBO ELFO NMSQ RSPO PEMO TORO ALGO'

# REPLACEMENTS
#Centroid: [45.93916875511448, -77.865459826293602]
#STATIONS='TOBO ALGO BRPO ELGO DPQ TYNO TORO DRWO LSQQ ALFO NEMQ MATQ DSNO QCQ PTCO UWOO CLPO CHGQ KSVO CBRQ DELO HSMO BANO VDBQ ELFO NMSQ RSPO PLIO PEMO'
# Centroid: [53.900421891750774, -63.300984677402028]
#STATIONS='KRSQ WBHL SCH SABG NWRL MKVL NANL'
#Centroid: [71.345789950524036, -80.248527296905493]
#STATIONS='SBNU IGLN B2NU B1NU IVKQ MBC GFNU UPNG PINU'
#Centroid: [51.907729523541249, -88.290815468256724]
#STATIONS='KASO MUMO OTRO LDIO SNKN NSKO RDLO MSNO RLKO I10H1'
# Centroid: [-115.9, 53.64]
#STATIONS='WALA MEDA WAPA EDM RDEA PRDA RAYA SLEB BMBC FNBC'
#Centroid: [-123.6, 52.6]
#STATIONS='SULB ALRB MCMB1 UBRB FPLB THMB CLSB FLLB TALB RAMB'
#Centroid: [-122.2 49.6]
STATIONS='WSLR PMB LLLB HBDB HRMB HLSB HOPB PNT HNB PIMB COQB ANMB'
#Cluster ID:  West
#Cluster Lon / Lat:  -124.08 50.58
#STATIONS='CLVB FALL VIB BCBC PGCB MWAB WISB KELB THAB PHC QURY BPCB TLCB TFRB SNB PACB GHNB BMSB YOUB SHB SPLB VGZ CBB LCBC KHVB '
#STATIONS='WTRB PGC BTB LZB DHLB ENGB PA05 SILB TSJB GLBC ATLB RUBB TOFB MOBC TASB KLNB CLAP SHDB DAWS BBB SSIB SOKB TWKB PHYB EDB OZB'
#STATIONS='DIB PA12 FHRB CPLB FCBC PPSB JRBB SHVB KANO PA04 PA01 HOLB PA03 PA02 AHCB PFB MGB JRBC TWGB NLLB GOWB'

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
  echo "NET_LIST CNSN POLARIS" >> $event"_request"

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
  tev=`echo $se $mi $hr $jd | awk '{print $1+$2*60+$3*3600+$4*86400}'`
  dist=`grep $event event.list | awk '{print $7}'`
  evdp=`grep $event event.list | awk '{print $5}'`
  tp=`$HOME/bin/Get_tt/get_tt -z $evdp -d $dist -p P | grep P | head -1 | awk '{print $3}'`
  t1=`echo $tev $tp | awk '{print $1+int($2+0.5) - 120}'` #Note 120 seconds before crude P arrival
## Translate back.
  jd1=`echo $t1 | awk '{print int($1/86400)}'`
  mo1=`echo $cn$yr $jd1 | j2g | awk '{print substr($1+100,2,2)}'`
  dy1=`echo $cn$yr $jd1 | j2g | awk '{print substr($2+100,2,2)}'`
  hr1=`echo $t1 $jd1 | awk '{print substr(100+int(($1-$2*86400)/3600),2,2)}'`
  mi1=`echo $t1 $jd1 $hr1 | awk '{print substr(100+int(($1-$2*86400-$3*3600)/60),2,2)}'`
  se1=`echo $t1 $jd1 $hr1 $mi1 | awk '{print substr(100+$1-$2*86400-$3*3600-$4*60,2,2)}'`
################################

  echo "START_TIME "$cn$yr"/"$mo1"/"$dy1"."$hr1":"$mi1":"$se1  >> $event"_request"
#  echo "START_TIME" $cn$yr"/"$mo"/"$dy"."$hr":"$mi":"$se  >> $event"_request"
  echo "DURATION 600" >> $event"_request"
  echo "WAVE SEED" >> $event"_request"
  echo "STOP" >> $event"_request"
#  mail post.ben.here@gmail.com < $event"_request"
  mail autodrm@seismo.nrcan.gc.ca < $event"_request"
  rm $event"_request"
  sleep 1


done
