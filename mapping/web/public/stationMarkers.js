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


  // Create the legend and display on the map
  var legendDiv = document.createElement('DIV');
  var legend = new Legend(legendDiv, map);
  legendDiv.index = 1;
  map.controls[google.maps.ControlPosition.RIGHT_BOTTOM].push(legendDiv);


// Connect sockets to server and receiver station data
  var socket = io.connect("http://192.168.1.124:8111")
  var dpackets = {}
  var receivedpacks = 2
  socket.on('ternJson', function(data) {
    // Send station data to marker function
    dpackets.tern = data
    receivedpacks -= 1
    syncdata()
  })
  socket.on('stationsJson', function(data) {
    // Send station data to marker function
    dpackets.stns = data
    receivedpacks -= 1
    syncdata()
  })

  function syncdata() {
    console.log(receivedpacks)
    if(receivedpacks === 0)
      addMarkers(map, dpackets)
  }
}



function addMarkers(map, data) {
  // Run though station data and create a marker for each
  // entry. We have the base station.json as well as the
  // built up ternplots.json. Need to distinguish.
  // <Not Implemented> Passing in an specification object can contol
  // the way the station.json data is presented.
  // Loop through all stations
  var stns = data.stns
  var tern = data.tern
  for(var stn in stns) {
    if (tern.hasOwnProperty(stn)) {
      var s = tern[stn]
      var stncoords = new google.maps.LatLng(s.lat, s.lon);
      var icon = "http://maps.google.com/mapfiles/ms/icons/green-dot.png"
      var img = "tern_" + stn + ".png"
      var content = '<div class="content">' +
        '<h2>' + stn + '</h2>' +
        '<img border="0" align="left" src="images/'+img+'">' +
        '<p>' + JSON.stringify(s, null, " ").replace(/\n/g, '<br />') +
        '</p> </div>'

      createMarker(stn, stncoords, content, map, icon);
      }
    else {
      var icon
      var s = stns[stn]
      var stncoords = new google.maps.LatLng(s.lat, s.lon);
      if(s.usable === 1)
        icon = "http://maps.google.com/mapfiles/ms/icons/blue-dot.png"
      else if(s.status === "not aquired")
        icon = "http://maps.google.com/mapfiles/ms/icons/purple-dot.png"
      else
        icon = "http://maps.google.com/mapfiles/ms/icons/red-dot.png"
      var content = '<div class="content">' +
        '<h2>' + stn + '</h2>' +
        '<p>' + JSON.stringify(s, null, " ").replace(/\n/g, '<br />') +
        '</p> </div>'
      createMarker(stn, stncoords, content, map, icon);
    }
  }
}

function createMarker(stn, latlng, content, mapsent, icon)
{
  var marker = new google.maps.Marker({
    position: latlng,
    icon: icon,
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

function Legend(controlDiv, map) {
  // Set CSS styles for the DIV containing the control
  // Setting padding to 5 px will offset the control
  // from the edge of the map
  controlDiv.style.padding = '5px';

  // Set CSS for the control border
  var controlUI = document.createElement('DIV');
  controlUI.style.backgroundColor = 'white';
  controlUI.style.borderStyle = 'solid';
  controlUI.style.borderWidth = '1px';
  controlUI.title = 'Legend';
  controlDiv.appendChild(controlUI);

  // Set CSS for the control text
  var controlText = document.createElement('DIV');
  controlText.style.fontFamily = 'Arial,sans-serif';
  controlText.style.fontSize = '12px';
  controlText.style.paddingLeft = '4px';
  controlText.style.paddingRight = '4px';

  // Add the text
  controlText.innerHTML = '<b>Legend - Station Status</b><br /></br>' +
    	'<img src="http://maps.google.com/mapfiles/ms/micons/green-dot.png" /> Ternary Plot + Mooney<br />' +
  	'<img src="http://maps.google.com/mapfiles/ms/micons/blue-dot.png" /> Processed - Good <br />' +
  	'<img src="http://maps.google.com/mapfiles/ms/micons/red-dot.png" /> Processed - Bad data <br />' +
  	'<img src="http://maps.google.com/mapfiles/ms/micons/purple-dot.png" /> Not aquired <br />' +
   	'<small>*Data is fictional</small>';
  controlUI.appendChild(controlText);
}