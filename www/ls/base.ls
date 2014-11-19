referrer = document.referrer || document.location.toString!
referrer = referrer.split '#' .0
sync = (mapMaster, mapSlave) ->
  mapMaster.on "drag" ->
    {lat, lng} = mapMaster.getCenter!
    center = [lat, lng]
    zoom = mapMaster.getZoom!
    mapSlave.setView center, zoom, animate: no

  mapSlave.on "drag" ->
    {lat, lng} = mapSlave.getCenter!
    center = [lat, lng]
    zoom = mapSlave.getZoom!
    mapMaster.setView center, zoom, animate: no

  mapMaster.on \zoomstart (evt) ->
    <~ setImmediate
    return unless evt.target._animateToCenter
    return if mapMaster.getZoom! == evt.target._animateToZoom
    {lat, lng} = evt.target._animateToCenter
    center = [lat, lng]
    mapSlave.setView center, evt.target._animateToZoom

  mapSlave.on \zoomstart (evt) ->
    <~ setImmediate
    return unless evt.target._animateToCenter
    return if mapSlave.getZoom! == evt.target._animateToZoom
    {lat, lng} = evt.target._animateToCenter
    center = [lat, lng]
    mapMaster.setView center, evt.target._animateToZoom
  mapSlave.on \baselayerchange ({layer}) ->
    {lat, lng} = mapMaster.getCenter!
    center = [lat, lng]
    zoom = mapMaster.getZoom!
    mapSlave.setView center, zoom, animate: no

  mapMaster.on \mousemove ({{lat, lng}:latlng}) ->
    if not mapSlave.slaveMarkerAdded
      mapSlave.addLayer mapSlave.slaveMarker
      mapSlave.slaveMarkerAdded = yes
    if mapMaster.slaveMarkerAdded
      mapMaster.removeLayer mapMaster.slaveMarker
      mapMaster.slaveMarkerAdded = no
    latlng = [lat, lng]
    mapSlave.slaveMarker.setLatLng latlng

  mapSlave.on \mousemove ({{lat, lng}:latlng}) ->
    if not mapMaster.slaveMarkerAdded
      mapMaster.addLayer mapMaster.slaveMarker
      mapMaster.slaveMarkerAdded = yes
    if mapSlave.slaveMarkerAdded
      mapSlave.removeLayer mapSlave.slaveMarker
      mapSlave.slaveMarkerAdded = no
    latlng = [lat, lng]
    mapMaster.slaveMarker.setLatLng latlng

res = resolutions: [0 to 13].map -> 2048.256 / (2 ** it)
proj = proj4 "+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=30.28813975277778 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +units=m no_defs"
crs = new L.Proj.CRS.TMS do
  * "EPSG:102067"
  * "+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=30.28813975277778 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +units=m no_defs"
  * [-925000.000000000000 -1444353.535999999800 -400646.464000000040 -920000.000000000000]
  * res
crs2 = new L.Proj.CRS.TMS do
  * "EPSG:102067"
  * "+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=30.28813975277778 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +units=m no_defs"
  * [-920000.000000000000 -1444353.535999999800 -400646.464000000040 -920000.000000000000]
  * res
icon = L.divIcon className: "slaveMarker"
manualHash = no
maps = for let i in [0, 1]
  elm = document.createElement "div"
    ..className = "map"
    ..id = "map-#i"
  ig.containers.base.appendChild elm
  center = if location.hash
    [lat, lon, zoom] = location.hash.substr 1 .split /[^-\.0-9]+/
    lat = parseFloat lat
    lon = parseFloat lon
    zoom = parseFloat zoom
    [lat, lon]
  else
    zoom = 10
    [49.820540567975925 14.430988109454786]
  map = L.map do
    * elm
    * zoom: zoom
      maxZoom: 13
      center: center
      inertia: no
      zoomControl: !i
      crs: if i then crs2 else crs
  map.slaveMarker = L.marker [0, 0], {icon}
  map.slaveMarkerAdded = no
  map.on \click ->
    manualHash := yes
    {lat, lng} = it.latlng
    console.log lat, lng

    window.location.hash = "#{lat.toFixed 4},#{lng.toFixed 4},#{map.getZoom!}"
  if i is 0
    mapGroup = L.layerGroup!
      ..addLayer L.tileLayer do
        * 'https://samizdat.cz/proxy/cuzk_geo//WMTS_ZM/service.svc/get?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=zm&STYLE=default&TILEMATRIXSET=jtsk%3Aepsg%3A102067&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&FORMAT=image%2Fjpeg'
        * attribution: "Základní mapy ČR © <a href='http://www.cuzk.cz/' target='_blank'>ČUZK</a>"
      ..addLayer L.tileLayer.wms do
        * 'https://samizdat.cz/proxy/cuzk_archiv/cgi-bin/mapserv.exe?projection=EPSG:102067&srs=EPSG:102067&map=e:/wwwdata/main/cio_main_wms_05.map'
        * format: 'png24',
          transparent: true
          layers: ['smo5_1vyd_sm5']
    layers =
      L.tileLayer do
        * 'https://samizdat.cz/proxy/cuzk_orto/WMTS_ORTOFOTO/service.svc/get?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=orto&STYLE=default&TILEMATRIXSET=jtsk%3Aepsg%3A102067&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&FORMAT=image%2Fjpeg'
        * attribution: "Ortofoto ČR © <a href='http://www.cuzk.cz/' target='_blank'>ČUZK</a>"
      L.tileLayer do
        * 'https://samizdat.cz/proxy/cuzk_geo//WMTS_ZM/service.svc/get?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=zm&STYLE=default&TILEMATRIXSET=jtsk%3Aepsg%3A102067&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&FORMAT=image%2Fjpeg'
        * attribution: "Základní mapy ČR © <a href='http://www.cuzk.cz/' target='_blank'>ČUZK</a>"
      mapGroup
    layersAssoc =
      "Ortofotomapa současnost": layers.0
      "Mapa současnost": layers.1
      "Mapa 50. léta (pouze oblast Slap)": layers.2
    map.addLayer layers.0
  else
    layers =
      L.tileLayer do
        * 'https://samizdat.cz/proxy/gov_geoportal/ArcGIS/rest/services/CENIA/cenia_rt_ortofotomapa_historicka/MapServer/tile/{z}/{y}/{x}?token=WzhTU6WUdzsTdgrVaNjNnJhgdYMRdL3fsGG9CpK72sIAAPg6WLlHsh4nSw72pvQb'
        * attribution: "Historická ortofotomapa © <a href='http://www.cenia.cz/' target='_blank'>CENIA</a> 2010 a <a href='http://www.geodis.cz/' target='_blank'>GEODIS BRNO, spol. s r.o.</a> 2010, Podkladové letecké snímky poskytl <a href='http://www.geoservice.army.cz/' target='_blank'>VGHMÚř Dobruška</a>, © MO ČR 2009"
      ...
    layersAssoc =
      "Ortofotomapa 50. léta": layers.0
    map.addLayer layers.0

  map.addControl L.control.layers layersAssoc, {}, collapsed: no unless i
  map

sync ...maps

window.onhashchange = ->
  return if manualHash
  [lat, lon, zoom] = location.hash.substr 1 .split /[^-\.0-9]+/
  lat = parseFloat lat
  lon = parseFloat lon
  zoom = parseFloat zoom
  if lat and lon and zoom >= 0
    maps.0
      ..setView [lat, lon], zoom
      ..fire \drag
shareArea = document.createElement \div
  ..id = "shareArea"
  ..className = ''
  ..innerHTML = "Odkaz ke sdílení
  <a href='#' class='close'>Zavřít</a>
  <input type='text'>
  <a class='social' target='_blank' href='https://www.facebook.com/sharer/sharer.php?u='><img src='https://samizdat.cz/tools/icons/facebook.png' alt='Sdílet na Facebooku' /></a>
  <a class='social' target='_blank' href=''><img src='https://samizdat.cz/tools/icons/twitter.png' alt='Sdílet na Twitteru' /></a>
  "
shareArea.querySelector "a.close" .onclick = -> shareArea.className = ""
shareBtn = document.createElement \a
  ..innerHTML = "Sdílet odkaz na toto místo"
  ..id = "shareBtn"
  ..onclick = (evt) ->
    evt.preventDefault!
    shareArea.className = "visible"
    center = maps.0.getCenter!
    ref = referrer + '#' + "#{center.lat.toFixed 4},#{center.lng.toFixed 4},#{maps.0.getZoom!}"
    refSoc = ref.replace '#' '%23'
    shareArea.querySelector "input"
      ..value = ref
      ..focus!
      ..setSelectionRange 0, ref.length
    for elm, index in shareArea.querySelectorAll ".social"
      elm.href = unless index
         "https://www.facebook.com/sharer/sharer.php?u=" + refSoc
      else
        "https://twitter.com/home?status=" + refSoc + " // @dataRozhlas"
ig.containers.base
  ..appendChild shareBtn
  ..appendChild shareArea

geocoder = null
form = document.createElement \form
  ..id = "frm-geocode"
label = document.createElement \label
  ..innerHTML = "Najít místo"
inputs = document.createElement \div
  ..className = "inputs"

inputText = document.createElement \input
  ..type = \text
  ..setAttribute? \placeholder "Vinohradská 12"
inputButton = document.createElement \input
  ..type = \submit
  ..value = "Najít"
inputs
  ..appendChild inputText
  ..appendChild inputButton

form
  ..appendChild label
  ..appendChild inputs
  ..addEventListener \submit (evt) ->
    evt.preventDefault!
    geocoder := new google.maps.Geocoder! if not geocoder
    address = inputText.value
    bounds = new google.maps.LatLngBounds do
      new google.maps.LatLng 48.3 11.6
      new google.maps.LatLng 51.3 19.1
    address += ", Česká republika"
    (results, status) <~ geocoder.geocode {address, bounds}
    if status != google.maps.GeocoderStatus.OK or !results.length
      alert "Bohužel, danou adresu nebylo možné najít"
      return
    result = results.0
    latlng = [result.geometry.location.lat!, result.geometry.location.lng!]
    maps.0.setView latlng, 11
    maps.1.setView latlng, 11

ig.containers.base
  ..appendChild form
