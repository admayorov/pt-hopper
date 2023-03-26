import { useState } from 'react'
// import reactLogo from './assets/react.svg'
// import viteLogo from '/vite.svg'
import './App.css'

function App() {
  // const [count, setCount] = useState(55)

  const [query, setQuery] = useState('');


  const handleInputChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
    setQuery(event.target.value);
    const response = await fetch(`/search?q=${query}`);
    const data = await response.json();
    console.log(data);
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
        </div></div>
    </div>
  )
}

export default App
