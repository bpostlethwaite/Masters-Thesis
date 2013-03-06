var f = require('findit')
var fs = require('fs')
var path = require('path')

var finder = f.find("/media/TerraS/CN/" )
var count = 0

finder.on('file', function (file) {
  if (path.basename(file) === 'stack_P.sac')
    count++
})

finder.on('end', function() {
  console.log("total files = " + String(count))
})
