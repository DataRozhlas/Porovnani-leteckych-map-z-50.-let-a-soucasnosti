# Porovnání map leteckých map z 50. let a současnosti

Celý článek na webu Rozhlasu: [Jesenice u Prahy je jednou z nejzastavěnějších obcí. Nezbyla ani náves](http://www.rozhlas.cz/zpravy/data/_zprava/jesenice-u-prahy-je-jednou-z-nejzastavenejsich-obci-nezbyla-ani-naves--1422901)

> Projekt [datové rubriky Českého rozhlasu](http://www.rozhlas.cz/zpravy/data/). Uvolněno pod licencí [CC BY-NC-SA 3.0 CZ](http://creativecommons.org/licenses/by-nc-sa/3.0/cz/), tedy uveďte autora, nevyužívejte dílo ani přidružená data komerčně a zachovejte licenci.

Využívá knihovny [Proj4Leaflet](https://github.com/kartena/Proj4Leaflet) ke konverzi z EPSG 5514 (Křovák) do WebMercatora. Zdrojové kódy jak toho dosáhnout jsou v `ls/base.ls`, ve zkratce zde:
```LiveScript
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

# ...

map = L.map do
  * elm
  * zoom: zoom
    maxZoom: 13
    center: center
    inertia: no
    zoomControl: !i
    crs: if i then crs2 else crs
```

Dvě různé projekce jsou na mapy z ČÚZK (obecná i současná fotomapa) a na historickou mapu z CENIA, která má oproti ČÚZK posunutý začátek.

## Instalace

    npm install -g LiveScript@1.2.0
    npm install
    slake deploy

Hlavní stránka je v www/index.html
