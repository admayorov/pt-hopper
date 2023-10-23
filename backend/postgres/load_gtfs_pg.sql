-- Postgres

DROP TABLE IF EXISTS stg_calendar_dates;
DROP TABLE IF EXISTS stg_calendar;
DROP TABLE IF EXISTS stg_routes;
DROP TABLE IF EXISTS stg_stop_times;
DROP TABLE IF EXISTS stg_stops;
DROP TABLE IF EXISTS stg_trips;

DROP TABLE IF EXISTS calendar_dates;
DROP TABLE IF EXISTS calendar;
DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS stop_times;
DROP TABLE IF EXISTS stops;
DROP TABLE IF EXISTS trips;


-- CALENDAR_DATES
CREATE TEMPORARY TABLE stg_calendar_dates (
    mode TEXT,
    service_id TEXT,
    date TEXT,
    exception_type TEXT
);

ALTER TABLE stg_calendar_dates ALTER COLUMN mode SET DEFAULT 'vline';
\COPY stg_calendar_dates(service_id,date,exception_type) FROM 'backend/local/gtfs/1/calendar_dates.txt' WITH CSV HEADER;

ALTER TABLE stg_calendar_dates ALTER COLUMN mode SET DEFAULT 'metro';
\COPY stg_calendar_dates(service_id,date,exception_type) FROM 'backend/local/gtfs/2/calendar_dates.txt' WITH CSV HEADER;

ALTER TABLE stg_calendar_dates ALTER COLUMN mode SET DEFAULT 'tram';
\COPY stg_calendar_dates(service_id,date,exception_type) FROM 'backend/local/gtfs/3/calendar_dates.txt' WITH CSV HEADER;

ALTER TABLE stg_calendar_dates ALTER COLUMN mode SET DEFAULT 'bus';
\COPY stg_calendar_dates(service_id,date,exception_type) FROM 'backend/local/gtfs/4/calendar_dates.txt' WITH CSV HEADER;

ALTER TABLE stg_calendar_dates ALTER COLUMN mode DROP DEFAULT;

CREATE TABLE calendar_dates as (
  select
    mode::TEXT                as mode,
    service_id::TEXT          as service_id,
    date::DATE                as date,
    exception_type::SMALLINT  as exception_type 
  from stg_calendar_dates
);


-- CALENDAR
CREATE TEMPORARY TABLE stg_calendar (
    mode TEXT,
    service_id TEXT,
    monday TEXT,
    tuesday TEXT,
    wednesday TEXT,
    thursday TEXT,
    friday TEXT,
    saturday TEXT,
    sunday TEXT,
    start_date TEXT,
    end_date TEXT
);


ALTER TABLE stg_calendar ALTER COLUMN mode SET DEFAULT 'vline';
\COPY stg_calendar(service_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_date, end_date) FROM 'backend/local/gtfs/1/calendar.txt' WITH CSV HEADER;

ALTER TABLE stg_calendar ALTER COLUMN mode SET DEFAULT 'metro';
\COPY stg_calendar(service_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_date, end_date) FROM 'backend/local/gtfs/2/calendar.txt' WITH CSV HEADER;

ALTER TABLE stg_calendar ALTER COLUMN mode SET DEFAULT 'tram';
\COPY stg_calendar(service_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_date, end_date) FROM 'backend/local/gtfs/3/calendar.txt' WITH CSV HEADER;

ALTER TABLE stg_calendar ALTER COLUMN mode SET DEFAULT 'bus';
\COPY stg_calendar(service_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_date, end_date) FROM 'backend/local/gtfs/4/calendar.txt' WITH CSV HEADER;

ALTER TABLE stg_calendar ALTER COLUMN mode DROP DEFAULT;

CREATE TABLE calendar as (
  select
      mode::TEXT           as mode,
      service_id::TEXT     as service_id,
      monday::SMALLINT     as monday,
      tuesday::SMALLINT    as tuesday,
      wednesday::SMALLINT  as wednesday,
      thursday::SMALLINT   as thursday,
      friday::SMALLINT     as friday,
      saturday::SMALLINT   as saturday,
      sunday::SMALLINT     as sunday,
      start_date::DATE     as start_date,
      end_date::DATE       as end_date 
  from stg_calendar
);



-- ROUTES
CREATE TEMPORARY TABLE stg_routes (
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

ALTER TABLE stg_routes ALTER COLUMN mode SET DEFAULT 'vline';
\COPY stg_routes(route_id, agency_id, route_short_name, route_long_name, route_type, route_color, route_text_color) FROM 'backend/local/gtfs/1/routes.txt' WITH CSV HEADER;

ALTER TABLE stg_routes ALTER COLUMN mode SET DEFAULT 'metro';
\COPY stg_routes(route_id, agency_id, route_short_name, route_long_name, route_type, route_color, route_text_color) FROM 'backend/local/gtfs/2/routes.txt' WITH CSV HEADER;

ALTER TABLE stg_routes ALTER COLUMN mode SET DEFAULT 'tram';
\COPY stg_routes(route_id, agency_id, route_short_name, route_long_name, route_type, route_color, route_text_color) FROM 'backend/local/gtfs/3/routes.txt' WITH CSV HEADER;

ALTER TABLE stg_routes ALTER COLUMN mode SET DEFAULT 'bus';
\COPY stg_routes(route_id, agency_id, route_short_name, route_long_name, route_type, route_color, route_text_color) FROM 'backend/local/gtfs/4/routes.txt' WITH CSV HEADER;

ALTER TABLE stg_routes ALTER COLUMN mode DROP DEFAULT;

CREATE TABLE routes as (
  select
    mode::TEXT              as mode,
    route_id::TEXT          as route_id,
    agency_id::TEXT         as agency_id,
    route_short_name::TEXT  as route_short_name,
    route_long_name::TEXT   as route_long_name,
    route_type::TEXT        as route_type,
    route_color::TEXT       as route_color,
    route_text_color::TEXT  as route_text_color,
    route_api_id::TEXT      as route_api_id 
  from stg_routes
);



-- STOP_TIMES
CREATE TEMPORARY TABLE stg_stop_times (
  mode TEXT,
  trip_id TEXT,
  arrival_time TEXT,
  departure_time TEXT,
  stop_id TEXT,
  stop_sequence TEXT,
  stop_headsign TEXT,
  pickup_type TEXT,
  drop_off_type TEXT,
  shape_dist_traveled TEXT  -- should be numeric but the CSVs have empty values which breaks \COPY stg_import
);

ALTER TABLE stg_stop_times ALTER COLUMN mode SET DEFAULT 'vline';
\COPY stg_stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled) FROM 'backend/local/gtfs/1/stop_times.txt' WITH CSV HEADER;

ALTER TABLE stg_stop_times ALTER COLUMN mode SET DEFAULT 'metro';
\COPY stg_stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled) FROM 'backend/local/gtfs/2/stop_times.txt' WITH CSV HEADER;

ALTER TABLE stg_stop_times ALTER COLUMN mode SET DEFAULT 'tram';
\COPY stg_stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled) FROM 'backend/local/gtfs/3/stop_times.txt' WITH CSV HEADER;

ALTER TABLE stg_stop_times ALTER COLUMN mode SET DEFAULT 'bus';
\COPY stg_stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled) FROM 'backend/local/gtfs/4/stop_times.txt' WITH CSV HEADER;

ALTER TABLE stg_stop_times ALTER COLUMN mode DROP DEFAULT;

CREATE TABLE stop_times as (
  with stg_stop_times_split as (
    select
      *,
      SPLIT_PART(arrival_time, ':', 1)::NUMERIC    as arrival_hours,
      SPLIT_PART(arrival_time, ':', 2)::NUMERIC    as arrival_minutes,
      SPLIT_PART(arrival_time, ':', 3)::NUMERIC    as arrival_seconds,
      SPLIT_PART(departure_time, ':', 1)::NUMERIC  as departure_hours,
      SPLIT_PART(departure_time, ':', 2)::NUMERIC  as departure_minutes,
      SPLIT_PART(departure_time, ':', 3)::NUMERIC  as departure_seconds
    from stg_stop_times
  )

  select
    mode::TEXT                                                                  as mode,
    trip_id::TEXT                                                               as trip_id,
    (3600*arrival_hours + 60*arrival_minutes + arrival_seconds)::INTEGER        as arrival_time_int,
    (3600*departure_hours + 60*departure_minutes + departure_seconds)::INTEGER  as departure_time_int,
    stop_id::TEXT                                                               as stop_id,
    stop_sequence::SMALLINT                                                     as stop_sequence,
    stop_headsign::TEXT                                                         as stop_headsign,
    pickup_type::SMALLINT                                                       as pickup_type,
    drop_off_type::SMALLINT                                                     as drop_off_type,
    CASE
      WHEN COALESCE(shape_dist_traveled,'') = ''
      THEN 0
      ELSE shape_dist_traveled::NUMERIC
    END                                                                         as shape_dist_traveled 
  from stg_stop_times_split
);



-- STOPS
CREATE TEMPORARY TABLE stg_stops (
  mode TEXT,
  stop_id TEXT,
  stop_name TEXT,
  stop_lat TEXT,
  stop_lon TEXT
);

ALTER TABLE stg_stops ALTER COLUMN mode SET DEFAULT 'vline';
\COPY stg_stops(stop_id,stop_name,stop_lat,stop_lon) FROM 'backend/local/gtfs/1/stops.txt' WITH CSV HEADER;

ALTER TABLE stg_stops ALTER COLUMN mode SET DEFAULT 'metro';
\COPY stg_stops(stop_id,stop_name,stop_lat,stop_lon) FROM 'backend/local/gtfs/2/stops.txt' WITH CSV HEADER;

ALTER TABLE stg_stops ALTER COLUMN mode SET DEFAULT 'tram';
\COPY stg_stops(stop_id,stop_name,stop_lat,stop_lon) FROM 'backend/local/gtfs/3/stops.txt' WITH CSV HEADER;

ALTER TABLE stg_stops ALTER COLUMN mode SET DEFAULT 'bus';
\COPY stg_stops(stop_id,stop_name,stop_lat,stop_lon) FROM 'backend/local/gtfs/4/stops.txt' WITH CSV HEADER;

ALTER TABLE stg_stops ALTER COLUMN mode DROP DEFAULT;

CREATE TABLE stops as (
  with vline_metro as (
    select
      *,
      REGEXP_MATCHES(stop_name, '^(.+)\s+Railway Station\s*\((.+)\)') as stop_regex_array
    from stg_stops
    where mode = 'vline' or mode ='metro'
  )

  , tram as (
    select
      *,
      REGEXP_MATCHES(stop_name, '^([^-]+)-([^/]*)(?:/([^/]+(?:/[^/]+)*)\s)?\s*\(\s*([^\]]+)\s*\)$') as stop_regex_array
    from stg_stops
    where mode = 'tram'
  )

  , bus as (
    select
      *,
      REGEXP_MATCHES(stop_name, '(.+?)(?:/(.+)\s)?\s*\((.*(?:\(.*\)).*|[^()]+)\)$') as stop_regex_array
    from stg_stops
    where mode = 'bus'
  )

  , stops_all as (
    select
      *,
      stop_regex_array[1] as stop_number,
      stop_regex_array[2] as stop_short_name,
      stop_regex_array[3] as stop_road_name,
      stop_regex_array[4] as stop_suburb
    from tram   

    union all

    select
      *,
      NULL                as stop_number,
      stop_regex_array[1] as stop_short_name,
      stop_regex_array[2] as stop_road_name,
      stop_regex_array[3] as stop_suburb
    from bus

    union all

    select
      *,
      NULL                as stop_number,
      stop_regex_array[1] as stop_short_name,
      NULL                as stop_road_name,
      stop_regex_array[2] as stop_suburb
    from vline_metro
  )

  select
    mode::TEXT             as mode,
    stop_id::TEXT          as stop_id,
    stop_name::TEXT        as stop_full_name,
    stop_number::TEXT      as stop_number,
    stop_short_name::TEXT  as stop_short_name,  
    stop_road_name::TEXT   as stop_road_name,
    stop_suburb::TEXT      as stop_suburb,
    stop_lat::NUMERIC      as stop_lat,
    stop_lon::NUMERIC      as stop_lon,
    ST_Transform(
      ST_SetSRID(
        ST_MakePoint(stop_lon::NUMERIC, stop_lat::NUMERIC),
      4326),
    3857)::GEOMETRY        as stop_geo_point,
    NULL::TEXT[]           as cluster_neighbours
  from stops_all

);



-- TRIPS
CREATE TEMPORARY TABLE stg_trips (
  mode TEXT,
  route_id TEXT,
  service_id TEXT,
  trip_id TEXT,
  shape_id TEXT,
  trip_headsign TEXT,
  direction_id TEXT
);

ALTER TABLE stg_trips ALTER COLUMN mode SET DEFAULT 'vline';
\COPY stg_trips(route_id,service_id,trip_id,shape_id,trip_headsign,direction_id) FROM 'backend/local/gtfs/1/trips.txt' WITH CSV HEADER;

ALTER TABLE stg_trips ALTER COLUMN mode SET DEFAULT 'metro';
\COPY stg_trips(route_id,service_id,trip_id,shape_id,trip_headsign,direction_id) FROM 'backend/local/gtfs/2/trips.txt' WITH CSV HEADER;

ALTER TABLE stg_trips ALTER COLUMN mode SET DEFAULT 'tram';
\COPY stg_trips(route_id,service_id,trip_id,shape_id,trip_headsign,direction_id) FROM 'backend/local/gtfs/3/trips.txt' WITH CSV HEADER;

ALTER TABLE stg_trips ALTER COLUMN mode SET DEFAULT 'bus';
\COPY stg_trips(route_id,service_id,trip_id,shape_id,trip_headsign,direction_id) FROM 'backend/local/gtfs/4/trips.txt' WITH CSV HEADER;

ALTER TABLE stg_trips ALTER COLUMN mode DROP DEFAULT;

CREATE TABLE trips as (
  select
    mode::TEXT           as mode,
    route_id::TEXT       as route_id,
    service_id::TEXT     as service_id,
    trip_id::TEXT        as trip_id,
    shape_id::TEXT       as shape_id,
    trip_headsign::TEXT  as trip_headsign,
    direction_id::TEXT   as direction_id 
  from stg_trips
);


-- Indexes
CREATE INDEX idx_calendar_dates_date ON calendar_dates(date);
CREATE INDEX idx_calendar_service_id ON calendar(service_id);
CREATE INDEX idx_routes_route_id ON routes(route_id);
CREATE INDEX idx_stop_times_stop_id ON stop_times(stop_id);
CREATE INDEX idx_stop_times_trip_id ON stop_times(trip_id);
CREATE INDEX idx_stops_stop_id ON stops(stop_id);
CREATE INDEX idx_trips_trip_id ON trips(trip_id);
CREATE INDEX idx_trips_route_id ON trips(route_id);
CREATE INDEX idx_trips_service_id ON trips(service_id);
CREATE INDEX idx_stops_stop_geo_point on stops using GIST(stop_geo_point);


-- Secondary Layer
-- Clusters
create temporary table stop_clusters as (
  with cluster as (
    select
      stop_id,
      ST_ClusterWithinWin(stop_geo_point, 100) OVER () as cluster_id
    from stops
  )

  , multi_stop_only as (
    select cluster_id from cluster
    group by cluster_id
    having count(*) > 1
  )

  select stop_id, cluster_id from cluster
  where cluster_id in (select cluster_id from multi_stop_only)
);

-- Update stops
update stops set cluster_neighbours = (
  select ARRAY_AGG(c.stop_id) from stop_clusters c
  where c.stop_id <> stops.stop_id
  and c.cluster_id in (
    select cc.cluster_id from stop_clusters cc where stops.stop_id = cc.stop_id
  )
);

-- Grants
GRANT ALL PRIVILEGES ON DATABASE ptvdb TO python;
GRANT ALL ON TABLE calendar TO python;
GRANT ALL ON TABLE calendar_dates TO python;
GRANT ALL ON TABLE geography_columns TO python;
GRANT ALL ON TABLE geometry_columns TO python;
GRANT ALL ON TABLE routes TO python;
GRANT ALL ON TABLE spatial_ref_sys TO python;
GRANT ALL ON TABLE stop_times TO python;
GRANT ALL ON TABLE stops TO python;
GRANT ALL ON TABLE trips TO python;