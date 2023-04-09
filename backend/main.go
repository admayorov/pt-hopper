package main

import (
	"encoding/json"
	"log"
	"net/http"
	"pt-hopper/internal/ptv"
	"time"

	"github.com/julienschmidt/httprouter"
)

func setCORSheaders(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "GET")
	(*w).Header().Set("Access-Control-Allow-Headers", "Content-Type")
}

func main() {
	log.Println("Starting Go backend...")

	ptv.InitDB(false)
	log.Println("DB initialised")

	log.Println("Starting web server now")

	router := httprouter.New()

	// PMTILES FILE
	router.GET("/map/melbourne.pmtiles", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		setCORSheaders(&w)

		http.ServeFile(w, r, "local/map/melbourne.pmtiles")
	})

	// PMTILES FILE
	router.GET("/map/ptv_stops.pmtiles", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		setCORSheaders(&w)

		http.ServeFile(w, r, "local/map/ptv_stops.pmtiles")
	})

	// GEOJSON FILE
	router.GET("/map/ptv_stops.json", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		setCORSheaders(&w)

		http.ServeFile(w, r, "local/map/ptv_stops.json")
	})

	// STOPS
	router.GET("/stops", func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
		setCORSheaders(&w)

		query := r.URL.Query().Get("q")

		mode := ptv.AnyRouteType
		stops, err := ptv.SearchGTFSStops(query, mode, false)
		if err != nil {
			log.Fatalf("SearchGTFSStops returned an error: %v", err)
		}

		log.Printf("Query %s: %d results \n", query, len(stops))

		// Encode the User struct as JSON
		jsonBytes, err := json.Marshal(stops)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		// Set the Content-Type header to application/json
		w.Header().Set("Content-Type", "application/json")

		// Write the JSON response
		w.Write(jsonBytes)
	})

	// DEPARTURES
	router.GET("/departures/:id/", func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
		setCORSheaders(&w)

		stopId := ps.ByName("id")

		deps, err := ptv.DeparturesByGTFSID(stopId, time.Now().Add(-1*time.Minute))
		if err != nil {
			log.Fatalf("DeparturesByGTFSID returned an error: %v", err)
		}

		log.Printf("Stop %s: %d results \n", stopId, len(deps))

		// Encode the User struct as JSON
		jsonBytes, err := json.Marshal(deps)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		// Set the Content-Type header to application/json
		w.Header().Set("Content-Type", "application/json")

		// Write the JSON response
		w.Write(jsonBytes)
	})

	// Start the server
	log.Fatal(http.ListenAndServe(":8080", router))
}
