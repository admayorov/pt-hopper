# pt-hopper

## Plan - v0.1
- Nextjs react frontend
- Map view
    - All stops as icons
    - Tap on icon to see scheduled next trips - GTFS only


## Prerequisites
- sqlite3 (if not already installed)
- go
- tippecanoe (https://github.com/mapbox/tippecanoe.git)

## Steps to load
1. Download https://data.ptv.vic.gov.au/downloads/gtfs.zip
2. Extract gtfs.zip into `local/gtfs/` and then run unzip_gtfs.sh to unzip the rest
3. Create DB file `sqlite3 local/gtfs/gtfs.db < gtfs/load_gtfs.sql`
4. Run prepare.go (ensure `local/map` directory exists)
5. Run gen_stops_pmtiles.sh to create the pmtiles object with all the stop data
    
## PTV Stops tileset generation
```
cd backend/local
tippecanoe -zg -f -o map/ptv_stops.mbtiles map/ptv_stops.json
./pmtiles convert map/ptv_stops.mbtiles map/ptv_stops.pmtiles
```