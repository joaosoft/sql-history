package __defining_columns

import (
	"database/sql"
	"fmt"
	"log"
	"testing"

	_ "github.com/lib/pq" // postgres driver
	"github.com/stretchr/testify/assert"
)

func Benchmark(b *testing.B) {
	driver := "postgres"
	dataSource := "postgres://postgres:postgres@localhost:7100/foursource?sslmode=disable"
	expectedAffectedRows := 10000
	modelSchemaName := "model"
	modelTableName := "example_zero"

	log.Printf("connecting database with driver [ %s ] and data source [ %s ]", driver, dataSource)
	db, err := sql.Open(driver, dataSource)
	if err != nil {
		log.Fatalf("error connecting to database: %s", err.Error())
	}

	tx, err := db.Begin()
	if err != nil {
		log.Fatalf("error creating database transaction: %s", err.Error())
	}

	count := 0
	for i := 1; i <= expectedAffectedRows; i++ {
		result, err := tx.Exec(
			fmt.Sprintf(`INSERT INTO %s.%s (id_example_zero, name, description) 
								VALUES ($1, $2, $3)`, modelSchemaName, modelTableName), i, fmt.Sprintf("name %d", i), fmt.Sprintf("name %d", i))
		if err != nil {
			log.Fatalf("error inserting on table %s.%s: %s", modelSchemaName, modelTableName, err.Error())
		}

		affectedRows, err := result.RowsAffected()
		if err != nil {
			log.Fatalf("error getting database rows number: %s", err.Error())
		}
		count += int(affectedRows)
	}

	assert.Equal(b, expectedAffectedRows, count, "The test should have inserted %d instead of %d inserted", expectedAffectedRows, count)

	if err = tx.Commit(); err != nil {
		log.Fatalf("error commiting database transaction: %s", err.Error())
	}
}
