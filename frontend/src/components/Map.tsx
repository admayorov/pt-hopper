import * as pmtiles from "pmtiles";
import maplibregl from "maplibre-gl"
import { useEffect, useRef } from "react";

import "maplibre-gl/dist/maplibre-gl.css";


function Map() {

    const mapRef = useRef<any>();

    useEffect(() => {
        let protocol = new pmtiles.Protocol()
        maplibregl.addProtocol("pmtiles", protocol.tile)

        const map = new maplibregl.Map({
            container: mapRef.current,
            style: {
                "version": 8,
                "sources": {
                    "melbourne": {
                        "type": "vector",
                        "url": `pmtiles:///api/map/melbourne.pmtiles`
                    },
                    "ptv_stops": {
                        "type": "vector",
                        "url": `pmtiles:///api/map/ptv_stops.pmtiles`
                    },
                },
                "glyphs": "https://demotiles.maplibre.org/font/{fontstack}/{range}.pbf",
                "layers": [
                    {
                        "id": "background",
                        "type": "background",
                        "paint": {
                            "background-color": "#222"
                        }
                    },
                    {
                        "id": "water",
                        "type": "fill",
                        "source": "melbourne",
                        "source-layer": "water",
                        "paint": {
                            "fill-color": "#182A35"
                        }
                    },
                    {
                        "id": "land",
                        "type": "fill",
                        "source": "melbourne",
                        "source-layer": "land",
                        "paint": {
                            "fill-color": "#16262E"
                        }
                    },
                    {
                        "id": "roads",
                        "type": "line",
                        "source": "melbourne",
                        "source-layer": "roads",
                        "paint": {
                            "line-color": "#4D4D4D",
                            "line-width": 1
                        }
                    },
                    {
                        "id": "buildings",
                        "type": "fill",
                        "source": "melbourne",
                        "source-layer": "buildings",
                        "paint": {
                            "fill-color": "#232323"
                        }
                    },
                    {
                        "id": "mask",
                        "type": "fill",
                        "source": "melbourne",
                        "source-layer": "mask",
                        "paint": {
                            "fill-color": "#222"
                        }
                    },
                    {
                        "id": "transit",
                        "type": "line",
                        "source": "melbourne",
                        "source-layer": "transit",
                        "paint": {
                            "line-color": "#DD0",
                            "line-width": 1
                        }
                    },
                    {
                        "id": "bus_stops",
                        "type": "circle",
                        "source": "ptv_stops",
                        "source-layer": "bus",
                        "paint": {
                            "circle-color": "#FF8200",
                            "circle-radius": 4
                        },
                        "minzoom": 13
                    },
                    {
                        "id": "tram_stops",
                        "type": "circle",
                        "source": "ptv_stops",
                        "source-layer": "tram",
                        "paint": {
                            "circle-color": "#78BE20",
                            "circle-radius": 4
                        },
                        "minzoom": 11

                    },
                    {
                        "id": "metro_stops",
                        "type": "circle",
                        "source": "ptv_stops",
                        "source-layer": "metro",
                        "paint": {
                            "circle-color": "#0072CE",
                            "circle-radius": 4
                        },
                        "minzoom": 9
                    },
                    {
                        "id": "vline_stops",
                        "type": "circle",
                        "source": "ptv_stops",
                        "source-layer": "vline",
                        "paint": {
                            "circle-color": "#8F1A95",
                            "circle-radius": 4
                        }
                    },
                ]
                ,
                center: [144.93255155345383, -37.82129634139583],
                zoom: 11,

            }
        })

        map.addControl(new maplibregl.NavigationControl({ showCompass: true, showZoom: true }), 'top-right')

        map.on('click', (ev) => {
            console.log(ev.lngLat);
            console.log(map.getZoom())
        })

        return () => { map.remove() }

    }, [])

    return (
        <div className="map-wrap h-screen">
            <div ref={mapRef} className="map h-full w-full bg-gray-100 mx-auto" />
        </div>
    );

}

export default Map;