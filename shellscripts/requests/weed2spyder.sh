#!/bin/sh
# Shell script takes input from IRIS search catalogue
# http://www.iris.washington.edu/quakes/catalogs.htm)
# and puts into format of old SPYDER catalogue.
cat $1 | awk -F, '{if ($3 < 0) lat="S"; else lat="N"; if ($4 < 0) lon="W"; else lon="E";\
     printf (" 00  %s %#3.0f %5.2f %s  %6.2f %s %3.0f %s\n", substr($2,4,2)substr($2,7,2)substr($2,10,2)substr($2,13,2)substr($2,16,2) ,substr($2,19,2), sqrt($3*$3),lat,sqrt($4*$4),lon,$5,$9) }' 
#printf (" 00  %s  %2.0f %5.2f %s %6.2f %s %3.0f %s\n", substr($2,4,2)substr($2,7,2)substr($2,10,2)substr($2,13,2)substr($2,16,2) ,substr($2,19,2), sqrt($3*$3),lat,sqrt($4*$4),lon,$5,$9) }'