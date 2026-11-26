// Package httpapi is the Gin adapter of the orders module. Handlers stay thin:
// parse the request, call the service, map the result. This package never
// imports package api. The server passes in a function that reads the
// authenticated user's id, so the module knows nothing about tokens.
package httpapi

import (
	"errors"
	"fmt"
	"log"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"

	"primestore_demo_backend/internal/orders/domain"
	"primestore_demo_backend/internal/orders/service"
)

// UserIDFunc returns the authenticated user's id for this request.
type UserIDFunc func(c *gin.Context) int32

type handler struct {
	svc    *service.Service
	userID UserIDFunc
}

// Register adds the orders routes. routes must already be behind the
// authentication middleware.
func Register(routes gin.IRoutes, svc *service.Service, userID UserIDFunc) {
	h := &handler{svc: svc, userID: userID}

	routes.POST("/cart/items", h.addCartItem)
	routes.PUT("/cart/items/:id", h.setCartItemQuantity)
	routes.DELETE("/cart/items/:id", h.removeCartItem)
	routes.GET("/cart", h.getCart)
}

// writeError maps a domain error to an HTTP response. notFound is the message
// used for domain.ErrNotFound, because "not found" means something different in
// each handler. Anything unexpected is logged and becomes a generic 500.
func writeError(c *gin.Context, err error, notFound, serverError string) {
	switch {
	case errors.Is(err, domain.ErrNotFound):
		c.JSON(http.StatusNotFound, gin.H{"error": notFound})
	case errors.Is(err, domain.ErrQuantityLimit):
		c.JSON(http.StatusBadRequest, gin.H{
			"error": fmt.Sprintf("quantity must be between 1 and %d", domain.MaxCartQuantity),
		})
	case errors.Is(err, domain.ErrInvalidUser):
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid user"})
	default:
		log.Printf("%s %s: %v", c.Request.Method, c.FullPath(), err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": serverError})
	}
}

// parseVariantID reads :id from the URL. It writes the 400 itself when the value
// is not a positive 32-bit integer (a bigger number must not wrap around).
func parseVariantID(c *gin.Context) (int32, bool) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 32)
	if err != nil || id <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid variant id"})
		return 0, false
	}
	return int32(id), true
}
