import { useState } from 'react'
import Stops from "./Stops";

// import reactLogo from './assets/react.svg'
// import viteLogo from '/vite.svg'
import './App.css'






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
      <Stops stops={stops} />
    </div>
  )
}

export default App
