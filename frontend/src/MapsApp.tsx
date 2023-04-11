import Map from './components/Map';
import Search from './components/Search';
import Panel from './components/Panel';

import { useState } from 'react'

const MapsApp: React.FC = () => {
    const [stopID, setStopID] = useState('');


    return (
      <div className="relative flex flex-col max-w-4xl mx-auto h-screen">
        <div className="absolute top-0 left-0 z-10 w-full p-4 bg-transparent">
          <Search />
        </div>
        <Map onMapEvent={setStopID}/>
        <Panel stopID={stopID}/>
      </div>
    );
  };
  
  export default MapsApp;