package httpapi

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// The quantity limit is enforced once, by the domain (MaxCartQuantity), so the
// binding tags only check that the field is present.
type addCartItemRequest struct {
	VariantID int32 `json:"variant_id" binding:"required,min=1"`
	Quantity  int32 `json:"quantity" binding:"required"`
}

type setQuantityRequest struct {
	Quantity int32 `json:"quantity" binding:"required"`
}

func (h *handler) addCartItem(c *gin.Context) {
	var req addCartItemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	quantity, err := h.svc.AddToCart(c.Request.Context(), h.userID(c), req.VariantID, req.Quantity)
	if err != nil {
		writeError(c, err, "variant not found", "could not add item to cart")
		return
	}

	// quantity is the line's resulting quantity. It can be lower than the sum
	// asked for when the line hit the per-item limit.
	c.JSON(http.StatusOK, gin.H{"message": "item successfully added", "quantity": quantity})
}

func (h *handler) setCartItemQuantity(c *gin.Context) {
	variantID, ok := parseVariantID(c)
	if !ok {
		return
	}

	var req setQuantityRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.svc.SetQuantity(c.Request.Context(), h.userID(c), variantID, req.Quantity); err != nil {
		writeError(c, err, "item not found", "could not update item quantity")
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "item quantity was updated"})
}

func (h *handler) removeCartItem(c *gin.Context) {
	variantID, ok := parseVariantID(c)
	if !ok {
		return
	}

	if err := h.svc.RemoveItem(c.Request.Context(), h.userID(c), variantID); err != nil {
		writeError(c, err, "cart item not found", "could not delete cart item")
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "cart item successfully deleted"})
}

// The JSON below is the contract with the Flutter app. It is unchanged from the
// first version of the cart endpoint.
type cartItemResponse struct {
	VariantID int32  `json:"variant_id"`
	ProductID int32  `json:"product_id"`
	Name      string `json:"name"`
	Color     string `json:"color"`
	Size      string `json:"size"`
	ImageURL  string `json:"image_url"`
	UnitPrice string `json:"unit_price"`
	Quantity  int32  `json:"quantity"`
	LineTotal string `json:"line_total"`
	InStock   bool   `json:"in_stock"`
}

type cartResponse struct {
	Items    []cartItemResponse `json:"items"`
	Subtotal string             `json:"subtotal"`
}

func (h *handler) getCart(c *gin.Context) {
	cart, err := h.svc.GetCart(c.Request.Context(), h.userID(c))
	if err != nil {
		writeError(c, err, "cart not found", "could not fetch cart")
		return
	}

	// make(..., 0, n) so an empty cart is [] in JSON and never null.
	items := make([]cartItemResponse, 0, len(cart.Lines))
	for _, l := range cart.Lines {
		items = append(items, cartItemResponse{
			VariantID: l.VariantID,
			ProductID: l.ProductID,
			Name:      l.ProductName,
			Color:     l.Color,
			Size:      l.Size,
			ImageURL:  l.ImageURL,
			UnitPrice: l.UnitPrice.String(),
			Quantity:  l.Quantity,
			LineTotal: l.LineTotal.String(),
			InStock:   l.InStock,
		})
	}

	c.JSON(http.StatusOK, cartResponse{Items: items, Subtotal: cart.Subtotal.String()})
}
