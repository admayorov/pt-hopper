import * as pmtiles from "pmtiles";
import maplibregl, { Map } from "maplibre-gl"
import { useEffect, useRef } from "react";

import "maplibre-gl/dist/maplibre-gl.css";

interface MapProps {
    stopID: string,
    setStopID: (info: string) => void;
}


function MapView(props: MapProps) {
    const mapContainerRef = useRef<any>();
    const mapObjectRef = useRef<Map>();

    useEffect(() => {
        let protocol = new pmtiles.Protocol()
        maplibregl.addProtocol("pmtiles", protocol.tile)

        const map = new maplibregl.Map({
            container: mapContainerRef.current,
            style: {
                "version": 8,
                "sources": {
                    "melbourne": {
                        "type": "vector",
                        "url": `pmtiles:///api/map/melbourne.pmtiles`
                    },
                    "ptv_stops": {
                        "type": "vector",
                        "url": `pmtiles:///api/map/ptv_stops.pmtiles`,
                        "promoteId": "stop_id"
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

                    // LABELS
                    {
                        "id": 'labels_vline',
                        "type": 'symbol',
                        "source": "ptv_stops",
                        "source-layer": "vline",
                        "layout": {
                            'text-field': '{stop_short_name}',
                            'text-size': 12,
                            'text-offset': [1, 0],
                            'text-anchor': 'left'
                        },
                        "paint": {
                            'text-color': '#ffffff'
                        }
                    },
                    {
                        "id": 'labels_metro',
                        "type": 'symbol',
                        "source": "ptv_stops",
                        "source-layer": "metro",
                        "layout": {
                            'text-field': '{stop_short_name}',
                            'text-size': 10,
                            'text-offset': [1, 0],
                            'text-anchor': 'left'
                        },
                        "paint": {
                            'text-color': '#ffffff'
                        },
                        "minzoom": 11
                    },
                    {
                        "id": 'labels_tram',
                        "type": 'symbol',
                        "source": "ptv_stops",
                        "source-layer": "tram",
                        "layout": {
                            'text-field': '{stop_short_name}',
                            'text-size': 10,
                            'text-offset': [1, 0],
                            'text-anchor': 'left'
                        },
                        "paint": {
                            'text-color': '#ffffff'
                        },
                        "minzoom": 13
                    },
                    {
                        "id": 'labels_bus',
                        "type": 'symbol',
                        "source": "ptv_stops",
                        "source-layer": "bus",
                        "layout": {
                            'text-field': '{stop_short_name}',
                            'text-size': 10,
                            'text-offset': [1, 0],
                            'text-anchor': 'left'
                        },
                        "paint": {
                            'text-color': '#ffffff'
                        },
                        "minzoom": 14
                    },

                    // STOPS
                    {
                        "id": "bus_stops",
                        "type": "circle",
                        "source": "ptv_stops",
                        "source-layer": "bus",
                        "paint": {
                            "circle-color": "#FF8200",
                            "circle-radius": 4
                        },
                        "minzoom": 14
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
                        "minzoom": 13

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

        mapObjectRef.current = map;

        map.addControl(new maplibregl.NavigationControl({ showCompass: true, showZoom: true }), 'bottom-right')

        map.on('click', (ev) => {
            console.log(ev.lngLat);
            console.log(map.getZoom())
        })

        const mapEvent = (ev: any) => {
            if (ev.features) {
                var feature = ev.features[0];
                console.log(feature.properties);
                if (feature.properties) {
                    props.setStopID(feature.properties.stop_id)
                }
                
            }
        }

        for (const layer of ['vline', 'metro', 'tram', 'bus']) {
            map.on('click', `${layer}_stops`, mapEvent);
            map.on('click', `labels_${layer}`, mapEvent);
        }

        return () => { map.remove() }

    }, [])

    useEffect(() => {
        const map = mapObjectRef.current;
        console.log("map will fly now to stop id " + props.stopID)
    }, [props.stopID])

    // todo: instead of storing just stopID, store the entire stop data in the React state

    return (
        <div ref={mapContainerRef} className="map-wrap w-full h-[80vh] bg-gray-200" />
    );

}

export default MapView;