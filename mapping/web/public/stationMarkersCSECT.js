// Standard google maps function

function initialize() {

// Initialize google map
  var myLatlng = new google.maps.LatLng(54.0, -88.0);
  var myOptions = {
    zoom: 5,
    center: myLatlng,
    mapTypeId: google.maps.MapTypeId.HYBRID
  }
  var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions)


  // Create the legend and display on the map
  var legendDiv = document.createElement('DIV')
    , legendEntry = appendlegend(legendDiv)
  legendDiv.index = 1
  map.controls[google.maps.ControlPosition.RIGHT_BOTTOM].push(legendDiv)


// Connect sockets to server and receiver station data
  var socket = io.connect("http://137.82.49.27:8080")

  // Get station data
  socket.on('stationsJson', function(data) {
    // Send station data to marker function
    addMarker(map, data, legendEntry)
  })
}

var icobj = {
  "processed-ok": "http://maps.google.com/mapfiles/marker_green.png"
, "processed-notok": "http://maps.google.com/mapfiles/marker_orange.png"
, "picked": "http://maps.google.com/mapfiles/marker_yellow.png"
, "bad station": "http://maps.google.com/mapfiles/marker.png"
, "aquired": "http://maps.google.com/mapfiles/marker_grey.png"
, "not aquired": "http://maps.google.com/mapfiles/marker_black.png"
, "data corruption": "http://maps.google.com/mapfiles/marker_purple.png"
}

var seenIcons = {}
Object.keys(icobj).forEach( function (key) {
  seenIcons[key] = false
})
// PUT ICONS AND STATUS IN A STRUCTURE AND CALL FROM LEGEND AND ADDMARKER //

function addMarker(map, data, lentry) {
  // Run though station data and create a marker for each
  // entry. We have the base station.json as well as the
  // built up ternplots.json. Need to distinguish.
  // <Not Implemented> Passing in an specification object can contol
  // the way the station.json data is presented.
  // Loop through all stations
  var stn = data.stn
  var stname = data.stname
  var img = data.fig ? '<img border="0" align="left" src="images/' + data.fig + '">' : ''
  var icon = icobj[stn.status]
  var stncoords = new google.maps.LatLng(stn.lat, stn.lon);

  var content = '<div class="content">' +
    '<h2>' + stname + '</h2>' + img +
    '<p>' + JSON.stringify(stn, null, " ").replace(/\n/g, '<br />') +
    '</p> </div>'

  createMarker(stname, stncoords, content, map, icon);
  /*
   * Add to Legend
   */
  if (!seenIcons[stn.status]) {
    lentry.innerHTML += '<img src=' + icobj[stn.status] + '> ' + stn.status + '<br/>'
    /*
     * Keep track of what is on the map for the legend
     */
    seenIcons[stn.status] = true
  }

}


function createMarker(stname, latlng, content, mapsent, icon)
{
  var marker = new google.maps.Marker({
    position: latlng,
    icon: icon,
    map: mapsent,
    title: stname
  })

  marker.info = new google.maps.InfoWindow({
    content: content
  })

  google.maps.event.addListener(marker, 'click', function(){
    marker.info.open(mapsent, marker);
  })

  return marker
}

function appendlegend(controlDiv) {
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
  controlText.innerHTML = '<b>Legend - Station Status</b><br /></br>'
  controlText.id = "legendEntry"
//  Object.keys(usedIcons).forEach( function (key) {
//    controlText.innerHTML += '<img src=' + usedIcons[key] + '/> ' + key + '<br/>'
//  })
//  controlText.innerHTML = innerHTML
  controlUI.appendChild(controlText)

  /*
   * Return Text so we can
   * dynamically add entries
   */
  return controlText

}
