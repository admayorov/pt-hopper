import React from 'react'


import ReactDOM from 'react-dom/client'
import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import Search from './Search'
import Departures from './Departures'
import Map from './Map'
import './index.css'

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
  }
])

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>,
)
