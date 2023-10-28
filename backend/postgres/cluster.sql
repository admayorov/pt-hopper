DROP TABLE IF EXISTS stop_clusters;

-- Clusters

-- Proximity clusters
-- Clusters stops within 50 metres of each other
create temporary table stop_proximity_clusters as (
  with cluster as (
    select
      stop_id,
      ST_ClusterWithinWin(stop_geo_point, 50) OVER () as cluster_id
    from stops
  )

  , multi_stop_only as (
    select cluster_id from cluster
    group by cluster_id
    having count(*) > 1
  )

  , stop_routes as (
      select st.stop_id, array_agg(distinct r.route_short_name order by r.route_short_name) as stop_route_list
      from stop_times st
      inner join trips t on st.trip_id = t.trip_id
      inner join routes r on t.route_id = r.route_id
      group by st.stop_id
  )

  , interchange_clusters as (
    select c.cluster_id, (count(distinct sr.stop_route_list) > 1) as is_interchange_cluster
    from stop_routes sr
    inner join cluster c on sr.stop_id = c.stop_id
    inner join stops s on c.stop_id = s.stop_id
    group by c.cluster_id
  )

  select c.stop_id, c.cluster_id, ic.is_interchange_cluster from cluster c
  left join interchange_clusters ic on ic.cluster_id = c.cluster_id
  where c.cluster_id in (select cluster_id from multi_stop_only)
);


-- Name clusters
-- Clusters stops with the same name, that are within 200 metres of each other
create temporary table stop_name_clusters as (
    with stops1 as (
        select
            stop_id,
            stop_geo_point,
            TRIM(
                REGEXP_REPLACE(REGEXP_REPLACE(stop_short_name, ' (?:Railway )?Station\s*$', ''), '^\d+-', ''),
            ' ') as stop_base_name
        from stops
    )

    , stops2 as (
        select
            stop_id,
            stop_geo_point,
            stop_base_name,
            DENSE_RANK() over (order by stop_base_name) as name_cluster_id
        from stops1
    )
    
    , stops3 as (
        select
            stop_id,
            name_cluster_id,
            ST_ClusterWithinWin(stop_geo_point, 200) OVER (partition by name_cluster_id) as distance_sub_cluster_id
        from stops2
    )

    , cluster as (
        select
            stop_id,
            DENSE_RANK() over (order by name_cluster_id||'-'||distance_sub_cluster_id) as cluster_id,
            count(*) over (partition by name_cluster_id, distance_sub_cluster_id) as count_within_cluster
        from stops3
    )

    , stop_routes as (
      select st.stop_id, array_agg(distinct r.route_short_name order by r.route_short_name) as stop_route_list
      from stop_times st
      inner join trips t on st.trip_id = t.trip_id
      inner join routes r on t.route_id = r.route_id
      group by st.stop_id
    )

    , interchange_clusters as (
      select c.cluster_id, (count(distinct sr.stop_route_list) > 1) as is_interchange_cluster
      from stop_routes sr
      inner join cluster c on sr.stop_id = c.stop_id
      inner join stops s on c.stop_id = s.stop_id
      group by c.cluster_id
    )

    select c.stop_id, c.cluster_id, ic.is_interchange_cluster from cluster c
    left join interchange_clusters ic on ic.cluster_id = c.cluster_id
    where c.count_within_cluster > 1
);

create table stop_clusters as (
    select
      coalesce(pc.stop_id, nc.stop_id) as stop_id,
      'P'||pc.cluster_id as proximity_cluster_id,
      'N'||nc.cluster_id as name_cluster_id,
      (coalesce(pc.is_interchange_cluster, false) or coalesce(nc.is_interchange_cluster, false)) as is_interchange_cluster
    from stop_proximity_clusters pc
    full outer join stop_name_clusters nc on pc.stop_id = nc.stop_id
);