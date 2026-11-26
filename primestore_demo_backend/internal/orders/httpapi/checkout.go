package httpapi

import (
	"context"
	"errors"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	"primestore_demo_backend/internal/orders/domain"
	"primestore_demo_backend/internal/orders/service"
)

const (
	idempotencyHeader = "Idempotency-Key"

	// A checkout that takes longer than this is abandoned (and its stock released).
	// Stock reservations last far longer, so this can never outlive a reservation.
	checkoutTimeout = 30 * time.Second
)

type checkoutHandler struct {
	svc    *service.CheckoutService
	userID UserIDFunc
}

// RegisterCheckout adds POST /checkout. routes must already be behind the
// authentication middleware. Any extra middleware (a rate limiter, for example)
// runs before the handler.
func RegisterCheckout(routes gin.IRoutes, svc *service.CheckoutService, userID UserIDFunc, middleware ...gin.HandlerFunc) {
	h := &checkoutHandler{svc: svc, userID: userID}

	handlers := append(append([]gin.HandlerFunc{}, middleware...), h.checkout)
	routes.POST("/checkout", handlers...)
}

type checkoutRequest struct {
	AddressID int64 `json:"address_id" binding:"required,min=1"`
}

func (h *checkoutHandler) checkout(c *gin.Context) {
	var req checkoutRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx, cancel := context.WithTimeout(c.Request.Context(), checkoutTimeout)
	defer cancel()

	res, err := h.svc.Checkout(ctx, h.userID(c), req.AddressID, c.GetHeader(idempotencyHeader))
	if err != nil {
		writeCheckoutError(c, err)
		return
	}

	// 201 for a new order, 200 when this key had already produced it.
	status := http.StatusCreated
	if res.Replayed {
		status = http.StatusOK
	}
	c.JSON(status, newOrderResponse(res.Order))
}

func writeCheckoutError(c *gin.Context, err error) {
	var outOfStock *domain.OutOfStockError
	var unavailable *domain.ItemUnavailableError

	switch {
	case errors.As(err, &outOfStock):
		c.JSON(http.StatusConflict, gin.H{"error": "not enough stock", "variant_id": outOfStock.VariantID})
	case errors.As(err, &unavailable):
		c.JSON(http.StatusConflict, gin.H{"error": "an item in your cart is no longer available", "variant_id": unavailable.VariantID})
	case errors.Is(err, domain.ErrOutOfStock):
		c.JSON(http.StatusConflict, gin.H{"error": "not enough stock"})
	case errors.Is(err, domain.ErrItemUnavailable):
		c.JSON(http.StatusConflict, gin.H{"error": "an item in your cart is no longer available"})
	case errors.Is(err, domain.ErrEmptyCart):
		c.JSON(http.StatusBadRequest, gin.H{"error": "cart is empty"})
	case errors.Is(err, domain.ErrNotFound):
		c.JSON(http.StatusNotFound, gin.H{"error": "address not found"})
	case errors.Is(err, domain.ErrInvalidIdempotencyKey):
		c.JSON(http.StatusBadRequest, gin.H{"error": "Idempotency-Key header is required: 8 to 64 characters, letters, digits, - or _"})
	case errors.Is(err, domain.ErrReservationExpired):
		c.JSON(http.StatusConflict, gin.H{"error": "checkout took too long, please try again"})
	case errors.Is(err, domain.ErrInvalidAmount):
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": "order amount is not valid"})
	case errors.Is(err, domain.ErrInvalidUser):
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid user"})
	case errors.Is(err, context.DeadlineExceeded):
		log.Printf("%s %s: %v", c.Request.Method, c.FullPath(), err)
		c.JSON(http.StatusGatewayTimeout, gin.H{"error": "checkout timed out, check your orders before trying again"})
	default:
		log.Printf("%s %s: %v", c.Request.Method, c.FullPath(), err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "could not place order"})
	}
}

// The order JSON is shared by every endpoint that returns an order.
type orderItemResponse struct {
	VariantID    int32  `json:"variant_id"`
	ProductID    int32  `json:"product_id"`
	Name         string `json:"name"`
	VariantLabel string `json:"variant_label"`
	ImageURL     string `json:"image_url"`
	UnitPrice    string `json:"unit_price"`
	Quantity     int32  `json:"quantity"`
	LineTotal    string `json:"line_total"`
}

type orderAddressResponse struct {
	FullName     string `json:"full_name"`
	Phone        string `json:"phone"`
	AddressLine1 string `json:"address_line_1"`
	AddressLine2 string `json:"address_line_2"`
	City         string `json:"city"`
	State        string `json:"state"`
	PostalCode   string `json:"postal_code"`
	Country      string `json:"country"`
}

type orderResponse struct {
	ID            int64                `json:"id"`
	OrderNumber   string               `json:"order_number"`
	Status        string               `json:"status"`
	PaymentStatus string               `json:"payment_status"`
	Subtotal      string               `json:"subtotal"`
	DeliveryFee   string               `json:"delivery_fee"`
	Total         string               `json:"total"`
	CreatedAt     time.Time            `json:"created_at"`
	Address       orderAddressResponse `json:"address"`
	Items         []orderItemResponse  `json:"items"`
}

func newOrderResponse(o domain.Order) orderResponse {
	items := make([]orderItemResponse, 0, len(o.Items))
	for _, it := range o.Items {
		items = append(items, orderItemResponse{
			VariantID:    it.VariantID,
			ProductID:    it.ProductID,
			Name:         it.ProductName,
			VariantLabel: it.VariantLabel,
			ImageURL:     it.ImageURL,
			UnitPrice:    it.UnitPrice.String(),
			Quantity:     it.Quantity,
			LineTotal:    it.LineTotal.String(),
		})
	}

	return orderResponse{
		ID:            o.ID,
		OrderNumber:   o.OrderNumber,
		Status:        string(o.Status),
		PaymentStatus: string(o.PaymentStatus),
		Subtotal:      o.Subtotal.String(),
		DeliveryFee:   o.DeliveryFee.String(),
		Total:         o.Total.String(),
		CreatedAt:     o.CreatedAt,
		Address: orderAddressResponse{
			FullName:     o.Address.FullName,
			Phone:        o.Address.Phone,
			AddressLine1: o.Address.Line1,
			AddressLine2: o.Address.Line2,
			City:         o.Address.City,
			State:        o.Address.State,
			PostalCode:   o.Address.PostalCode,
			Country:      o.Address.Country,
		},
		Items: items,
	}
}
