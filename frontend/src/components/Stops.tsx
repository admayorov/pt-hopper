import { useNavigate } from "react-router-dom";

function Stops({ stops }: { stops: Array<any> }) {
  const navigate = useNavigate();

  if (!stops || stops.length === 0) {
    return null;
  }

  const handleRowClick = (stopId: string) => {
    navigate(`/departures/${stopId}`);
  };


  return (
    <div>
      <table className="table-auto w-full">
        <thead>
          <tr className="dark:bg-gray-900 bg-gray-200 text-gray-600 dark:text-gray-400 uppercase text-sm leading-normal">
            <th className="py-3 px-6 text-left">Stop ID</th>
            <th className="py-3 px-6 text-left">Stop Name</th>
            <th className="py-3 px-6 text-left">Suburb</th>
            <th className="py-3 px-6 text-left">Mode</th>
          </tr>
        </thead>
        <tbody className="text-gray-600 dark:text-gray-200 text-sm font-light">
          {stops.map((stop) => (
            <tr
              key={stop.stop_gtfs_id}
              className="border-b border-gray-200 dark:border-gray-400 hover:bg-gray-100 dark:hover:bg-gray-600 cursor-pointer"
              onClick={() => handleRowClick(stop.stop_gtfs_id)}
            >
              <td className="py-3 px-6 text-left whitespace-nowrap">{stop.stop_gtfs_id}</td>
              <td className="py-3 px-6 text-left">
                {stop.name}
                <span className="text-xs"><br />{stop.road_name ? `on ${stop.road_name}` : ""}</span>
              </td>
              <td className="py-3 px-6 text-left">{stop.suburb}</td>
              <td className="py-3 px-6 text-left">{stop.mode}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default Stops;