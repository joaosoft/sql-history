package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq" // postgres driver
)

func main() {
	driver := "postgres"
	dataSource := "postgres://postgres:postgres@localhost:7100/foursource?sslmode=disable"

	cleanTables := map[string][]string{
		"model":   []string{"example_zero", "example_one", "example_two", "example_three", "example_four"},
		"history": []string{"example_one", "example_two", "example_three", "example_four"},
	}

	log.Printf("connecting database with driver [ %s ] and data source [ %s ]", driver, dataSource)
	db, err := sql.Open(driver, dataSource)
	if err != nil {
		log.Fatalf("error connecting to database: %s", err.Error())
	}

	for schema, tables := range cleanTables {
		for _, table := range tables {
			log.Printf("cleaning %s.%s", schema, table)
			_, err = db.Exec(fmt.Sprintf(`DELETE FROM %s.%s`, schema, table))
			if err != nil {
				log.Fatalf("error getting database history table count: %s", err.Error())
			}
		}
	}

	log.Printf("done!")
}
