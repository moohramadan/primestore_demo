package main

import (
	"context"
	"database/sql"
	"log"
	"os"
	"strconv"

	"primestore_demo_backend/api"
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/util"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

const (
	dbDriver      = "postgres"
	serverAddress = "0.0.0.0:8080"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("no .env file found, relying on real environment variables")
	}

	dbSource := os.Getenv("DB_SOURCE")
	if dbSource == "" {
		log.Fatal("DB_SOURCE is not set")
	}

	tokenSecret := os.Getenv("TOKEN_SECRET")
	if len(tokenSecret) < 32 {
		log.Fatal("TOKEN_SECRET must be at least 32 characters")
	}

	conn, err := sql.Open(dbDriver, dbSource)
	if err != nil {
		log.Fatal("cannot connect to db:", err)
	}

	store := db.New(conn)
	tokenMaker := util.NewTokenMaker(tokenSecret)

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

	googleClientID := os.Getenv("GOOGLE_CLIENT_ID")
	if googleClientID == "" {
		log.Println("warning: GOOGLE_CLIENT_ID is not set, Google sign-in will reject every request")
	}
	bucket := os.Getenv("S3_BUCKET")
	if bucket == "" {
		log.Fatal("S3_BUCKET is not set")
	}
	images, err := util.NewImageStorage(context.Background(), bucket, os.Getenv("S3_PUBLIC_BASE_URL"))
	if err != nil {
		log.Fatal("cannot initialize image storage:", err)
	}

	server := api.NewServer(*store, conn, tokenMaker, mailer, googleClientID, images)

	err = server.Start(serverAddress)
	if err != nil {
		log.Fatal("cannot start server:", err)
	}
}
