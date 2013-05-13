#!/usr/bin/nodejs
/////////////////
var stringifyParams
  , argv = require('optimist')
           .boolean('k')
           .alias('k', 'keys')
           .describe('k', 'print only keys to stdout, not JSON')
           .argv

var JSONStream = require('JSONStream')

argv._.forEach( function (arg, ind, arr) {
  if (arg === "true")
    arr[ind] = true
})


if (argv.k)
  stringifyParams = false

var Parser =  JSONStream.parse(argv._)
process.stdin.pipe(Parser)
.pipe(JSONStream.stringify(stringifyParams))
.pipe(process.stdout)