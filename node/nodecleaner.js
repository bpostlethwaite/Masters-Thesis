var f = require('findit')
var ncp = require('ncp').ncp
var path = require('path')

ncp.limit = 16


var stations = ["DPQ","GAC","YKW3","OTT"]
var stn = "DPQ"

var finder = f.find("/media/TerraS/CN/" + stn)



finder.on('directory', function (dir, stat) {

  var head = path.dirname(dir)
  var tail = path.basename(dir)
  tail = tail.slice(0,9)
  if (tail.length > 10) {
    console.log(tail + '/')
    ncp(dir, path.join(head, tail), function (err) {
      if (err) {
        return console.error(err)
      }
    })
    console.log('Done!')
  }
})

finder.on('file', function (file, stat) {

})