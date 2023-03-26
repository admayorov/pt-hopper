-- SQLite
SELECT
    t.trip_id,
    s.stop_id,
    s.stop_short_name,
    st.departure_time,
    st.stop_sequence
FROM trips t

LEFT JOIN stop_times st
ON t.trip_id = st.trip_id

LEFT JOIN stops s
ON st.stop_id = s.stop_id

WHERE t.trip_id=:trip_id
ORDER BY CAST(st.stop_sequence as INTEGER) asc;





