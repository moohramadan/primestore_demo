package api

import (
	"github.com/gin-gonic/gin"
	db "primestore_demo_backend/db/sqlc"
)

// Server serves HTTP requests for our banking service.
type Server struct {
	store  db.Queries
	router *gin.Engine
}

// NewServer creates a new HTTP server and sets up routing.
func NewServer(store db.Queries) *Server {
	server := &Server{store: store}
	router := gin.Default()

	router.POST("/users", server.createUser)
	router.POST("/login", server.login)

	server.router = router
	return server
}

// Start runs the HTTP server on the given address
func (server *Server) Start(address string) error {
	return server.router.Run(address)
}
