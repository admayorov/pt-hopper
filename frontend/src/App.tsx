import { useState } from 'react'
// import reactLogo from './assets/react.svg'
// import viteLogo from '/vite.svg'
import './App.css'

function App() {
  // const [count, setCount] = useState(55)

  const [query, setQuery] = useState('');

  const handleSearch = async () => {
    // Here you can use any library or native fetch method to call the API
    const response = await fetch(`/search?q=${query}`);
    const data = await response.json();
    console.log(data);
  };

  return (
    <div className="App">
      <h1>Search by Stop</h1>
      <div>
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search..."
        />
        <button onClick={handleSearch}>Search</button>
      </div>
    </div>
  )
}

export default App
