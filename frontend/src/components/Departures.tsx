import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";

interface Departure {
  mode?: string;
  trip_id?: string;
  arrival_time?: string;
  departure_time?: string;
  trip_headsign?: string;
  route_name?: string;
  route_id?: string;
  route_api_id?: string;
  id_dep_id?: string;
}


function DepartureTable({ deps }: { deps: Departure[] }) {
    if (!deps || deps.length === 0) {
      return null;
    }

    return (
      <div>
        <table className="table-auto w-full">
          <thead>
            <tr className="bg-gray-200 text-gray-600 uppercase text-sm leading-normal">
              <th className="py-3 px-6 text-left">Trip ID</th>
              <th className="py-3 px-6 text-left">Destination</th>
              <th className="py-3 px-6 text-left">Departing At</th>
            </tr>
          </thead>
          <tbody className="text-gray-600 text-sm font-light">
            {deps.map((dep) => (
              <tr
                key={dep.trip_id}
                className="border-b border-gray-200 hover:bg-gray-100"
              >
                <td className="py-3 px-6 text-left whitespace-nowrap">{dep.trip_id}</td>
                <td className="py-3 px-6 text-left">{dep.trip_headsign}</td>
                <td className="py-3 px-6 text-left">{dep.departure_time?.slice(0,-3)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  }

function Departures() {
  const { stop_gtfs_id } = useParams<{ stop_gtfs_id: string }>();
  const [departures, setDepartures] = useState<Departure[]>([]);

  useEffect(() => {
    async function fetchDepartures() {
      try {
        const response = await fetch(`${import.meta.env.VITE_BACKEND_HOST}/departures/${stop_gtfs_id}/`);
        if (!response.ok) {
            throw new Error("Departures API response was not ok");
        }
        const data = await response.json();
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
      <DepartureTable deps={departures} />
    </div>
  );
}

export default Departures;
