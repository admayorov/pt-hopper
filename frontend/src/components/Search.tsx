import { useState } from 'react'
import Stops from "./Stops";

// import reactLogo from './assets/react.svg'
// import viteLogo from '/vite.svg'

interface Stop {
  mode: string;
  stop_gtfs_id: string;
  name: string;
  suburb: string;
  latitude: number;
  longitude: number;
}

interface SearchProps {
  setStopID: (info: string) => void;
}

function Search(props: SearchProps) {
  const [query, setQuery] = useState('');
  const [debounceTimer, setDebounceTimer] = useState<NodeJS.Timeout>();
  const [stops, setStops] = useState<Stop[]>([]);


  const handleStopSearch = async (query: string) => {
    const _handleStopSearch = async (q: string) => {
      const response = await fetch(`/api/stops?q=${q}`);
      const data = await response.json();
      setStops(data)
    };

    clearTimeout(debounceTimer);
    let newDebounceTimer = setTimeout(() => {
      _handleStopSearch(query);
    }, 250);
    setDebounceTimer(newDebounceTimer)
  };

  const handleInputChange = (input: string) => {
    if (input.length !== 0) {
      setQuery(input);
      handleStopSearch(input);
    } else {
      setQuery('')
      setStops([])
    }
  };

  const handleStopSuggestionSelect = (stopName: string, stopId: string) => {
    setQuery(stopName);
    setStops([]);
    props.setStopID(stopId)
  }

  return (
    <div>
      <input className="flex items-center w-full p-2 bg-white rounded"
        type="text"
        value={query}
        onChange={(e) => handleInputChange(e.target.value)}
        placeholder="Search..."
      />
      {query.length > 0 && stops.length > 0 && (
        <ul className="w-full py-1 mt-1 bg-white border border-gray-300 rounded shadow-md">
          {stops.map((stop, index) => (
            <li
              key={index}
              onClick={() => handleStopSuggestionSelect(stop.name, stop.stop_gtfs_id)}
              className="px-4 py-2 cursor-pointer hover:bg-gray-200"
            >
              {stop.name}
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}

export default Search
