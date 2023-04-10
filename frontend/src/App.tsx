import React from 'react'


import ReactDOM from 'react-dom/client'
import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import Search from './components/Search'
import Departures from './components/Departures'
import Map from './components/Map'
import './index.css'
import MapsApp from './MapsApp'

const router = createBrowserRouter([
  {
    path: "/",
    element: <Search />,
  },
  {
    path: "departures/:stop_gtfs_id/",
    element: <Departures />
  },
  {
    path: "map/",
    element: <Map />
  },
  {
    path: "mapsapp/",
    element: <MapsApp />
  },
])

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>,
)
