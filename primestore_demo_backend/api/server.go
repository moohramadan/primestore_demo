package api

import (
	"database/sql"
	db "primestore_demo_backend/db/sqlc"
	ordersadapters "primestore_demo_backend/internal/orders/adapters"
	ordershttpapi "primestore_demo_backend/internal/orders/httpapi"
	ordersservice "primestore_demo_backend/internal/orders/service"
	ordersstore "primestore_demo_backend/internal/orders/store"
	"primestore_demo_backend/util"
	"time"

	"github.com/gin-gonic/gin"
)

type Server struct {
	store          db.Queries
	conn           *sql.DB
	tokenMaker     *util.TokenMaker
	mailer         *util.Mailer
	googleClientID string
	router         *gin.Engine
	images         *util.ImageStorage
}

func NewServer(store db.Queries, conn *sql.DB, tokenMaker *util.TokenMaker, mailer *util.Mailer, googleClientID string, images *util.ImageStorage) *Server {
	server := &Server{
		store:          store,
		conn:           conn,
		images:         images,
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
	catalog := ordersadapters.NewCatalogAdapter(&server.store, server.images.PublicURL)
	orderStore := ordersstore.New(conn)
	userID := func(ctx *gin.Context) int32 {
		return int32(ctx.MustGet(authorizationPayloadKey).(*util.UserClaims).UserID)
	}
	cartService := ordersservice.New(orderStore, catalog)
	ordershttpapi.Register(authRoutes, cartService, userID)
	checkout := ordersservice.NewCheckoutService(ordersservice.CheckoutDeps{
		Cart:      orderStore,
		Orders:    orderStore,
		Catalog:   catalog,
		Inventory: ordersadapters.NewInventoryAdapter(conn, 15*time.Minute),
		Addresses: ordersadapters.NewAddressesAdapter(db.New(conn)),
	}, ordersservice.CheckoutConfig{
		DeliveryFee: 0, // flat fee in cents: 50000 means 500.00
	})
	checkoutLimiter := NewRateLimiter(10, 15*time.Minute)
	ordershttpapi.RegisterCheckout(authRoutes, checkout, userID, rateLimitMiddleware(checkoutLimiter))
	authRoutes.GET("/users/me", server.getMe)
	emailChangeRequestLimiter := NewRateLimiter(3, 10*time.Minute)
	authRoutes.POST("/users/me/email/request", rateLimitMiddleware(emailChangeRequestLimiter), server.requestEmailChange)
	emailChangeConfirmLimiter := NewRateLimiter(5, 10*time.Minute)
	authRoutes.POST("/users/me/email/confirm", rateLimitMiddleware(emailChangeConfirmLimiter), server.confirmEmailChange)
	router.GET("/categories", server.listCategories)
	router.GET("/products/featured", server.listFeaturedProducts)
	router.GET("/products/category/:id", server.listProductsByCategory)
	addressLimiter := NewRateLimiter(5, 15*time.Minute)
	authRoutes.POST("/addresses", rateLimitMiddleware(addressLimiter), server.createAddress)
	authRoutes.PUT("/addresses/:id/default", server.setDefaultAddress)
	authRoutes.GET("/addresses", server.listAddresses)
	authRoutes.POST("/wishlist", server.addToWishlist)
	authRoutes.DELETE("/wishlist/:product_id", server.removeFromWishlist)
	authRoutes.GET("/wishlist", server.listWishlist)
	authRoutes.GET("/wishlist/ids", server.listWishlistedIDs)
	sellerLimiter := NewRateLimiter(3, 15*time.Minute)
	authRoutes.POST("/seller/profile", rateLimitMiddleware(sellerLimiter), server.createSellerProfile)
	authRoutes.GET("/seller/profile", server.getSellerProfile)
	router.GET("/brands", server.listBrands)
	uploadLimiter := NewRateLimiter(20, 15*time.Minute)
	authRoutes.POST("/seller/products/upload-urls", rateLimitMiddleware(uploadLimiter), sellerOnly(server), server.createProductUploadURLs)
	// Cleanup is called once per removed photo (up to 5 per product), so allow more than uploads.
	cleanupLimiter := NewRateLimiter(60, 15*time.Minute)
	authRoutes.POST("/seller/products/upload-cleanup", rateLimitMiddleware(cleanupLimiter), sellerOnly(server), server.deleteUnusedProductImage)
	productLimiter := NewRateLimiter(20, 15*time.Minute)
	authRoutes.POST("/seller/products", rateLimitMiddleware(productLimiter), sellerOnly(server), server.createProduct)
	authRoutes.GET("/seller/products", sellerOnly(server), server.listSellerProducts)
	authRoutes.PUT("/seller/products/:id", rateLimitMiddleware(productLimiter), sellerOnly(server), server.updateSellerProduct)
	server.router = router
	return server
}

func (server *Server) Start(address string) error {
	return server.router.Run(address)
}
