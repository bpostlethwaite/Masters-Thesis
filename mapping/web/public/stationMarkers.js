// Standard google maps function

function initialize() {

// Initialize google map
  var myLatlng = new google.maps.LatLng(54.0, -88.0);
  var myOptions = {
    zoom: 5,
    center: myLatlng,
    mapTypeId: google.maps.MapTypeId.HYBRID
  }
  var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

// Connect sockets to server and receiver station data
//  var socket = io.connect("http://192.168.1.124:8111")
  var socket = io.connect("http://24.84.18.166")
  socket.on('stationJson', function(data) {
    // Send station data to marker function
    addMarkers(map, data);
  })
}

function addMarkers(map, data) {
  // Run though station data and create a marker for each
  // entry.
  // <Not Implemented> Passing in an specification object can contol
  // the way the station.json data is presented.
  // Loop through all stations
  for(var stn in data) {
    var s = data[stn]
    var stncoords = new google.maps.LatLng(s.lat, s.lon);
    var img = "tern_" + stn + ".png"
    var content = '<div class="content">' +
      '<h2>' + stn + '</h2>' +
    '<img border="0" align="left" src="images/'+img+'">' +
      '<p>' + JSON.stringify(s, null, " ").replace(/\n/g, '<br />') +
      '</p> </div>'

    createMarker(stn, stncoords, content, map);
  }
}

function createMarker(stn, latlng, content, mapsent)
{
    var marker = new google.maps.Marker({
                       position: latlng,
                       map: mapsent,
                       title: stn
                       });

    marker.info = new google.maps.InfoWindow({
      content: content
    });

    google.maps.event.addListener(marker, 'click', function(){
        marker.info.open(mapsent, marker);
    });

    return marker;
}
