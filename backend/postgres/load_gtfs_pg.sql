-- Postgres

DROP TABLE IF EXISTS calendar_dates;
DROP TABLE IF EXISTS calendar;
DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS stop_times;
DROP TABLE IF EXISTS stops;
DROP TABLE IF EXISTS trips;


-- CALENDAR_DATES
CREATE TABLE calendar_dates (
    "mode" TEXT,
    "service_id" TEXT,
    "date" DATE,
    "exception_type" SMALLINT
);

ALTER TABLE calendar_dates ALTER COLUMN mode SET DEFAULT 'vline';
\COPY calendar_dates(service_id,date,exception_type) FROM 'backend/local/gtfs/1/calendar_dates.txt' WITH CSV HEADER;

ALTER TABLE calendar_dates ALTER COLUMN mode SET DEFAULT 'metro';
\COPY calendar_dates(service_id,date,exception_type) FROM 'backend/local/gtfs/2/calendar_dates.txt' WITH CSV HEADER;

ALTER TABLE calendar_dates ALTER COLUMN mode SET DEFAULT 'tram';
\COPY calendar_dates(service_id,date,exception_type) FROM 'backend/local/gtfs/3/calendar_dates.txt' WITH CSV HEADER;

ALTER TABLE calendar_dates ALTER COLUMN mode SET DEFAULT 'bus';
\COPY calendar_dates(service_id,date,exception_type) FROM 'backend/local/gtfs/4/calendar_dates.txt' WITH CSV HEADER;

ALTER TABLE calendar_dates ALTER COLUMN mode DROP DEFAULT;



-- CALENDAR
CREATE TABLE calendar (
    mode TEXT,
    service_id TEXT,
    monday SMALLINT,
    tuesday SMALLINT,
    wednesday SMALLINT,
    thursday SMALLINT,
    friday SMALLINT,
    saturday SMALLINT,
    sunday SMALLINT,
    start_date DATE,
    end_date DATE
);


ALTER TABLE calendar ALTER COLUMN mode SET DEFAULT 'vline';
\COPY calendar(service_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_date, end_date) FROM 'backend/local/gtfs/1/calendar.txt' WITH CSV HEADER;

ALTER TABLE calendar ALTER COLUMN mode SET DEFAULT 'metro';
\COPY calendar(service_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_date, end_date) FROM 'backend/local/gtfs/2/calendar.txt' WITH CSV HEADER;

ALTER TABLE calendar ALTER COLUMN mode SET DEFAULT 'tram';
\COPY calendar(service_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_date, end_date) FROM 'backend/local/gtfs/3/calendar.txt' WITH CSV HEADER;

ALTER TABLE calendar ALTER COLUMN mode SET DEFAULT 'bus';
\COPY calendar(service_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_date, end_date) FROM 'backend/local/gtfs/4/calendar.txt' WITH CSV HEADER;

ALTER TABLE calendar ALTER COLUMN mode DROP DEFAULT;



-- ROUTES
CREATE TABLE routes (
  mode TEXT,
  route_id TEXT,
  agency_id TEXT,
  route_short_name TEXT,
  route_long_name TEXT,
  route_type TEXT,
  route_color TEXT,
  route_text_color TEXT,
  route_api_id TEXT
);

ALTER TABLE routes ALTER COLUMN mode SET DEFAULT 'vline';
\COPY routes(route_id, agency_id, route_short_name, route_long_name, route_type, route_color, route_text_color) FROM 'backend/local/gtfs/1/routes.txt' WITH CSV HEADER;

ALTER TABLE routes ALTER COLUMN mode SET DEFAULT 'metro';
\COPY routes(route_id, agency_id, route_short_name, route_long_name, route_type, route_color, route_text_color) FROM 'backend/local/gtfs/2/routes.txt' WITH CSV HEADER;

ALTER TABLE routes ALTER COLUMN mode SET DEFAULT 'tram';
\COPY routes(route_id, agency_id, route_short_name, route_long_name, route_type, route_color, route_text_color) FROM 'backend/local/gtfs/3/routes.txt' WITH CSV HEADER;

ALTER TABLE routes ALTER COLUMN mode SET DEFAULT 'bus';
\COPY routes(route_id, agency_id, route_short_name, route_long_name, route_type, route_color, route_text_color) FROM 'backend/local/gtfs/4/routes.txt' WITH CSV HEADER;

ALTER TABLE routes ALTER COLUMN mode DROP DEFAULT;



-- STOP_TIMES
CREATE TABLE stop_times (
  mode TEXT,
  trip_id TEXT,
  arrival_time TEXT,
  departure_time TEXT,
  stop_id TEXT,
  stop_sequence SMALLINT,
  stop_headsign TEXT,
  pickup_type SMALLINT,
  drop_off_type SMALLINT,
  shape_dist_traveled TEXT  -- should be numeric but the CSVs have empty values which breaks \COPY import
);

ALTER TABLE stop_times ALTER COLUMN mode SET DEFAULT 'vline';
\COPY stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled) FROM 'backend/local/gtfs/1/stop_times.txt' WITH CSV HEADER;

ALTER TABLE stop_times ALTER COLUMN mode SET DEFAULT 'metro';
\COPY stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled) FROM 'backend/local/gtfs/2/stop_times.txt' WITH CSV HEADER;

ALTER TABLE stop_times ALTER COLUMN mode SET DEFAULT 'tram';
\COPY stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled) FROM 'backend/local/gtfs/3/stop_times.txt' WITH CSV HEADER;

ALTER TABLE stop_times ALTER COLUMN mode SET DEFAULT 'bus';
\COPY stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled) FROM 'backend/local/gtfs/4/stop_times.txt' WITH CSV HEADER;

ALTER TABLE stop_times ALTER COLUMN mode DROP DEFAULT;



-- STOPS
CREATE TABLE stops (
  mode TEXT,
  stop_id TEXT,
  stop_name TEXT,
  stop_lat DECIMAL,
  stop_lon DECIMAL
);

ALTER TABLE stops ALTER COLUMN mode SET DEFAULT 'vline';
\COPY stops(stop_id,stop_name,stop_lat,stop_lon) FROM 'backend/local/gtfs/1/stops.txt' WITH CSV HEADER;

ALTER TABLE stops ALTER COLUMN mode SET DEFAULT 'metro';
\COPY stops(stop_id,stop_name,stop_lat,stop_lon) FROM 'backend/local/gtfs/2/stops.txt' WITH CSV HEADER;

ALTER TABLE stops ALTER COLUMN mode SET DEFAULT 'tram';
\COPY stops(stop_id,stop_name,stop_lat,stop_lon) FROM 'backend/local/gtfs/3/stops.txt' WITH CSV HEADER;

ALTER TABLE stops ALTER COLUMN mode SET DEFAULT 'bus';
\COPY stops(stop_id,stop_name,stop_lat,stop_lon) FROM 'backend/local/gtfs/4/stops.txt' WITH CSV HEADER;

ALTER TABLE stops ALTER COLUMN mode DROP DEFAULT;



-- TRIPS
CREATE TABLE trips (
  mode TEXT,
  route_id TEXT,
  service_id TEXT,
  trip_id TEXT,
  shape_id TEXT,
  trip_headsign TEXT,
  direction_id SMALLINT
);

ALTER TABLE trips ALTER COLUMN mode SET DEFAULT 'vline';
\COPY trips(route_id,service_id,trip_id,shape_id,trip_headsign,direction_id) FROM 'backend/local/gtfs/1/trips.txt' WITH CSV HEADER;

ALTER TABLE trips ALTER COLUMN mode SET DEFAULT 'metro';
\COPY trips(route_id,service_id,trip_id,shape_id,trip_headsign,direction_id) FROM 'backend/local/gtfs/2/trips.txt' WITH CSV HEADER;

ALTER TABLE trips ALTER COLUMN mode SET DEFAULT 'tram';
\COPY trips(route_id,service_id,trip_id,shape_id,trip_headsign,direction_id) FROM 'backend/local/gtfs/3/trips.txt' WITH CSV HEADER;

ALTER TABLE trips ALTER COLUMN mode SET DEFAULT 'bus';
\COPY trips(route_id,service_id,trip_id,shape_id,trip_headsign,direction_id) FROM 'backend/local/gtfs/4/trips.txt' WITH CSV HEADER;

ALTER TABLE trips ALTER COLUMN mode DROP DEFAULT;


CREATE INDEX idx_calendar_dates_date ON calendar_dates(date);
CREATE INDEX idx_calendar_service_id ON calendar(service_id);
CREATE INDEX idx_routes_route_id ON routes(route_id);
CREATE INDEX idx_stop_times_stop_id ON stop_times(stop_id);
CREATE INDEX idx_stop_times_trip_id ON stop_times(trip_id);
CREATE INDEX idx_stops_stop_id ON stops(stop_id);
CREATE INDEX idx_trips_trip_id ON trips(trip_id);
CREATE INDEX idx_trips_route_id ON trips(route_id);
CREATE INDEX idx_trips_service_id ON trips(service_id);

