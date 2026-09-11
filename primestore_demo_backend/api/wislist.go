package api

import (
	
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/util"
)

type addWishlistRequest struct {
	ProductID int64 `json:"product_id" binding:"required"`
}

func (server *Server) addToWishlist(ctx *gin.Context) {
	var req addWishlistRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	authPayload := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

	_, err := server.store.AddToWishlist(ctx, db.AddToWishlistParams{
		UserID:    authPayload.UserID,
		ProductID: req.ProductID,
	})
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "could not add to wishlist"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "added to wishlist"})
}

func (server *Server) removeFromWishlist(ctx *gin.Context) {
	productID, err := strconv.ParseInt(ctx.Param("product_id"), 10, 64)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid product id"})
		return
	}

	authPayload := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

	err = server.store.RemoveFromWishlist(ctx, db.RemoveFromWishlistParams{
		UserID:    authPayload.UserID,
		ProductID: productID,
	})
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "could not remove from wishlist"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "removed from wishlist"})
}

func (server *Server) listWishlist(ctx *gin.Context) {
	authPayload := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

	products, err := server.store.ListWishlistProducts(ctx, authPayload.UserID)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "could not fetch wishlist"})
		return
	}

	res := make([]productResponse, 0, len(products))
	for _, p := range products {
		built, err := server.buildProductResponse(ctx, p.ID, p.Name, p.Description, p.IsFeatured, p.BrandName, p.BrandVerified)
		if err != nil {
			ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		res = append(res, built)
	}

	ctx.JSON(http.StatusOK, gin.H{"products": res})
}


func (server *Server) listWishlistedIDs(ctx *gin.Context) {
	authPayload := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

	ids, err := server.store.ListWishlistedProductIDs(ctx, authPayload.UserID)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "could not fetch wishlist ids"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"product_ids": ids})
}
