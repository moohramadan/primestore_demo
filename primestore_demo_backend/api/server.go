package api

import (
	"github.com/gin-gonic/gin"
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/util"
)

type Server struct {
	store          db.Queries
	tokenMaker     *util.TokenMaker
	mailer         *util.Mailer
	googleClientID string
	router         *gin.Engine
}

func NewServer(store db.Queries, tokenMaker *util.TokenMaker, mailer *util.Mailer, googleClientID string) *Server {
	server := &Server{
		store:          store,
		tokenMaker:     tokenMaker,
		mailer:         mailer,
		googleClientID: googleClientID,
	}
	router := gin.Default()

	router.POST("/users", server.createUser)
	router.POST("/users/login", server.login)
	router.POST("/users/google-signin", server.googleSignIn)
	router.POST("/users/verify-email/send", server.sendOtp)
	router.POST("/users/verify-email/confirm", server.confirmOtp)
	router.POST("/users/refresh", server.refresh)
	router.POST("/users/logout", server.logout)
	authRoutes := router.Group("/").Use(authMiddleware(server))
	authRoutes.GET("/users/me", server.getMe)
	router.GET("/categories", server.listCategories)
	router.GET("/products/featured", server.listFeaturedProducts)
	authRoutes.POST("/wishlist", server.addToWishlist)
	authRoutes.DELETE("/wishlist/:product_id", server.removeFromWishlist)
	authRoutes.GET("/wishlist", server.listWishlist)
	authRoutes.GET("/wishlist/ids", server.listWishlistedIDs)

	server.router = router
	return server
}

func (server *Server) Start(address string) error {
	return server.router.Run(address)
}
