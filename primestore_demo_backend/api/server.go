package api

import (
	"github.com/gin-gonic/gin"
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/util"
)

type Server struct {
	store      db.Queries
	tokenMaker *util.TokenMaker
	mailer     *util.Mailer
	router     *gin.Engine
}

func NewServer(store db.Queries, tokenMaker *util.TokenMaker, mailer *util.Mailer) *Server {
	server := &Server{
		store:      store,
		tokenMaker: tokenMaker,
		mailer:     mailer,
	}
	router := gin.Default()

	router.POST("/users", server.createUser)
	router.POST("/users/login", server.login)
	router.POST("/users/verify-email/send", server.sendOtp)
	router.POST("/users/verify-email/confirm", server.confirmOtp)

	server.router = router
	return server
}

func (server *Server) Start(address string) error {
	return server.router.Run(address)
}
