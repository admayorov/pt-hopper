import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";

interface Departure {
  mode: string;
  trip_id: string;
  arrival_time: string;
  departure_time: string;
  trip_headsign: string;
  route_name: string;
  route_id: string;
}

interface RouteDepartures {
  [key: string]: Departure[];
}

function DepartureTable(props: { deps: RouteDepartures }) {
  const { deps } = props;

  return (
    <div>
      {Object.keys(deps).map((route) => (
        <div key={route}>
          <h2 className="text-2xl mb-4 dark:text-white">{route}</h2>
          <table className="table-auto w-full">
            <thead>
              <tr className="bg-gray-200 dark:bg-gray-900 text-gray-600 dark:text-gray-400 uppercase text-sm leading-normal">
                <th className="py-3 px-6 text-left">Trip ID</th>
                <th className="py-3 px-6 text-left">Destination</th>
                <th className="py-3 px-6 text-left">Departing At</th>
              </tr>
            </thead>
            <tbody className="text-gray-600 dark:text-gray-200">
              {deps[route].map((dep, index) => (
                <tr
                  key={dep.trip_id}
                  className="border-b border-gray-200 dark:border-gray-400 dark:hover:bg-gray-600 hover:bg-gray-100"
                >
                  <td className="py-3 px-6 text-left whitespace-nowrap">{dep.trip_id}</td>
                  <td className="py-3 px-6 text-left">{dep.trip_headsign}</td>
                  <td className="py-3 px-6 text-left">{dep.departure_time?.slice(0, -3)}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <br />
          <br />
        </div>
      ))}
    </div>
  );
}


function Departures() {
  const { stop_gtfs_id } = useParams<{ stop_gtfs_id: string }>();
  const [departures, setDepartures] = useState<RouteDepartures>({});

  useEffect(() => {
    async function fetchDepartures() {
      try {
        const response = await fetch(`/api/departures/${stop_gtfs_id}/`);
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
    <div className="max-w-screen-lg mx-auto p-8 text-center">
      <h1 className="text-white py-4">Departures for stop {stop_gtfs_id}</h1>
      <DepartureTable deps={departures} />
    </div>
  );
}

export default Departures;
