package main

import (
	"database/sql"
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/api"
	"primestore_demo_backend/util"
)

const (
	dbDriver       = "postgres"
	dbSource       = "postgresql://postgres:secret@localhost:5433/primestore?sslmode=disable"
	serverAddress  = "0.0.0.0:8080"
	tokenSecretKey = "12345678901234567890123456789012" // dev only, move to env var later
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("no .env file found, relying on real environment variables")
	}

	conn, err := sql.Open(dbDriver, dbSource)
	if err != nil {
		log.Fatal("cannot connect to db:", err)
	}

	store := db.New(conn)
	tokenMaker := util.NewTokenMaker(tokenSecretKey)

	smtpPort, err := strconv.Atoi(os.Getenv("SMTP_PORT"))
	if err != nil {
		log.Fatal("invalid SMTP_PORT:", err)
	}
	mailer := util.NewMailer(
		os.Getenv("SMTP_HOST"),
		smtpPort,
		os.Getenv("SMTP_USERNAME"),
		os.Getenv("SMTP_PASSWORD"),
		os.Getenv("SMTP_FROM"),
	)

	server := api.NewServer(*store, tokenMaker, mailer)

	err = server.Start(serverAddress)
	if err != nil {
		log.Fatal("cannot start server:", err)
	}
}
