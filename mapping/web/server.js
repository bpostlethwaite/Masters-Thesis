/*jshint asi: true*/
/*jshint laxcomma: true*/
"use strict";
var server = require("node-static")
  , app = require("http").createServer(handler)
  , io = require("socket.io").listen(app)
  , fs = require("fs")

// Listen on port
var port = 8111
app.listen(port)
console.log("Static server listening on " + port)

// Minimal logging level
io.set('log level', 0)

//
// BORING SERVER
//
var clientFiles = new server.Server("./public")
function handler(request, response) {
  request.addListener('end', function() {
    //
    // Serve files!
    //
    clientFiles.serve(request, response, function(err, res) {
      if (err) { // An error as occured
        console.log("> Error serving " + request.url + " - " + err.message)
        response.writeHead(err.status, err.headers);
        response.end()
      }
      else { // The file was served successfully
        console.log("> " + request.url + " - " + res.message)
      }
    })
  })
}

//
// Load up station data into memory
//
var json
fs.readFile("../../ternplots.json", 'utf8', function (err, data) {
  if (err) throw err
  try {
    json = JSON.parse(data)
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
  socket.emit('stationJson', json )
})