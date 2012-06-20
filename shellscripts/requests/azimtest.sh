#!/bin/bash

# Script to pipe in event.list data and get out travel time differences for 
# different events. Program in two stations to use as comparisons.

AZIM="/home/bpostlet/thesis/shellscripts/requests/azim"
GETT="/home/bpostlet/bin/Get_tt/get_tt"
while read event; do

    evlat=`echo $event | awk '{print $3}'`
    evlon=`echo $event | awk '{print $4}'`

    ulmdel=`$AZIM -s -95.87 50.25 -e $evlon $evlat | grep DELTA | awk '{print $2}'`
    drlndel=`$AZIM -s -57.5042 49.256 -e $evlon $evlat | grep DELTA | awk '{print $2}'`

    Ut=`$GETT -z 20 -d $ulmdel -p P | grep P | head -1 | awk '{print $3}'`
    Dt=`$GETT -z 20 -d $drlndel -p P | grep P | head -1 | awk '{print $3}'`
    
    echo $Ut $Dt

    #gent=`$GETT -z 20 -d $ulmdel -p P | grep P | head -1 | awk '{print $3}'`

    # Get diff between arrival times
    #echo $((${Ut/\.*} - ${Dt/\.*}))
done
