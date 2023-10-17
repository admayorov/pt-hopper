from sqlalchemy import create_engine, and_, case, func, Column, Integer, Numeric, SmallInteger, Text, Date
from sqlalchemy.orm import sessionmaker, declarative_base

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
    stop_lat = Column(Numeric)
    stop_lon = Column(Numeric)

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


# Example
with Session() as session:

    # Some params
    day_of_the_week = 2

    cal_column_list = [Calendar.sunday, Calendar.monday, Calendar.tuesday, Calendar.wednesday, Calendar.thursday, Calendar.friday, Calendar.saturday, Calendar.sunday]
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

    # Define the JOIN conditions
    query = query.join(Trip, and_(StopTime.trip_id == Trip.trip_id, Trip.mode == StopTime.mode), isouter=True)
    query = query.join(Calendar, and_(Trip.service_id == Calendar.service_id, Calendar.mode == StopTime.mode), isouter=True)
    query = query.join(Route, and_(Trip.route_id == Route.route_id, Route.mode == StopTime.mode), isouter=True)

    # Define the WHERE conditions
    query = query.filter(
        StopTime.stop_id == '19943',
        Calendar.start_date <= func.current_date(),
        Calendar.end_date >= func.current_date(),
        cal_column == 1,
        StopTime.departure_time_int.between(22 * 3600 + 21 * 60, 23 * 3600 + 21 * 60),
        ~Trip.service_id.in_(
            session.query(CalendarDate.service_id).filter(
                CalendarDate.date == func.current_date(),
                CalendarDate.exception_type == '2'
            )
        )
    )

    # Execute the query and fetch the results
    results = query.all()

    # Print the results
    for row in results:
        print(row)
