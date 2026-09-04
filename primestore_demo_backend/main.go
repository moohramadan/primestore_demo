package main

import (
	"database/sql"
	"log"

	_ "github.com/lib/pq"
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/api"
)

const (
	dbDriver      = "postgres"
	dbSource      = "postgresql://postgres:secret@localhost:5433/primestore?sslmode=disable"
	serverAddress = "0.0.0.0:8080"
)

func main() {
	conn, err := sql.Open(dbDriver, dbSource)
	if err != nil {
		log.Fatal("cannot connect to db:", err)
	}

	store := db.New(conn)
	server := api.NewServer(*store)

	err = server.Start(serverAddress)
	if err != nil {
		log.Fatal("cannot start server:", err)
	}
}
