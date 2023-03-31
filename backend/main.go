package main

import (
	"encoding/json"
	"log"
	"net/http"
	"pt-hopper/internal/ptv"
	"time"

	"github.com/julienschmidt/httprouter"
)

func main() {
	log.Println("Starting Go backend...")

	ptv.InitDB(false)
	log.Println("DB initialised")

	log.Println("Starting web server now")

	router := httprouter.New()

	// PMTILES FILE
	router.GET("/map", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

		http.ServeFile(w, r, "local/pm/melbourne.pmtiles")
	})

	// STOPS
	router.GET("/stops", func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

		query := r.URL.Query().Get("q")

		mode := ptv.AnyRouteType
		stops, err := ptv.SearchGTFSStops(query, mode, false)
		if err != nil {
			log.Fatalf("SearchGTFSStops returned an error: %v", err)
		}

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
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

		stopId := ps.ByName("id")

		mode := ptv.AnyRouteType
		stops, err := ptv.DeparturesByGTFSID(stopId, mode, time.Now().Add(-1*time.Minute))
		if err != nil {
			log.Fatalf("DeparturesByGTFSID returned an error: %v", err)
		}

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

	// Start the server
	log.Fatal(http.ListenAndServe(":8080", router))
}
