SELECT mode, stop_id, stop_short_name, stop_road_name, stop_suburb, stop_lat, stop_lon
FROM stops
WHERE 1=1
AND stop_short_name REGEXP :stop_regex
AND (
    CASE WHEN :mode IN (SELECT DISTINCT mode from stops)
    THEN mode = :mode
    ELSE 1=1 END
)
LIMIT :limit;