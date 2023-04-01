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
        const response = await fetch(`${import.meta.env.VITE_BACKEND_HOST}/stops?q=${query}`);
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
    <div className="Search max-w-screen-lg mx-auto p-8 text-center">
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
      <Stops stops={stops} />
    </div>
  )
}

export default Search
