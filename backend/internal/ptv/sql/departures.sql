-- SQLite
SELECT DISTINCT
    st.mode,
	t.trip_id,
    st.arrival_time,
    st.departure_time,
    t.trip_headsign,
	coalesce(nullif(r.route_short_name,''),r.route_long_name) as route,
    r.route_id
    -- r.route_api_id,
    -- r.route_api_id||'_'||REPLACE(st.departure_time,':','') as id_dep_id
FROM stop_times st

LEFT JOIN trips t
on st.trip_id = t.trip_id and t.mode = st.mode

LEFT JOIN calendar c
on t.service_id = c.service_id and c.mode = st.mode

LEFT JOIN routes r
on t.route_id = r.route_id and r.mode = st.mode

WHERE st.stop_id = :stop_id
and c.mode = st.mode
and c.start_date <= :date
and c.end_date >= :date
and (CASE :int_weekday
	when 0 then c.sunday = 1
    when 1 then c.monday = 1
    when 2 then c.tuesday = 1
    when 3 then c.wednesday = 1
    when 4 then c.thursday = 1
    when 5 then c.friday = 1
    when 6 then c.saturday = 1
    when 7 then c.sunday = 1
    else 1=1
    END) 
and st.departure_time >= :dep_time_min
and st.departure_time <= :dep_time_max

and t.service_id not in (
    select service_id
    from calendar_dates
    where date = :date
    and exception_type = "2"
)

ORDER BY
    t.direction_id desc,
    route,
    st.departure_time;