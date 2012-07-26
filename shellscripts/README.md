# REQUEST DATA

1. Go to IRIS event catalogue: http://www.iris.edu/SeismiQuery/sq-events.htm
2. Choose time limits,  minimum magnitude threshld >= 6.0 (?), and specify view  WEED file.
3. Cut and paste contents of WEED file into e.g. dum.weed
4. Run following command to generate a file showing azimuths and epicentral distances to Location given after rdneic
5. Use UNIX awk to cull events to include only those of interest (for teleseismic P, from 30 to 100 degrees distance)

    weed2spyder.sh dum.weed | rdneic -s  -82.62 67.48 | sort -nk1 | awk '{ if ( ($7 >= 30 && $7 <= 100) ) print $0}' > event.list

>> This outputs the following columns: name dum lat lon depth mag GCARC BackAZ

6. Stream desired events into evmail.sh and run to request data from CNSN/GSC/ETS/POLARIS stations (you may
want to restrict what stations are requested. File cnsn.list contains an up-to-date listing of stations and
for what periods data are available for.
7. Stream desired events into breq_usa.sh and run to request data from IRIS/US stations.

    cat event.list | cut -d' ' -f1 | uniq | evmail.sh

8. Run events through getFTP.sh to aquire data from server.

    cat event.list | cut -d' ' -f1 | uniq | getFTP.sh


If things get confusing as to what has and has not been downloaded do list comparisons with:

	comm -13  <(ls /tmp/seed/ | cut -c1-10 | sort | uniq) <(cat event.list | cut -d' ' -f1 | sort | uniq)

or if you created a deseeded file with the output of `deseeded.py`:

	comm -13  <(cat deseeded | sort | uniq) <(cat event.list | cut -d' ' -f1 | sort | uniq)

(just add a `| getFTP.sh` command at the end to try and download the remaining files)
(tip, use a `head -n x` and `tail +n x` to pipe parts of the list. `tail +n x` is the inverse head, it cuts of everything but last `x` lines.)

10. Transform SEED to SAC and move into network/station/event/component.sac file structure.

    rdseed -df <seedfile.seed>

or run `deseed.py >> deseeded` which also builds out the directory structure in given root folder.

11. Roll through SAC files, and run `rdneic` for each event within each station directory using station lat and lon to get a new `BAZ` and `GCARC` for use with get_tt.  This is included in `preprocessor.py` which can be run with `loopApplyDRIVER.py` with the rest of the preprocessing.
