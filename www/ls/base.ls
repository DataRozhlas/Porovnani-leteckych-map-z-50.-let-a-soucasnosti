diff =
  50.0994878082588 - 50.09333513996532
  14.441656813751825 - 14.37241038890274

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
  mapSlave.on \baselayerchange ({layer}) ->
    if layer.options.diff
      diff := that
    else
      diff := [0, 0]
    {lat, lng} = mapMaster.getCenter!
    center = [lat, lng]
    center.0 -= diff.0
    center.1 -= diff.1
    zoom = mapMaster.getZoom!
    mapSlave.setView center, zoom, animate: no

res = resolutions: [0 to 13].map -> 2048.256 / (2 ** it)
crs = new L.Proj.CRS.TMS do
  * "EPSG:102067"
  * "+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=30.28813975277778 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +units=m no_defs"
  * [-925000.000000000000 -1444353.535999999800 -400646.464000000040 -920000.000000000000]
  * res
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
      crs: crs
  map.on \click -> window.location.hash = "#{it.latlng.lat},#{it.latlng.lng},#{map.getZoom!}"
  if i is 0
    layers =
      L.tileLayer do
        * 'https://samizdat.cz/proxy/cuzk_orto/WMTS_ORTOFOTO/service.svc/get?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=orto&STYLE=default&TILEMATRIXSET=jtsk%3Aepsg%3A102067&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&FORMAT=image%2Fjpeg'
        * attribution: "Ortofoto ČR © <a href='http://www.cuzk.cz/' target='_blank'>ČUZK</a>"
      L.tileLayer do
        * 'https://samizdat.cz/proxy/cuzk_geo//WMTS_ZM/service.svc/get?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=zm&STYLE=default&TILEMATRIXSET=jtsk%3Aepsg%3A102067&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&FORMAT=image%2Fjpeg'
        * attribution: "Základní mapy ČR © <a href='http://www.cuzk.cz/' target='_blank'>ČUZK</a>"
    layersAssoc =
      "Ortofotomapa současnost": layers.0
      "Mapa současnost": layers.1
    map.addLayer layers.0
  else
    layers =
      L.tileLayer do
        * 'https://samizdat.cz/proxy/gov_geoportal/ArcGIS/rest/services/CENIA/cenia_rt_ortofotomapa_historicka/MapServer/tile/{z}/{y}/{x}?token=WzhTU6WUdzsTdgrVaNjNnJhgdYMRdL3fsGG9CpK72sIAAPg6WLlHsh4nSw72pvQb'
        * attribution: "Historická ortofotomapa © <a href='http://www.cenia.cz/' target='_blank'>CENIA</a> 2010 a <a href='http://www.geodis.cz/' target='_blank'>GEODIS BRNO, spol. s r.o.</a> 2010, Podkladové letecké snímky poskytl <a href='http://www.geoservice.army.cz/' target='_blank'>VGHMÚř Dobruška</a>, © MO ČR 2009"
          diff:
            50.0994878082588 - 50.09333513996532
            14.441656813751825 - 14.37241038890274
      L.tileLayer.wms do
        * 'https://samizdat.cz/proxy/cuzk_archiv/cgi-bin/mapserv.exe?projection=EPSG:102067&srs=EPSG:102067&map=e:/wwwdata/main/cio_main_wms_05.map'
        * format: 'jpeg',
          layers: ['smo5_1vyd_sm5']
    layersAssoc =
      "Ortofotomapa 50. léta": layers.0
      "Mapa 50. léta": layers.1
    map.addLayer layers.0

  map.addControl L.control.layers layersAssoc, {}, collapsed: no
  map

sync ...maps
if document.getElementById 'fallback'
  that.parentNode.removeChild that
