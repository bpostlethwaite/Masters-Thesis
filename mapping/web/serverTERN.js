/*jshint asi: true*/
/*jshint laxcomma: true*/
//"use strict";
var st = require("st")
  , http = require("http")
  , io = require("socket.io")
  , fs = require("fs")

// Listen on port
var PORT = 8082
  , STATIC = 'public'
  , mount = st(
    { path: './' + STATIC
    , url: '/'
    , index: 'index.html'
    })
var server = http.createServer( mount ).listen(PORT)

console.log("Static server listening on " + PORT)

/*
 * socket.io setup
 */
io = io.listen(server)
io.set('log level', 0)

/*
 * Load up station data into memory
 */
var jsonternary
var jsonstation
fs.readFile("../../data/ternplots.json", 'utf8', function (err, data) {
  if (err) throw err
  try {
    jsonternary = JSON.parse(data)
  } catch (err) {
    throw err
  }
})
fs.readFile("../../data/stations.json", 'utf8', function (err, data) {
  if (err) throw err
  try {
    jsonstation = JSON.parse(data)
  } catch (err) {
    throw err
  }
})


//
//
// SOCKETS!
//
io.sockets.on('connection', function(socket) {
  //
  // Connect content
  //
  socket.emit('ternJson', jsonternary )
  socket.emit('stationsJson', jsonstation )

})