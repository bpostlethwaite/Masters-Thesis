#!/usr/bin/nodejs
/////////////////

var split = require('split')

var splitter =  split()

process.stdin.pipe(splitter)

var acc = 0
var count = 0

splitter.on('data',function (data) {
  if (data) {
    acc += parseFloat(data)
    count += 1
  }
})

splitter.on('end', function () {
  console.log(acc/count)
  console.log('count =', count)
})