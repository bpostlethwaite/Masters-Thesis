#!/bin/bash

SEEDDIR='/tmp/seed'

if [ ! -d "$SEEDDIR" ]; then
    mkdir $SEEDDIR
fi

while read event; do

    echo "aquiring $event"
    curl ftp.seismo.NRCan.gc.ca/pub/autodrm/$event.seed \
	--user ftp:post.ben.here@gmail.com -o $SEEDDIR/$event.seed

    sleep 15
    
done
