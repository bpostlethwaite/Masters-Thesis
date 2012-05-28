#!/bin/bash

while read event; do

    curl ftp.seismo.NRCan.gc.ca/pub/autodrm/$event.seed \
	--user ftp:post.ben.here@gmail.com -o $event.seed

done
