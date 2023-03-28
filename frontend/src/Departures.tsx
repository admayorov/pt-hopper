import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";

interface Departure {
  trip_id: string;
  departure_time: string;
}

function Departures() {
  const { stop_gtfs_id } = useParams<{ stop_gtfs_id: string }>();
  const [departures, setDepartures] = useState<Departure[]>([]);

  useEffect(() => {
    async function fetchDepartures() {
      try {
        // const response = await fetch(`${import.meta.env.VITE_BACKEND_HOST}/api/stops/${stop_gtfs_id}/departures`);
        // if (!response.ok) {
        //     throw new Error("Network response was not ok");
        // }
        // const data = await response.json();
        const data : Departure[] = [{
            trip_id: "1234",
            departure_time: "09:30:00",
          }]
        setDepartures(data);
      } catch (error) {
        console.error(error);
      }
    }
    fetchDepartures();
  }, [stop_gtfs_id]);

  return (
    <div>
      <h1>Departures for stop {stop_gtfs_id}</h1>
      <ul>
        {departures.map((departure) => (
          <li key={departure.trip_id}>
            Trip ID: {departure.trip_id}, Departure Time: {departure.departure_time}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default Departures;
