package api

import (
	"database/sql"
	"net/http"
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/util"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

type createAddressRequest struct {
    FullName       string `json:"full_name" binding:"required"`
	Phone          string `json:"phone" binding:"required"`
	AddressLine1   string `json:"address_line_1" binding:"required"`
	AddressLine2   string `json:"address_line_2"`
	City           string `json:"city" binding:"required"`
	State          string `json:"state" binding:"required"`
	PostalCode     string `json:"postal_code" binding:"required"`
	Country        string `json:"country" binding:"required"`
}
type addressResponse struct {
	ID           int64  `json:"id"`
	FullName     string `json:"full_name"`
	Phone        string `json:"phone"`
	AddressLine1 string `json:"address_line_1"`
	AddressLine2 string `json:"address_line_2"`
	City         string `json:"city"`
	State        string `json:"state"`
	PostalCode   string `json:"postal_code"`
	Country      string `json:"country"`
	IsDefault    bool   `json:"is_default"`
	CreatedAt    string `json:"created_at"`
}
func newAddressResponse(a db.Address) addressResponse {
	return addressResponse{
		ID:           a.ID,
		FullName:     a.FullName,
		Phone:        a.Phone,
		AddressLine1: a.AddressLine1,
		AddressLine2: a.AddressLine2.String, // just pull out .String, ignore .Valid — empty string if null
		City:         a.City,
		State:        a.State,
		PostalCode:   a.PostalCode,
		Country:      a.Country,
		IsDefault:    a.IsDefault,
		CreatedAt:    a.CreatedAt.Time.Format(time.RFC3339),
	}
}

func (server *Server) createAddress(ctx *gin.Context) {
	var req createAddressRequest
    // 1. bind JSON
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error" : err.Error()})
		return
	}
	authPayload := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)
    // 3. build CreateAddressParams
	arg := db.CreateAddressParams{
		UserID:             authPayload.UserID,
		FullName:          req.FullName,
		Phone:             req.Phone,
		AddressLine1:      req.AddressLine1,
		AddressLine2:      sql.NullString{String: req.AddressLine2, Valid: req.AddressLine2 != ""},
		City:              req.City,
		State:             req.State,
		PostalCode:        req.PostalCode,
		Country:           req.Country,
	}
   
		address, err := server.store.CreateAddress(ctx, arg)
	if err != nil {
		internalError(ctx, err, "could not add address")
		return
	}

	// New addresses become the default automatically.
	if _, err := server.store.SetDefaultAddress(ctx, db.SetDefaultAddressParams{
		UserID: authPayload.UserID,
		ID:     address.ID,
	}); err != nil {
		internalError(ctx, err, "could not set default address")
		return
	}
	address.IsDefault = true // the row we hold is stale, so reflect the change

	ctx.JSON(http.StatusCreated, gin.H{"address": newAddressResponse(address)})
   
}
func (server *Server) setDefaultAddress(ctx *gin.Context) {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid address id"})
		return
	}

	authPayload := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

	rows, err := server.store.SetDefaultAddress(ctx, db.SetDefaultAddressParams{
		UserID: authPayload.UserID,
		ID:     id,
	})
	if err != nil {
		internalError(ctx, err, "could not set default address")
		return
	}
	if rows == 0 {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "address not found"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "default address updated"})
}

func (server *Server) listAddresses(ctx *gin.Context) {
	authPayload := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

	addresses, err := server.store.ListAddressesByUser(ctx, authPayload.UserID)
	if err != nil {
		internalError(ctx, err, "could not fetch addresses")
		return
	}

	responses := make([]addressResponse, len(addresses))
	for i, a := range addresses {
		responses[i] = newAddressResponse(a)
	}

	ctx.JSON(http.StatusOK, gin.H{"addresses": responses})
}


