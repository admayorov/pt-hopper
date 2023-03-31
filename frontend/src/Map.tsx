import * as pmtiles from "pmtiles";
import maplibregl from "maplibre-gl"
import { useEffect, useRef } from "react";


function Map() {

    const mapRef = useRef<any>();

    useEffect(() => {
        const map = new maplibregl.Map({
            container: mapRef.current,
            style: {
                "version": 8,
                "sources": {
                    "melbourne": {
                        "type": "vector",
                        "url": `pmtiles://${import.meta.env.VITE_BACKEND_HOST}/map`
                    }
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
                        "id": "pois",
                        "type": "circle",
                        "source": "melbourne",
                        "source-layer": "pois",
                        "paint": {
                            "circle-color": "#FFD900",
                            "circle-radius": 3
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
                    }
                ]
                ,
                center: [144.93255155345383, -37.82129634139583],
                zoom: 11,

            }
        })

        let protocol = new pmtiles.Protocol()
        maplibregl.addProtocol("pmtiles", protocol.tile)

        map.addControl(new maplibregl.NavigationControl({ showCompass: true, showZoom: true }), 'top-right')

        map.on('click', 'melbourne-earth', (ev) => { console.log(map.getZoom()) })

        return () => { map.remove() }

    }, [])

    return (
        <div className="map-wrap h-screen">
            <div ref={mapRef} className="map h-4/5 w-4/5 bg-gray-100 mx-auto" />
        </div>
    );

}

export default Map;