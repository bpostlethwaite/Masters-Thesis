var f = require('findit')
var fs = require('fs')
var path = require('path')


process.stdin.resume()
process.stdin.setEncoding('utf8')

var stns
process.stdin.on('data', function (chunk) {
  chunk = chunk.replace(/\n$/, "")
  stns = chunk.split("\n")
})

// var finder = f.find("/media/TerraS/CN/" + stn)



// finder.on('directory', function (dir, stat) {

//   var head = path.dirname(dir)
//   var tail = path.basename(dir)
//   if (tail.length === 9) {
//     rmdir(dir, function (err) {
//       if (err) throw err
//     })
//     return
//   }
//   if (tail.length > 10) {
//     tail = tail.slice(0,10)
//     fs.rename(dir, path.join(head, tail), function (err) {
//       console.log(dir)
//       if (err) throw err
//     })
//   }
// })


// finder.on('file', function (file, stat) {
//   console.log(file)
// })