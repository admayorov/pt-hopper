# pt-hopper

## Plan - v0.1
- Nextjs react frontend
- Map view
    - All stops as icons
    - Tap on icon to see scheduled next trips - GTFS only
    
## PTV Stops tileset generation
```
cd backend/local
tippecanoe -zg -f -o map/ptv_stops.mbtiles map/ptv_stops.json
./pmtiles convert map/ptv_stops.mbtiles map/ptv_stops.pmtiles
```