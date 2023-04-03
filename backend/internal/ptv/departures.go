package ptv

import (
	"database/sql"
	"fmt"
	"log"
	"time"
)

type DepartureGTFS struct {
	Mode          string `json:"mode,omitempty"`
	TripID        string `json:"trip_id,omitempty"`
	ArrivalTime   string `json:"arrival_time,omitempty"`
	DepartureTime string `json:"departure_time,omitempty"`
	TripHeadsign  string `json:"trip_headsign,omitempty"`
	RouteName     string `json:"route_name,omitempty"`
	RouteID       string `json:"route_id,omitempty"`
	// RouteAPIID    string `json:"route_api_id,omitempty"`
	// IDDepID       string `json:"id_dep_id,omitempty"`
}

func truncateTimeToDay(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
}

func DeparturesByGTFSID(gtfsStopID string, startTime time.Time) (map[string][]*DepartureGTFS, error) {
	_t := time.Now()
	date := startTime.Format("20060102")

	t1 := startTime
	t2 := t1.Add(time.Hour * 2)
	nextMidnight := truncateTimeToDay(t1).Add(24 * time.Hour)

	if nextMidnight.Before(t2) {
		t2 = nextMidnight.Add(-1 * time.Second)
	}

	t1s := t1.Format("15:04:05")
	t2s := t2.Format("15:04:05")

	log.Println("Date range:", date, t1s, t2s)

	rows, err := dbData.stmtGetDeparturesForStopID.Query(
		sql.Named("stop_id", gtfsStopID),
		sql.Named("date", date),
		sql.Named("int_weekday", startTime.Weekday()),
		sql.Named("dep_time_min", t1s),
		sql.Named("dep_time_max", t2s),
	)
	if err != nil {
		return nil, fmt.Errorf("departuresByGTFSID query exec error: %v", err)
	}
	fmt.Printf("DB call took: %s \n", time.Since(_t))
	_t = time.Now()

	// results := make([]DepartureGTFS, 0)
	results := make(map[string][]*DepartureGTFS)
	for rows.Next() {
		var res DepartureGTFS
		err := rows.Scan(
			&res.Mode,
			&res.TripID,
			&res.ArrivalTime,
			&res.DepartureTime,
			&res.TripHeadsign,
			&res.RouteName,
			&res.RouteID,
			// &res.RouteAPIID,
			// &res.IDDepID,
		)
		if err != nil {
			return nil, fmt.Errorf("departuresByGTFSID query result rows scan error: %v", err)
		}

		results[res.RouteName] = append(results[res.RouteName], &res)
	}

	fmt.Printf("Struct wrangling took: %s \n", time.Since(_t))
	return results, nil
}
