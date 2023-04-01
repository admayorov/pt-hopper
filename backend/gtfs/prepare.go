package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"regexp"
	"strings"

	_ "github.com/mattn/go-sqlite3"
)

type stopRow struct {
	StopID        string  `json:"stop_id,omitempty"`
	StopName      string  `json:"stop_name,omitempty"`
	StopMode      string  `json:"stop_mode,omitempty"`
	StopNumber    string  `json:"stop_number,omitempty"`
	StopShortName string  `json:"stop_short_name,omitempty"`
	StopRoadName  string  `json:"stop_road_name,omitempty"`
	StopSuburb    string  `json:"stop_suburb,omitempty"`
	StopLat       float32 `json:"stop_latitude,omitempty"`
	StopLon       float32 `json:"stop_longitude,omitempty"`
}

type GeoJSONGeometry struct {
	Type        string    `json:"type"`
	Coordinates []float32 `json:"coordinates"`
}

type GeoJSONFeature struct {
	Type       string                 `json:"type"`
	Geometry   GeoJSONGeometry        `json:"geometry"`
	Properties map[string]interface{} `json:"properties"`
}

type GeoJSON struct {
	Type     string           `json:"type"`
	Features []GeoJSONFeature `json:"features"`
}

func stopRowsToGeoJSON(stopRows []stopRow) GeoJSON {
	features := make([]GeoJSONFeature, len(stopRows))

	for i, stop := range stopRows {
		geometry := GeoJSONGeometry{
			Type:        "Point",
			Coordinates: []float32{stop.StopLon, stop.StopLat},
		}

		properties := map[string]interface{}{
			"stop_id":         stop.StopID,
			"stop_name":       stop.StopName,
			"stop_mode":       stop.StopMode,
			"stop_number":     stop.StopNumber,
			"stop_short_name": stop.StopShortName,
			"stop_road_name":  stop.StopRoadName,
			"stop_suburb":     stop.StopSuburb,
		}

		features[i] = GeoJSONFeature{
			Type:       "Feature",
			Geometry:   geometry,
			Properties: properties,
		}
	}

	return GeoJSON{
		Type:     "FeatureCollection",
		Features: features,
	}
}

// type apiRoute struct {
// 	RouteAPIMode   int    `json:"route_type"`
// 	RouteAPIID     int    `json:"route_id"`
// 	RouteName      string `json:"route_name"`
// 	RouteNumber    string `json:"route_number"`
// 	RouteGTFSID    string `json:"route_gtfs_id"`
// 	RouteAPIGTFSID string
// }

// type apiRouteList struct {
// 	Routes []apiRoute `json:"routes"`
// }

// Updates the sqlite db file, performing cleanup on the stops table
// The stop name is parsed to extract the stop name, road name and suburb where applicable
// Note: PTV GTFS data is poor quality, around 20 or so stops do not follow the naming convention
// and are skipped for processing.
func updateStopNames(db *sql.DB) {
	query := "SELECT mode, stop_id, stop_name, stop_lat, stop_lon from stops;"

	rows, err := db.Query(query)
	if err != nil {
		log.Fatal("error querying:", err)
	}

	stops := make([]stopRow, 0)

	for rows.Next() {
		var stop stopRow
		err = rows.Scan(&stop.StopMode, &stop.StopID, &stop.StopName, &stop.StopLat, &stop.StopLon)
		if err != nil {
			log.Fatal("error scanning row:", err)
		}

		stops = append(stops, stop)
	}

	log.Printf("Select complete, loaded %d stops", len(stops))

	reVlineMetro := regexp.MustCompile(`^(.+)\s*Railway Station\s*\((.+)\)$`)
	reTram := regexp.MustCompile(`^([^/]*)(?:/([^/]+(?:/[^/]+)*))?\s*\(\s*([^\]]+)\s*\)$`)
	// reTram := regexp.MustCompile(`^([^-]+)-([^/]*)(?:/([^/]+(?:/[^/]+)*))?\s*\(\s*([^\]]+)\s*\)$`)
	reBus := regexp.MustCompile(`(.+?)(?:/(.+))?\s*\((.*(?:\(.*\)).*|[^()]+)\)$`)

	for i := range stops {
		switch stops[i].StopMode {
		case "vline":
			fallthrough
		case "metro":
			match := reVlineMetro.FindStringSubmatch(stops[i].StopName)
			if match == nil {
				log.Fatalf("metro/vline regex did not match '%s'", stops[i].StopName)
			}
			stops[i].StopShortName = match[1]
			stops[i].StopSuburb = match[2]
		case "tram":
			match := reTram.FindStringSubmatch(stops[i].StopName)
			if match == nil {
				log.Fatalf("tram regex did not match '%s'", stops[i].StopName)
			}
			// res.StopNumber = match[1]
			stops[i].StopShortName = match[1]
			stops[i].StopRoadName = match[2]
			stops[i].StopSuburb = match[3]
		case "bus":
			if !strings.ContainsRune(stops[i].StopName, '(') {
				break
			}
			match := reBus.FindStringSubmatch(stops[i].StopName)
			if match == nil {
				log.Fatalf("bus regex did not match '%s'", stops[i].StopName)
			}
			stops[i].StopShortName = match[1]
			stops[i].StopRoadName = match[2]
			stops[i].StopSuburb = match[3]
		default:
			log.Fatalf("bad mode %s", stops[i].StopMode)
		}
	}

	log.Println("Stop struct data update complete, ready to update DB")

	updateQuery := `
		UPDATE stops SET
		stop_short_name = ?,
		stop_road_name = ?,
		stop_suburb = ?
		WHERE stop_id = ?;
	`

	tx, err := db.Begin()
	if err != nil {
		log.Fatal(err)
	}
	defer tx.Rollback()

	updateStmt, err := tx.Prepare(updateQuery)
	if err != nil {
		log.Fatal(err)
	}

	for _, stop := range stops {
		_, err := updateStmt.Exec(stop.StopShortName, stop.StopRoadName, stop.StopSuburb, stop.StopID)
		if err != nil {
			log.Fatal(err)
		}
	}

	tx.Commit()

	log.Println("Done updating stop names")

	log.Println("Now starting GeoJSON creation")

	geoJSON := stopRowsToGeoJSON(stops)
	geoJSONBytes, err := json.MarshalIndent(geoJSON, "", "  ")
	if err != nil {
		log.Fatal(err)
	}

	err = os.WriteFile("local/map/ptv_stops.json", geoJSONBytes, 0644)
	if err != nil {
		log.Fatal(err)
	}

}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("No arguments provided")
		return
	}

	dbFilePath := os.Args[1]
	fmt.Println("dbFilePath=", dbFilePath)

	db, err := sql.Open("sqlite3", dbFilePath)
	if err != nil {
		log.Fatal("failed to open sqlite database file:", err)
	}

	updateStopNames(db)

	log.Println("All done.")

}
