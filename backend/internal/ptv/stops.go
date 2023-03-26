package ptv

import (
	"database/sql"
	"fmt"
)

type StopGTFS struct {
	Mode       string `json:"mode,omitempty"`
	StopGTFSID string `json:"stop_gtfs_id,omitempty"`
	Name       string `json:"name,omitempty"`
	RoadName   string `json:"road_name,omitempty"`
	Suburb     string `json:"suburb,omitempty"`
	Latitude   string `json:"latitude,omitempty"`
	Longitude  string `json:"longitude,omitempty"`
}

func SearchGTFSStops(searchTerm string, mode RouteType, includeSuburb bool) ([]StopGTFS, error) {
	limit := 10

	rows, err := dbData.stmtGetStops.Query(
		sql.Named("stop_regex", searchTerm),
		sql.Named("mode", mode.asGTFSstring),
		sql.Named("limit", limit),
	)
	if err != nil {
		return nil, fmt.Errorf("searchGTFS query exec error: %v", err)
	}
	defer rows.Close()

	results := make([]StopGTFS, 0)
	for rows.Next() {
		var res StopGTFS
		err := rows.Scan(&res.Mode, &res.StopGTFSID, &res.Name, &res.RoadName, &res.Suburb, &res.Latitude, &res.Longitude)
		if err != nil {
			return nil, fmt.Errorf("searchGTFS query result rows scan error: %v", err)
		}

		results = append(results, res)
	}

	return results, nil
}
