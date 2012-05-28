#!/bin/bash

####
# FLAGS
####
WEEDREQ=1
GETFTP=0

if [ "$WEEDREQ" eq "1" ] ; then
# Take data from IRIS, copy it into dum.weed then perform
# geolocation and get rid of EQ's outside back azimuth ranges
    weed2spyder.sh dum.weed | rdneic -s -80 48 | sort -nk8 | awk '{ if ( ($7 >= 30 && $7 <= 100) ) print $0}' > event.list

# Now take sorted list and pipe it into mailer script.
# CAUTION, THIS WILL JUST MAIL OUT THE WHOLE LIST!!!
    cat event.list | cut -d' ' -f2 | evmail.sh
#echo '120501224' | cut -d' ' -f2 | evmail.sh

fi

if [ "$GETFTP" eq "1" ] ; then
    cat event.list | cut -d' ' -f2 | getFTP.sh
fi