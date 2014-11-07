sync = (mapMaster, mapSlave) ->
  mapMaster.on "drag" ->
    {lat, lng} = mapMaster.getCenter!
    center = [lat, lng]
    center.0 -= diff.0
    center.1 -= diff.1
    zoom = mapMaster.getZoom!
    mapSlave.setView center, zoom, animate: no

  mapSlave.on "drag" ->
    {lat, lng} = mapSlave.getCenter!
    center = [lat, lng]
    center.0 += diff.0
    center.1 += diff.1
    zoom = mapSlave.getZoom!
    mapMaster.setView center, zoom, animate: no

  mapMaster.on \zoomstart (evt) ->
    <~ setImmediate
    return if mapMaster.getZoom! == evt.target._animateToZoom
    {lat, lng} = evt.target._animateToCenter
    center = [lat, lng]
    center.0 -= diff.0
    center.1 -= diff.1
    mapSlave.setView center, evt.target._animateToZoom

  mapSlave.on \zoomstart (evt) ->
    <~ setImmediate
    return if mapSlave.getZoom! == evt.target._animateToZoom
    {lat, lng} = evt.target._animateToCenter
    center = [lat, lng]
    center.0 += diff.0
    center.1 += diff.1
    mapMaster.setView center, evt.target._animateToZoom
diff =
  0
  -53.865108489990234 - -57.298164367675774

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
    [59.95, -57.30]
  if i
    center.0 -= diff.0
    center.1 -= diff.1
  map = L.map do
    * elm
    * zoom: zoom
      maxZoom: 13
      center: center
      inertia: no
      zoomControl: !i
  map.on \click -> window.location.hash = "#{it.latlng.lat},#{it.latlng.lng},#{map.getZoom!}"
  if i is 0
    layers =
      L.tileLayer do
        * 'http://geoportal-orto3.cuzk.cz/WMTS_ORTOFOTO/service.svc/get?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=orto&STYLE=default&TILEMATRIXSET=jtsk%3Aepsg%3A102067&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&FORMAT=image%2Fjpeg'
        * attribution: "Ortofoto ČR © <a href='http://www.cuzk.cz/' target='_blank'>ČUZK</a>"
      L.tileLayer do
        * 'http://geoportal-zm2.cuzk.cz/WMTS_ZM/service.svc/get?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=zm&STYLE=default&TILEMATRIXSET=jtsk%3Aepsg%3A102067&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&FORMAT=image%2Fjpeg'
        * attribution: "Základní mapy ČR © <a href='http://www.cuzk.cz/' target='_blank'>ČUZK</a>"
    layersAssoc =
      "Ortofotomapa současnost": layers.0
      "Mapa současnost": layers.1
    map.addLayer layers.0
  else
    layers =
      L.tileLayer do
        * 'https://geoportal.gov.cz/ArcGIS/rest/services/CENIA/cenia_rt_ortofotomapa_historicka/MapServer/tile/{z}/{y}/{x}?token=WzhTU6WUdzsTdgrVaNjNnJhgdYMRdL3fsGG9CpK72sIAAPg6WLlHsh4nSw72pvQb'
        * attribution: "Historická ortofotomapa © <a href='http://www.cenia.cz/' target='_blank'>CENIA</a> 2010 a <a href='http://www.geodis.cz/' target='_blank'>GEODIS BRNO, spol. s r.o.</a> 2010, Podkladové letecké snímky poskytl <a href='http://www.geoservice.army.cz/' target='_blank'>VGHMÚř Dobruška</a>, © MO ČR 2009"
      L.tileLayer do
        * 'https://tiles.arcgis.com/tiles/h9E2wwIZUacHyhVE/arcgis/rest/services/slapy-smo5/MapServer/tile/{z}/{y}/{x}'
        * attribution: "Podkladová data SMO5 © <a href='http://www.cuzk.cz/' target='_blank'>ČUZK</a>"
    layersAssoc =
      "Ortofotomapa 50. léta": layers.0
      "Mapa 50. léta": layers.0
    map.addLayer layers.0
  if not i
    map.addControl L.control.layers layersAssoc, {}, collapsed: no
  map

sync ...maps
if document.getElementById 'fallback'
  that.parentNode.removeChild that
