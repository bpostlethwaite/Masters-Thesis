#!/bin/bash


# Take data from IRIS, copy it into dum.weed then perform
# geolocation and get rid of EQ's outside back azimuth ranges
weed2spyder.sh dum.weed | rdneic -s -95.87 50.25 | sort -nk1 | awk '{ if ( ($7 >= 30 && $7 <= 100) ) print $0}' > event.list

# Now take sorted list and pipe it into mailer script.
# CAUTION, THIS WILL JUST MAIL OUT THE WHOLE LIST!!!
cat event.list | cut -d' ' -f1 | uniq | evmail.sh
#echo '120501224' | cut -d' ' -f2 | evmail.sh

