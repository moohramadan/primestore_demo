package api

import (
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/util"
	"time"

	"github.com/gin-gonic/gin"
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
	loginLimiter := NewRateLimiter(10, 15*time.Minute)
	router.POST("/users/login", rateLimitMiddleware(loginLimiter), server.login)
	router.POST("/users/google-signin", server.googleSignIn)
	verifyEmailLimiter := NewRateLimiter(3, 10*time.Minute)
	router.POST("/users/verify-email/send", rateLimitMiddleware(verifyEmailLimiter), server.sendOtp)
	otpConfirmLimiter := NewRateLimiter(5, 10*time.Minute)
	router.POST("/users/verify-email/confirm", rateLimitMiddleware(otpConfirmLimiter), server.confirmOtp)
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
