#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

# Program to build station objects from state stored
# in JSON format.
# Functions to build station database from files
# and functions to add stats, add matlab data etc.

###########################################################################
# IMPORTS
###########################################################################
import json, os, argparse, sys


# CONFIGS
dbfile = os.environ['HOME'] + '/thesis/data/stations.json'


def mergeJson(target, source, pfx):
    newd = {}
    for key in source.keys():
        if key in target:
            newd[key] = target[key]
            newd[key][pfx] = {}
            for k in source[key].keys():
                newd[key][pfx][k] = source[key][k]

    return newd

if __name__== '__main__' :

    # Create top-level parser
    parser = argparse.ArgumentParser(description = "Merge two json files or streams")
    group = parser.add_mutually_exclusive_group()

    # Create query parser
    parser.add_argument('-p','--prefix', nargs = 1,
                        help = 'The prefix to use to to merge dictionary')

    parser.add_argument('mergeFile', nargs = '?',
                        help = 'The file to merge the stream into')

    # Parse arg list
    args = parser.parse_args()

    #Load station database
    if args.mergeFile:
        dbf = open(args.mergeFile[0])
    else:
        dbf =  open(dbfile)

    source = json.loads(sys.stdin.read())
    target = json.loads( dbf.read() )

    mergedjson = mergeJson(target, source, args.prefix[0])

    print json.dumps(mergedjson, sort_keys = True, indent = 2 )
