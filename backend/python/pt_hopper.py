from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, time, timedelta
from typing import Tuple

from heapdict import heapdict

from sqlalchemy import ARRAY, create_engine, and_, case, func, Column, Integer, Numeric, SmallInteger, Text, Date
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.sql import text

db_url = 'postgresql://python:testing@localhost:5432/ptvdb'
engine = create_engine(db_url)

Base = declarative_base()

class Stop(Base):
    __tablename__ = 'stops'

    mode = Column(Text)
    stop_id = Column(Text, primary_key=True)
    stop_full_name = Column(Text)
    stop_number = Column(Text)
    stop_short_name = Column(Text)
    stop_road_name = Column(Text)
    stop_suburb = Column(Text)
    cluster_neighbours = Column(ARRAY(Text))
    # stop_lat = Column(Numeric)
    # stop_lon = Column(Numeric)

class StopTime(Base):
    __tablename__ = 'stop_times'

    mode = Column(Text)
    trip_id = Column(Text)
    arrival_time_int = Column(Integer)
    departure_time_int = Column(Integer)
    stop_id = Column(Text, primary_key=True)
    stop_sequence = Column(SmallInteger)
    stop_headsign = Column(Text)
    pickup_type = Column(SmallInteger)
    drop_off_type = Column(SmallInteger)
    shape_dist_traveled = Column(Numeric)

class Route(Base):
    __tablename__ = 'routes'

    mode = Column(Text)
    route_id = Column(Text, primary_key=True)
    agency_id = Column(Text)
    route_short_name = Column(Text)
    route_long_name = Column(Text)
    route_type = Column(Text)
    route_color = Column(Text)
    route_text_color = Column(Text)
    route_api_id = Column(Text)

class Trip(Base):
    __tablename__ = 'trips'

    mode = Column(Text)
    route_id = Column(Text)
    service_id = Column(Text)
    trip_id = Column(Text, primary_key=True)
    shape_id = Column(Text)
    trip_headsign = Column(Text)
    direction_id = Column(Text)

class Calendar(Base):
    __tablename__ = 'calendar'

    mode = Column(Text)
    service_id = Column(Text, primary_key=True)
    monday = Column(SmallInteger)
    tuesday = Column(SmallInteger)
    wednesday = Column(SmallInteger)
    thursday = Column(SmallInteger)
    friday = Column(SmallInteger)
    saturday = Column(SmallInteger)
    sunday = Column(SmallInteger)
    start_date = Column(Date)
    end_date = Column(Date)

class CalendarDate(Base):
    __tablename__ = 'calendar_dates'

    mode = Column(Text)
    service_id = Column(Text, primary_key=True)
    date = Column(Date, primary_key=True)
    exception_type = Column(SmallInteger)


Base.metadata.create_all(engine)
Session = sessionmaker(bind=engine)



def time_to_seconds(dt: datetime | time, is_next_day=False) -> int:
    hours = dt.hour
    minutes = dt.minute
    seconds = dt.second

    if is_next_day:
        hours = hours + 24

    return hours * 3600 + minutes * 60 + seconds

def seconds_to_time(total_seconds: int) -> Tuple[time, bool]:
    hours, remainder = divmod(total_seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    is_next_day = False

    if hours >= 24:
        hours = hours - 24
        is_next_day = True

    return time(hour=hours, minute=minutes, second=seconds), is_next_day
    

def get_trips(stop_id: str, departure_time: datetime | int, row_limit: int = 100, time_limit: int = 9999999):
    with Session() as session:
        # Some params
        try:
            day_of_the_week = departure_time.weekday()
        except:
            day_of_the_week = 3  # FIXME

        cal_column_list = [Calendar.monday, Calendar.tuesday, Calendar.wednesday, Calendar.thursday, Calendar.friday, Calendar.saturday, Calendar.sunday]
        cal_column = cal_column_list[day_of_the_week]

        # Build the query
        query = session.query(
            StopTime.mode,
            Trip.trip_id,
            StopTime.arrival_time_int,
            StopTime.departure_time_int,
            Trip.trip_headsign,
            case((Route.route_short_name != '', Route.route_short_name), else_=Route.route_long_name).label('route'),
            Route.route_id
        ).distinct()

        query = query.join(Trip, and_(StopTime.trip_id == Trip.trip_id, Trip.mode == StopTime.mode), isouter=True)
        query = query.join(Calendar, and_(Trip.service_id == Calendar.service_id, Calendar.mode == StopTime.mode), isouter=True)
        query = query.join(Route, and_(Trip.route_id == Route.route_id, Route.mode == StopTime.mode), isouter=True)

        if type(departure_time) == 'datetime':
            dep_time_int = time_to_seconds(departure_time)
        else:
            dep_time_int = departure_time

        query = query.filter(
            StopTime.stop_id == stop_id,
            Calendar.start_date <= func.current_date(),
            Calendar.end_date >= func.current_date(),
            cal_column == 1,
            StopTime.departure_time_int.between(dep_time_int, dep_time_int+time_limit),
            ~Trip.service_id.in_(
                session.query(CalendarDate.service_id).filter(
                    CalendarDate.date == func.current_date(),
                    CalendarDate.exception_type == '2'
                )
            )
        ).order_by(StopTime.departure_time_int).limit(row_limit)

        return query.all()

def get_stopping_times(trip_id: str):
    with Session() as session:
        # Define the query
        query = session.query(
            Trip.trip_id,
            StopTime.stop_sequence,
            Stop.stop_id,
            Stop.stop_short_name,
            StopTime.departure_time_int
        )

        query = query.join(StopTime, Trip.trip_id == StopTime.trip_id, isouter=True)
        query = query.join(Stop, StopTime.stop_id == Stop.stop_id, isouter=True)

        query = query.filter(Trip.trip_id == trip_id)

        query = query.order_by(StopTime.stop_sequence.cast(Integer).asc())

        result = query.all()
        return [row[1:] for row in result] # Exclude reudndant trip_id column

def stop_distance(stop_id_1: str, stop_id_2: str):
    with Session() as session:
        sql = text(
            """
            select
                ST_Distance(s1.stop_geo_point, s2.stop_geo_point)
            from stops s1 cross join stops s2
            where s1.stop_id = :s1 and s2.stop_id = :s2;
            """)
        
        result = session.execute(sql, params={'s1': stop_id_1, 's2': stop_id_2}).fetchall()

        if len(result) == 0:
            raise Exception(f"No results from stop_distance with following stop_id values: {stop_id_1}, {stop_id_2}")
        
        return result[0][0]

def get_stop(stop_id: str):
    with Session() as session:
        query = session.query(
            Stop.mode,
            Stop.stop_id,
            Stop.stop_full_name,
            Stop.stop_number,
            Stop.stop_short_name,
            Stop.stop_road_name,
            Stop.stop_suburb,
            Stop.cluster_neighbours
        )
        
        result = query.all()

        if len(result) == 0:
            raise Exception(f"No results from get_stop for stop_id {stop_id}")
        
        return result[0]
        

# trips = get_trips('19943', datetime.now(), row_limit=20, time_limit=60*60)
# for row in trips:
#     desto = row[4]
#     line = row[5]
#     dep_time, _ = seconds_to_time(row[3])

#     print(f"{dep_time.strftime('%H:%M')} to {desto}")

# times = get_stopping_times(trip_id='191.T0.2-FKN-mjp-12.15.R')
# for row in times:
#     print(row)

@dataclass
class Node:
    type: str
    id: str
    t: str
    parent: Node = None

    def __hash__(self):
        return hash((self.type, self.id, self.t))
    
    def __repr__(self):
        return f"Node('{self.type}', '{self.id}', '{self.t}')"
    
    def __str__(self):
        time, _ = seconds_to_time(self.t)
        pretty_time = time.strftime('%H:%M')

        return f"<{self.type} node '{self.id}' at {pretty_time}>"
    
    def tid(self):
        return (self.type, self.id)

def algo(start_stop_id: str, end_stop_id: str, departure_time: datetime):
    allowed_transfer_time = 60 # Time (seconds) between arriving at a stop and boarding another trip
    q = heapdict()

    node_type = 'stop'
    id = start_stop_id
    t = time_to_seconds(departure_time)

    node = Node(node_type, id, t)
    
    q[node] = stop_distance(start_stop_id, end_stop_id)

    visited = set()
    visited.add(node.tid())

    found_node = None
    for i in range(999):
        node, current_dist = q.popitem()

        if node.type == 'stop':
            stop_data = get_stop(node.id)
            cluster_stop_ids = [node.id] + stop_data.cluster_neighbours

            for stop_id in cluster_stop_ids:
                new_stop_node = Node('stop', stop_id, t, parent=node)

                if new_stop_node.tid() not in visited:
                    visited.add(new_stop_node.tid())
                    q[new_stop_node] = current_dist + stop_distance(node.id, stop_id)

                trips = get_trips(new_stop_node.id, new_stop_node.t + allowed_transfer_time, time_limit=30*60)
                for trip in trips:
                    trip_id = trip[1]
                    t = trip[3]
                    dist = current_dist + (t - node.t) # add time delta to penalise later trips (1 second = 1 extra metre)

                    new_node = Node('trip', trip_id, t, parent=new_stop_node)

                    if new_node.tid() not in visited:
                        visited.add(new_node.tid())
                        q[new_node] = dist

        elif node.type == 'trip':
            stops = get_stopping_times(node.id)
            for stop in stops:
                if stop[3] > node.t:
                    stop_id = stop[1]
                    t = stop[3]
                    dist = stop_distance(stop[1], end_stop_id)

                    new_node = Node('stop', stop_id, t, parent=node)

                    if new_node.tid() not in visited:
                        visited.add(new_node.tid())
                        q[new_node] = dist

                    if stop_id == end_stop_id:
                        found_node = new_node
                        break
           
        print(f"#{i}")

        nodes = dict(q)
        nodes = {k: v for k, v in sorted(nodes.items(), key=lambda item: item[1])}

        for node, dist in nodes.items():
            print(f"{node} {round(dist/1000,3)} km")
        print("\n")

        if found_node:
            print("Found!")
            break

    # Target stop found, backtrack to get parents
    path = []
    node = found_node

    while node:
        path.append(node)
        node = node.parent
    
    for node in reversed(path):
        print(node)
        


if __name__ == '__main__':
    stop1 = '19915' # Clayton
    stop2 = '19866' # Cheltenham
    t0 = time_to_seconds(datetime.now())

    n = Node('stop', stop1, t0)

    algo(stop1, stop2, datetime.now())


# next:
# - pretty print ✅
# - incorporate time
#   - use as tiebraker?
#   - think about time-based heuristic function
# - consider A*
# - add other modes
#   - start looking into stop grouping