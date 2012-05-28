#!/bin/bash

SEEDDIR='/tmp/seed'

while read event; do

    curl ftp.seismo.NRCan.gc.ca/pub/autodrm/$event.seed \
	--user ftp:post.ben.here@gmail.com -o $SEEDDIR/$event.seed

    sleep 15
    
done
