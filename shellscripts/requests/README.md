# REQUEST DATA

1. Go to IRIS event catalogue: http://www.iris.edu/SeismiQuery/sq-events.htm
2. Choose time limits,  minimum magnitude threshld >= 6.0 (?), and specify view  WEED file.
3. Cut and paste contents of WEED file into e.g. dum.weed
4. Run following command to generate a file showing azimuths and epicentral distances to Location given after rdneic
5. Use UNIX awk to cull events to include only those of interest (for teleseismic P, from 30 to 100 degrees distance)
    
    weed2spyder.sh dum.weed | rdneic -s -80 48 | \
	sort -nk1 | awk '{ if ( ($7 >= 30 && $7 <= 100) ) print $0}' > event.list

>> This outputs: name dum lat lon depth mag GCARC BackAZ

6. Stream desired events into evmail.sh and run to request data from CNSN/GSC/ETS/POLARIS stations (you may 
want to restrict what stations are requested. File cnsn.list contains an up-to-date listing of stations and 
for what periods data are available for.
7. Stream desired events into breq_usa.sh and run to request data from IRIS/US stations.

    cat event.list | cut -d' ' -f2 | uniq | evmail.sh

8. Run events through getFTP.sh to aquire data from server.
 
    cat event.list | cut -d' ' -f2 | getFTP.sh	

If getFTP.sh stops then compare the event.list with the downloaded seedfiles
and go after only the remaining events with:

	comm -13  <(ls /tmp/seed | cut -c1-9) <(cat event.list \
	| cut -d' ' -f2 | uniq) | getFTP.sh 

(remove the `| getFTP.sh` command at the end to view the discrepancy between list and downloaded)

9. Transform SEED to SAC and move into network/station/event/component.sac file structure. 
   
    rdseed -df <seedfile.seed>

10. Roll through SAC files, and run `rdneic` for each event within each station directory using station lat and lon to get a new `BAZ` and `GCARC` for use with get_tt.
