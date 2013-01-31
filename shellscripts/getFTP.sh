#!/bin/bash

SEEDDIR='/tmp/seed'
EMAIL='post.ben.here@gmail.com'

# Set up a download directory
if [ ! -d "$SEEDDIR" ]; then
    mkdir $SEEDDIR
fi

# Loop through piped in names of seed files
while read event; do

    echo "aquiring $event"
    curl ftp.seismo.NRCan.gc.ca/pub/autodrm/$event.seed \
    	--user ftp:$EMAIL -o $SEEDDIR/$event.seed

    sleep 5

done
