import React from 'react';
import Map from './components/Map';
import Search from './components/Search';
import Panel from './components/Panel';


const MapsApp: React.FC = () => {

  
    return (
      <div className="relative flex flex-col max-w-4xl mx-auto h-screen">
        <div className="absolute top-0 left-0 z-10 w-full p-4 bg-transparent">
          <Search />
        </div>
        <Map />
        <Panel />
      </div>
    );
  };
  
  export default MapsApp;