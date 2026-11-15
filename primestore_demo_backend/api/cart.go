package api

import (
	"errors"
	"net/http"
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/util"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/lib/pq"
)

const maxCartQuantity = 10

// Struct tags cannot use constants: keep max=10 in sync with maxCartQuantity.
type addCartItemRequest struct {
	VariantID int32 `json:"variant_id" binding:"required,min=1"`
	Quantity  int32 `json:"quantity" binding:"required,min=1,max=10"`
}

type setQuantityRequest struct {
	Quantity int32 `json:"quantity" binding:"required,min=1,max=10"`
}

// parseVariantID reads :id from the URL. It writes the 400 itself when invalid.
func parseVariantID(ctx *gin.Context) (int32, bool) {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil || id <= 0 {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid variant id"})
		return 0, false
	}
	return int32(id), true
}

func (server *Server) createCartItem(ctx *gin.Context) {
	var req addCartItemRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	authPayload := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

	_, err := server.store.UpsertCartItem(ctx, db.UpsertCartItemParams{
		UserID:      int32(authPayload.UserID),
		VariantID:   req.VariantID,
		Quantity:    req.Quantity,
		MaxQuantity: maxCartQuantity,
	})
	if err != nil {
		var pqErr *pq.Error
		if errors.As(err, &pqErr) && pqErr.Code == "23503" { // foreign key violation
			ctx.JSON(http.StatusNotFound, gin.H{"error": "variant not found"})
			return
		}
		internalError(ctx, err, "could not add item to cart")
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "item successfully added"})
}

func (server *Server) updateCartItem(ctx *gin.Context) {
	variantID, ok := parseVariantID(ctx)
	if !ok {
		return
	}

	var req setQuantityRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	authPayload := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

	rows, err := server.store.SetCartItemQuantity(ctx, db.SetCartItemQuantityParams{
		UserID:    int32(authPayload.UserID),
		VariantID: variantID,
		Quantity:  req.Quantity,
	})
	if err != nil {
		internalError(ctx, err, "could not update item quantity")
		return
	}
	if rows == 0 {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "item not found"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "item quantity was updated"})
}

func (server *Server) deleteCartItem(ctx *gin.Context) {
	variantID, ok := parseVariantID(ctx)
	if !ok {
		return
	}

	authPayload := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

	rows, err := server.store.RemoveCartItem(ctx, db.RemoveCartItemParams{
		UserID:    int32(authPayload.UserID),
		VariantID: variantID,
	})
	if err != nil {
		internalError(ctx, err, "could not delete cart item")
		return
	}
	if rows == 0 {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "cart item not found"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "cart item successfully deleted"})
}

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

func (server *Server) getCart(ctx *gin.Context) {
	authPayload := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

	rows, err := server.store.ListCartItems(ctx, int32(authPayload.UserID))
	if err != nil {
		internalError(ctx, err, "could not fetch cart")
		return
	}

	// make(..., 0, n) so an empty cart serialises as [] and not null
	items := make([]cartItemResponse, 0, len(rows))
	var subtotal int64 // in cents

	for _, row := range rows {
		imageURL := ""
		if row.ImageUrl != "" {
			imageURL = server.images.PublicURL(row.ImageUrl)
		}

		unitCents, ok := parseMoney(row.UnitPrice)
		if !ok {
			// The database holds a price our own rules should never allow.
			// That is a server problem, not a bad request.
			internalError(ctx, errInvalidPrice, "could not fetch cart")
			return
		}

		lineCents := unitCents * int64(row.Quantity)
		subtotal += lineCents

		items = append(items, cartItemResponse{
			VariantID: row.VariantID,
			ProductID: row.ProductID,
			Name:      row.ProductName,
			Color:     row.Color.String,
			Size:      row.Size.String,
			ImageURL:  imageURL,
			UnitPrice: formatCents(unitCents),
			Quantity:  row.Quantity,
			LineTotal: formatCents(lineCents),
			InStock:   row.Stock >= row.Quantity,
		})
	}

	ctx.JSON(http.StatusOK, cartResponse{
		Items:    items,
		Subtotal: formatCents(subtotal),
	})
}
