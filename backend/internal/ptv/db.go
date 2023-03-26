package ptv

import (
	"database/sql"
	"fmt"
	"io/ioutil"
	"log"
	"regexp"

	sqlite3 "github.com/mattn/go-sqlite3"
)

const dbFilePath string = "local/gtfs/gtfs.db"

type dbDataGTFS struct {
	db                         *sql.DB
	stmtGetStops               *sql.Stmt
	stmtGetDeparturesForStopID *sql.Stmt
	stmtGetStopTimes           *sql.Stmt
}

var dbData *dbDataGTFS

func prepareQueryFromFile(db *sql.DB, filename string) (*sql.Stmt, error) {
	query, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("error reading %s: %v", filename, err)
	}
	stmt, err := db.Prepare(string(query))
	if err != nil {
		return nil, fmt.Errorf("error preparing query from %s: %v", filename, err)
	}

	return stmt, nil
}

// Open the database and prepare statements, store pointers in dbData
func InitDB(reload bool) error {
	if !reload && dbData != nil {
		log.Println("Database has already been initialised")
		return nil
	}

	// Prepare DB driver:
	regexMatch := func(re, s string) (bool, error) {
		return regexp.MatchString(re, s)
	}

	regexExtract := func(re, s string) (string, error) {
		rc, err := regexp.Compile(re)
		if err != nil {
			return "", err
		}

		match := rc.Find([]byte(s))
		if match == nil {
			return "", nil
		}
		return string(match), nil
	}

	connectHook := func(conn *sqlite3.SQLiteConn) error {
		err := conn.RegisterFunc("regexp", regexMatch, true)
		if err != nil {
			return err
		}

		err = conn.RegisterFunc("regex_extract", regexExtract, true)
		if err != nil {
			return err
		}

		return nil
	}

	sql.Register("sqlite3_with_go_regex",
		&sqlite3.SQLiteDriver{
			ConnectHook: connectHook,
		})

	db, err := sql.Open("sqlite3_with_go_regex", dbFilePath)
	if err != nil {
		return fmt.Errorf("failed to open sqlite database file: %v", err)
	}

	// Prepare Queries:
	stmtGetStops, err := prepareQueryFromFile(db, "internal/ptv/sql/stops.sql")
	if err != nil {
		return err
	}
	stmtGetDeparturesForStopID, err := prepareQueryFromFile(db, "internal/ptv/sql/departures.sql")
	if err != nil {
		return err
	}
	stmtGetStopTimes, err := prepareQueryFromFile(db, "internal/ptv/sql/stop_times.sql")
	if err != nil {
		return err
	}

	// Init dbData struct:
	dbData = &dbDataGTFS{
		db,
		stmtGetStops,
		stmtGetDeparturesForStopID,
		stmtGetStopTimes,
	}

	return nil

}

func CloseDB() {
	if dbData == nil {
		log.Fatal("Attempted to call CloseDB while dbData is nil")
	}

	dbData.db.Close()
}
