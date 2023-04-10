#!/bin/bash
set -euo pipefail

cd local/

pwd

# Create the mbtiles file with the combined GeoJSON file as layers
tippecanoe -zg -rg -f -o map/ptv_stops.mbtiles -L vline:map/vline_stops.json -L metro:map/metro_stops.json -L tram:map/tram_stops.json -L bus:map/bus_stops.json

# Convert the mbtiles file to pmtiles format
./pmtiles convert map/ptv_stops.mbtiles map/ptv_stops.pmtiles
