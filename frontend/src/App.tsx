import { useState } from 'react'
// import reactLogo from './assets/react.svg'
// import viteLogo from '/vite.svg'
import './App.css'

function StopTable({ stops }: { stops: Array<any> }) {
  if (!stops || stops.length === 0) {
    return null;
  }

  return (
    <table className="table-auto w-full">
      <thead>
        <tr className="bg-gray-200 text-gray-600 uppercase text-sm leading-normal">
          <th className="py-3 px-6 text-left">Stop ID</th>
          <th className="py-3 px-6 text-left">Stop Name</th>
          <th className="py-3 px-6 text-left">Suburb</th>
          <th className="py-3 px-6 text-left">Mode</th>
        </tr>
      </thead>
      <tbody className="text-gray-600 text-sm font-light">
        {stops.map((stop) => (
          <tr key={stop.stop_gtfs_id} className="border-b border-gray-200 hover:bg-gray-100">
            <td className="py-3 px-6 text-left whitespace-nowrap">{stop.stop_gtfs_id}</td>
            <td className="py-3 px-6 text-left">
              {stop.name}
              <span className="text-xs"><br/>{stop.road_name ? `on ${stop.road_name}` : ""}</span>
              </td>
            <td className="py-3 px-6 text-left">{stop.suburb}</td>
            <td className="py-3 px-6 text-left">{stop.mode}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}




function App() {
  const [query, setQuery] = useState('');
  const [debounceTimer, setDebounceTimer] = useState<NodeJS.Timeout>();
  const [stops, setStops] = useState([]);

  const handleStopSearch = async (query: string) => {
    try {
      const response = await fetch(`${import.meta.env.VITE_BACKEND_HOST}/stops?q=${query}`);
      const data = await response.json();
      console.log(`Query=${query} retrieved ${data.length} stops`);
      setStops(data)
    } catch (error) {
      console.error(error)
    }
  };

  const debouncedSearch = (query: string) => {
    clearTimeout(debounceTimer);
    let newDebounceTimer = setTimeout(() => {
      handleStopSearch(query);
    }, 300);
    setDebounceTimer(newDebounceTimer)
  };

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const query = event.target.value;
    setQuery(query);
    debouncedSearch(query);
  };

  return (
    <div className="App">
      <h1 className="text-2xl font-bold mb-4">Search by Stop</h1>
      <div className="flex flex-col items-center">
        <div className="flex items-center w-full max-w-md">
          <input className="w-full max-w-md px-4 py-2 rounded-md border border-gray-300 focus:outline-none focus:border-indigo-500 mr-4"
            type="text"
            value={query}
            onChange={handleInputChange}
            placeholder="Search..."
          />
        </div>
      </div>
      <p className="py-4">
        The env variable is {import.meta.env.VITE_BACKEND_HOST}
      </p>
      <StopTable stops={stops} />
    </div>
  )
}

export default App
