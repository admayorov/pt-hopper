import { useState } from 'react'
import Stops from "./Stops";

// import reactLogo from './assets/react.svg'
// import viteLogo from '/vite.svg'

function Search() {
  const [query, setQuery] = useState('');
  const [debounceTimer, setDebounceTimer] = useState<NodeJS.Timeout>();
  const [stops, setStops] = useState([]);



  const handleStopSearch = async (query: string) => {
    const _handleStopSearch = async (query: string) => {
      const response = await fetch(`/api/stops?q=${query}`);
      if (!response.ok) {
        throw new Error("Search API response was not ok");
      }
      const data = await response.json();
      console.log(`Query=${query} retrieved ${data.length} stops`);
      setStops(data)
    };

    clearTimeout(debounceTimer);
    let newDebounceTimer = setTimeout(() => {
      _handleStopSearch(query);
    }, 250);
    setDebounceTimer(newDebounceTimer)
  };

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const query = event.target.value;
    setQuery(query);
    handleStopSearch(query);
  };

  return (
    <div>
      <input className="flex items-center w-full p-2 bg-white rounded"
        type="text"
        value={query}
        onChange={handleInputChange}
        placeholder="Search..."
      />
      <Stops stops={stops} />
    </div>
  )
}

export default Search
