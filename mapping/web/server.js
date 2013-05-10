/*jshint asi: true*/
/*jshint laxcomma: true*/
"use strict";

var st = require("st")
  , http = require("http")
  , io = require("socket.io")
  , fs = require("fs")

// Listen on port
var PORT = 8080
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


//
// Load up station data into memory
//
var jsonstation
fs.readFile("../../data/stations.json", 'utf8', function (err, data) {
  if (err) throw err
  try {
    jsonstation = JSON.parse(data)
  } catch (err) {
    throw err
  }
})

/*
 * We are assuming the async read is completed before a connection attempt.
 * In this simple application that assumption is completely valid
 */
io.sockets.on('connection', function(socket) {
  /*
   * On connection fire off all the stations, plus the image
   * data if there is any.
   */

  Object.keys(jsonstation).forEach(function(key) {
    var fig = "csect_"+key+".png"
    var data = {
      stn : jsonstation[key]
    , stname : key
    , fig : fs.existsSync("public/images/"+fig) ? fig : ""
    }
    socket.emit('stationsJson', data )
  })




})