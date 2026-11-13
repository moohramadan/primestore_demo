package main

import (
	"context"
	"database/sql"
	"log"

	"primestore_demo_backend/api"
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/util"

	_ "github.com/lib/pq"
)

func main() {
	config, err := util.LoadConfig(".")
	if err != nil {
		log.Fatal("cannot load config:", err)
	}

	if err := config.Validate(); err != nil {
		log.Fatal("invalid config:", err)
	}

	conn, err := sql.Open(config.DBDriver, config.DBSource)
	if err != nil {
		log.Fatal("invalid db config:", err)
	}
	defer conn.Close()

	if err := conn.Ping(); err != nil {
		log.Fatal("cannot reach db:", err)
	}

	store := db.New(conn)
	tokenMaker := util.NewTokenMaker(config.TokenSecret)

	mailer := util.NewMailer(
		config.SMTPHost,
		config.SMTPPort,
		config.SMTPUsername,
		config.SMTPPassword,
		config.SMTPFrom,
	)

	if config.GoogleClientID == "" {
		log.Println("warning: GOOGLE_CLIENT_ID is not set, Google sign-in will reject every request")
	}

	images, err := util.NewImageStorage(context.Background(), config.S3Bucket, config.S3PublicBaseURL)
	if err != nil {
		log.Fatal("cannot initialize image storage:", err)
	}

	server := api.NewServer(*store, conn, tokenMaker, mailer, config.GoogleClientID, images)

	if err := server.Start(config.HTTPServerAddress); err != nil {
		log.Fatal("cannot start server:", err)
	}
}