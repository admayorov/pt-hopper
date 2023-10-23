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

session = Session()

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

    try:
        day_of_the_week = departure_time.weekday()
    except:
        day_of_the_week = datetime.now().weekday()  # FIXME

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

    # Define the query
    query = session.query(
        Trip.trip_id,
        StopTime.stop_sequence,
        Stop.stop_id,
        Stop.stop_short_name,
        StopTime.departure_time_int
    )

    query = query.join(StopTime, Trip.trip_id == StopTime.trip_id, isouter=True)
    query = query.join(Stop, StopTime.stop_id == Stop.stop_id)

    query = query.filter(Trip.trip_id == trip_id)

    query = query.order_by(StopTime.stop_sequence.cast(Integer).asc())

    result = query.all()
    return [row[1:] for row in result] # Exclude reudndant trip_id column

def stop_distance(stop_id_1: str, stop_id_2: str):
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

    query = query.filter(Stop.stop_id == stop_id)
    
    result = query.first()

    if result is None:
        raise Exception(f"No results from get_stop for stop_id {stop_id}")
    
    return result
        

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
    origin_stop_id: str = None
    parent: Node = None

    def __hash__(self):
        return hash((self.type, self.id, self.t))
    
    def __repr__(self):
        return f"Node('{self.type}', '{self.id}', '{self.t}')"
    
    def __str__(self):
        time, _ = seconds_to_time(self.t)
        pretty_time = time.strftime('%H:%M')

        return f"<{self.type} node '{self.id}' at {pretty_time}>"
    
class SearchQueue():
    def __init__(self):
        self.q = heapdict()
        self.visited = set()
    
    def __len__(self):
        return len(self.q)
    
    def __bool__(self):
        return bool(self.q)
    
    def add(self, node: Node, score: any):
        if (node.type, node.id) in self.visited:
            try:
                existing_score = self.q[node]
            except KeyError:
                return

            if score < existing_score:
                self.q[node] = score
        else:
            self.visited.add((node.type, node.id))
            self.q[node] = score
    
    def popitem(self):
        return self.q.popitem()
    
    def as_dict(self):
        return dict(self.q)
    
    

def algo(start_stop_id: str, end_stop_id: str, departure_time: datetime):
    def f_score(node):
        if node.type == 'stop':
            stop_id = node.id
        else:
            stop_id = node.origin_stop_id
        
        dist_in_metres = stop_distance(stop_id, end_stop_id)
        dist_in_km = dist_in_metres/1000

        avg_speed = 0.5 # km per minute

        time_in_minutes = dist_in_km / avg_speed
        time_in_seconds = time_in_minutes * 60

        estimate = int(time_in_seconds)

        return node.t + estimate
    
    minimum_transfer_time = 60 # Minimum time (seconds) allowed between arriving at a stop and boarding another trip
    sq = SearchQueue()

    t = time_to_seconds(departure_time)
    start_node = Node('stop', start_stop_id, t)

    sq.add(start_node, f_score(start_node))

    found_node = None
    for i in range(2000):
        node, _ = sq.popitem()

        if node.type == 'stop':
            trips = get_trips(node.id, node.t, time_limit=60*30)

            # Add trips from this stop
            for trip in trips:
                id = trip[1]
                t = trip[3]

                if (t - node.t) > minimum_transfer_time:
                    new_node = Node('trip', id, t, origin_stop_id=node.id, parent=node)
                    sq.add(new_node, f_score(new_node))
            
            # Add neighbour stops from cluster
            stop_data = get_stop(node.id)
            if stop_data.cluster_neighbours:
                for neighbour_id in stop_data.cluster_neighbours:
                    id = neighbour_id
                    t = node.t + minimum_transfer_time

                    new_node = Node('stop', id, t, parent=node)
                    sq.add(new_node, f_score(new_node))

                    if neighbour_id == end_stop_id:
                        found_node = new_node
                        break

        elif node.type == 'trip':
            stops = get_stopping_times(node.id)

            for stop in stops:
                stop_id = stop[1]
                if stop_id == node.origin_stop_id:
                    origin_seq_no = stop[0]
                    break
            
            for stop in stops:
                seq_no = stop[0]
                if seq_no > origin_seq_no:
                    stop_id = stop[1]
                    t = stop[3]

                    new_node = Node('stop', stop_id, t, parent=node)
                    sq.add(new_node, f_score(new_node))

                    if stop_id == end_stop_id:
                        found_node = new_node
                        break
           
        print(f"#{i}")

        nodes = sq.as_dict()
        nodes = {k: v for k, v in sorted(nodes.items(), key=lambda item: item[1])}
        
        NUM = 10

        i = 0
        for node, est_t in nodes.items():
            if i == NUM:
                break

            time, _ = seconds_to_time(est_t)
            pretty_time = time.strftime('%H:%M')

            # if node.type == 'stop':
            #     stop_data = get_stop(node.id)
            # else:
            #     stop_data = get_stop(node.origin_stop_id)
            

            print(f"{node} - est arrival {pretty_time}")
            # print(f"{node} - est arrival {pretty_time} - {stop_data[:3]}")
            i+= 1

        if len(nodes) > NUM:
            print(f"... and {len(nodes)-NUM} more nodes.")
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
        if node.type == 'stop':
            data = get_stop(node.id)[:3]
        else:
            data = ''

        print(node, data)
        


if __name__ == '__main__':
    stop1 = '22180' # SXS
    stop2 = '21611' # Monash Uni

    algo(stop1, stop2, datetime.now() - timedelta(hours=10))


# next:
# - pretty print ✅
# - incorporate time 
#   - use as tiebraker? ✅
#   - think about time-based heuristic function ✅
# - consider A* ✅
# - add other modes ✅
#   - start looking into stop grouping ✅
# - formalise heapdict and visited set into a class ✅
# - re-use sqlalchemy session between calls ✅
# - update to modern sqlalchemy syntax
# - pass date and time into get trips instead of relying on current_date
# - get multiple paths
#   - once path is found, recalculate with an intermidate node removed