-- SQLite
-- Usage: sqlite3 local/gtfs/gtfs.db < gtfs/load_gtfs.sql

.echo on 

BEGIN;

DROP TABLE IF EXISTS stg_vline_calendar_dates;
DROP TABLE IF EXISTS stg_vline_calendar;
DROP TABLE IF EXISTS stg_vline_routes;
-- DROP TABLE IF EXISTS stg_vline_shapes;
DROP TABLE IF EXISTS stg_vline_stop_times;
DROP TABLE IF EXISTS stg_vline_stops;
DROP TABLE IF EXISTS stg_vline_trips;

DROP TABLE IF EXISTS stg_metro_calendar_dates;
DROP TABLE IF EXISTS stg_metro_calendar;
DROP TABLE IF EXISTS stg_metro_routes;
-- DROP TABLE IF EXISTS stg_metro_shapes;
DROP TABLE IF EXISTS stg_metro_stop_times;
DROP TABLE IF EXISTS stg_metro_stops;
DROP TABLE IF EXISTS stg_metro_trips;

DROP TABLE IF EXISTS stg_tram_calendar_dates;
DROP TABLE IF EXISTS stg_tram_calendar;
DROP TABLE IF EXISTS stg_tram_routes;
-- DROP TABLE IF EXISTS stg_tram_shapes;
DROP TABLE IF EXISTS stg_tram_stop_times;
DROP TABLE IF EXISTS stg_tram_stops;
DROP TABLE IF EXISTS stg_tram_trips;

DROP TABLE IF EXISTS stg_bus_calendar_dates;
DROP TABLE IF EXISTS stg_bus_calendar;
DROP TABLE IF EXISTS stg_bus_routes;
-- DROP TABLE IF EXISTS stg_bus_shapes;
DROP TABLE IF EXISTS stg_bus_stop_times;
DROP TABLE IF EXISTS stg_bus_stops;
DROP TABLE IF EXISTS stg_bus_trips;

DROP TABLE IF EXISTS calendar_dates;
DROP TABLE IF EXISTS calendar;
DROP TABLE IF EXISTS routes;
-- DROP TABLE IF EXISTS shapes;
DROP TABLE IF EXISTS stop_times;
DROP TABLE IF EXISTS stops;
DROP TABLE IF EXISTS trips;

.mode csv

.import local/gtfs/1/calendar_dates.txt stg_vline_calendar_dates
.import local/gtfs/1/calendar.txt       stg_vline_calendar
.import local/gtfs/1/routes.txt         stg_vline_routes
-- .import local/gtfs/1/shapes.txt         stg_vline_shapes
.import local/gtfs/1/stop_times.txt     stg_vline_stop_times
.import local/gtfs/1/stops.txt          stg_vline_stops
.import local/gtfs/1/trips.txt          stg_vline_trips

.import local/gtfs/2/calendar_dates.txt stg_metro_calendar_dates
.import local/gtfs/2/calendar.txt       stg_metro_calendar
.import local/gtfs/2/routes.txt         stg_metro_routes
-- .import local/gtfs/2/shapes.txt         stg_metro_shapes
.import local/gtfs/2/stop_times.txt     stg_metro_stop_times
.import local/gtfs/2/stops.txt          stg_metro_stops
.import local/gtfs/2/trips.txt          stg_metro_trips

.import local/gtfs/3/calendar_dates.txt stg_tram_calendar_dates
.import local/gtfs/3/calendar.txt       stg_tram_calendar
.import local/gtfs/3/routes.txt         stg_tram_routes
-- .import local/gtfs/3/shapes.txt         stg_tram_shapes
.import local/gtfs/3/stop_times.txt     stg_tram_stop_times
.import local/gtfs/3/stops.txt          stg_tram_stops
.import local/gtfs/3/trips.txt          stg_tram_trips

.import local/gtfs/4/calendar_dates.txt stg_bus_calendar_dates
.import local/gtfs/4/calendar.txt       stg_bus_calendar
.import local/gtfs/4/routes.txt         stg_bus_routes
-- .import local/gtfs/4/shapes.txt         stg_bus_shapes
.import local/gtfs/4/stop_times.txt     stg_bus_stop_times
.import local/gtfs/4/stops.txt          stg_bus_stops
.import local/gtfs/4/trips.txt          stg_bus_trips


-- CALENDAR_DATES
CREATE TABLE calendar_dates (
    "mode" TEXT,
    "service_id" TEXT,
    "date" TEXT,
    "exception_type" TEXT
);
INSERT INTO calendar_dates
    select "vline", * from stg_vline_calendar_dates union all
    select "metro", * from stg_metro_calendar_dates union all
    select "tram", * from stg_tram_calendar_dates union all
    select "bus", * from stg_bus_calendar_dates;

CREATE INDEX idx_calendar_dates_date ON calendar_dates(date);


-- CALENDAR
CREATE TABLE calendar (
    "mode" TEXT,
    "service_id" TEXT,
    "monday" TEXT,
    "tuesday" TEXT,
    "wednesday" TEXT,
    "thursday" TEXT,
    "friday" TEXT,
    "saturday" TEXT,
    "sunday" TEXT,
    "start_date" TEXT,
    "end_date" TEXT
);
INSERT INTO calendar
    select "vline", * from stg_vline_calendar union all
    select "metro", * from stg_metro_calendar union all
    select "tram", * from stg_tram_calendar union all
    select "bus", * from stg_bus_calendar;

CREATE INDEX idx_calendar_service_id ON calendar(service_id);


-- ROUTES
CREATE TABLE routes (
  "mode" TEXT,
  "route_id" TEXT,
  "agency_id" TEXT,
  "route_short_name" TEXT,
  "route_long_name" TEXT,
  "route_type" TEXT,
  "route_color" TEXT,
  "route_text_color" TEXT,
  "route_api_id" TEXT
);
INSERT INTO routes
    select "vline", route_id, agency_id, route_short_name, route_long_name, route_type, route_color, route_text_color, NULL from stg_vline_routes
    union all
    select "metro", route_id, agency_id, route_short_name, route_long_name, route_type, route_color, route_text_color, NULL from stg_metro_routes
    union all
    select "tram", route_id, agency_id, route_short_name, route_long_name, route_type, route_color, route_text_color, NULL from stg_tram_routes
    union all
    select "bus", route_id, agency_id, route_short_name, route_long_name, route_type, route_color, route_text_color, NULL from stg_bus_routes;

CREATE INDEX idx_routes_route_id ON routes(route_id);


-- -- SHAPES
-- CREATE TABLE shapes (
--   "mode" TEXT,
--   "shape_id" TEXT,
--   "shape_pt_lat" TEXT,
--   "shape_pt_lon" TEXT,
--   "shape_pt_sequence" TEXT,
--   "shape_dist_traveled" TEXT
-- );
-- INSERT INTO shapes
    -- select "vline", * from stg_vline_shapes union all
    -- select "metro", * from stg_metro_shapes union all
    -- select "tram", * from stg_tram_shapes union all
    -- select "bus", * from stg_bus_shapes;


-- STOP_TIMES
CREATE TABLE stop_times (
  "mode" TEXT,
  "trip_id" TEXT,
  "arrival_time" TEXT,
  "departure_time" TEXT,
  "stop_id" TEXT,
  "stop_sequence" TEXT,
  "stop_headsign" TEXT,
  "pickup_type" TEXT,
  "drop_off_type" TEXT,
  "shape_dist_traveled" TEXT
);
INSERT INTO stop_times
    select "vline", * from stg_vline_stop_times union all
    select "metro", * from stg_metro_stop_times union all
    select "tram", * from stg_tram_stop_times union all
    select "bus", * from stg_bus_stop_times;

CREATE INDEX idx_stop_times_stop_id ON stop_times(stop_id);
CREATE INDEX idx_stop_times_trip_id ON stop_times(trip_id);


-- STOPS
CREATE TABLE stops (
  "mode" TEXT,
  "stop_id" TEXT,
  "stop_name" TEXT,
  "stop_short_name" TEXT,
  "stop_road_name" TEXT,
  "stop_suburb" TEXT,
  "stop_lat" TEXT,
  "stop_lon" TEXT
);
INSERT INTO stops (mode, stop_id, stop_name, stop_lat, stop_lon)
    select "vline", stop_id, stop_name, stop_lat, stop_lon from stg_vline_stops union all
    select "metro", stop_id, stop_name, stop_lat, stop_lon from stg_metro_stops union all
    select "tram", stop_id, stop_name, stop_lat, stop_lon from stg_tram_stops union all
    select "bus", stop_id, stop_name, stop_lat, stop_lon from stg_bus_stops;

CREATE INDEX idx_stops_stop_id ON stops(stop_id);



-- TRIPS
CREATE TABLE trips (
  "mode" TEXT,
  "route_id" TEXT,
  "service_id" TEXT,
  "trip_id" TEXT,
  "shape_id" TEXT,
  "trip_headsign" TEXT,
  "direction_id" TEXT
);
INSERT INTO trips
    select "vline", * from stg_vline_trips union all
    select "metro", * from stg_metro_trips union all
    select "tram", * from stg_tram_trips union all
    select "bus", * from stg_bus_trips;

CREATE INDEX idx_trips_trip_id ON trips(trip_id);
CREATE INDEX idx_trips_route_id ON trips(route_id);
CREATE INDEX idx_trips_service_id ON trips(service_id);


DROP TABLE IF EXISTS stg_vline_calendar_dates;
DROP TABLE IF EXISTS stg_vline_calendar;
DROP TABLE IF EXISTS stg_vline_routes;
-- DROP TABLE IF EXISTS stg_vline_shapes;
DROP TABLE IF EXISTS stg_vline_stop_times;
DROP TABLE IF EXISTS stg_vline_stops;
DROP TABLE IF EXISTS stg_vline_trips;

DROP TABLE IF EXISTS stg_metro_calendar_dates;
DROP TABLE IF EXISTS stg_metro_calendar;
DROP TABLE IF EXISTS stg_metro_routes;
-- DROP TABLE IF EXISTS stg_metro_shapes;
DROP TABLE IF EXISTS stg_metro_stop_times;
DROP TABLE IF EXISTS stg_metro_stops;
DROP TABLE IF EXISTS stg_metro_trips;

DROP TABLE IF EXISTS stg_tram_calendar_dates;
DROP TABLE IF EXISTS stg_tram_calendar;
DROP TABLE IF EXISTS stg_tram_routes;
-- DROP TABLE IF EXISTS stg_tram_shapes;
DROP TABLE IF EXISTS stg_tram_stop_times;
DROP TABLE IF EXISTS stg_tram_stops;
DROP TABLE IF EXISTS stg_tram_trips;

DROP TABLE IF EXISTS stg_bus_calendar_dates;
DROP TABLE IF EXISTS stg_bus_calendar;
DROP TABLE IF EXISTS stg_bus_routes;
-- DROP TABLE IF EXISTS stg_bus_shapes;
DROP TABLE IF EXISTS stg_bus_stop_times;
DROP TABLE IF EXISTS stg_bus_stops;
DROP TABLE IF EXISTS stg_bus_trips;

COMMIT;

VACUUM;

.exit