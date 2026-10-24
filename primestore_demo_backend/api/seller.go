package api

import (
	"database/sql"
	"errors"
	"net/http"
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/util"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lib/pq"
)

const sellerProfileKey = "seller_profile"

type createSellerProfileRequest struct {
	AccountType       string `json:"account_type" binding:"required,oneof=individual private_business public_business non_profit"`
	BusinessName      string `json:"business_name" binding:"required"`
	BusinessPhone     string `json:"business_phone" binding:"required"`
	BusinessAddress   string `json:"business_address" binding:"required"`
	AccountHolderName string `json:"account_holder_name" binding:"required"`
	BankName          string `json:"bank_name" binding:"required"`
	AccountNumber     string `json:"account_number" binding:"required,number,min=6,max=20"`
}

// The full account number is never sent back to the app, only the last four digits.
type payoutAccountResponse struct {
	AccountHolderName  string `json:"account_holder_name"`
	BankName           string `json:"bank_name"`
	AccountNumberLast4 string `json:"account_number_last4"`
}

type sellerProfileResponse struct {
	ID                 int64                  `json:"id"`
	AccountType        string                 `json:"account_type"`
	BusinessName       string                 `json:"business_name"`
	BusinessPhone      string                 `json:"business_phone"`
	BusinessAddress    string                 `json:"business_address"`
	VerificationStatus string                 `json:"verification_status"`
	CreatedAt          string                 `json:"created_at"`
	PayoutAccount      *payoutAccountResponse `json:"payout_account,omitempty"`
}

func newSellerProfileResponse(p db.SellerProfile, payout *payoutAccountResponse) sellerProfileResponse {
	return sellerProfileResponse{
		ID:                 int64(p.ID),
		AccountType:        p.AccountType,
		BusinessName:       p.BusinessName,
		BusinessPhone:      p.BusinessPhone,
		BusinessAddress:    p.BusinessAddress,
		VerificationStatus: p.VerificationStatus,
		CreatedAt:          p.CreatedAt.Time.Format(time.RFC3339),
		PayoutAccount:      payout,
	}
}

func lastFour(s string) string {
	if len(s) <= 4 {
		return s
	}
	return s[len(s)-4:]
}

func (server *Server) createSellerProfile(ctx *gin.Context) {
	var req createSellerProfileRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	authPayload := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

	// Both rows are saved in one transaction, so a failure can never leave
	// a seller profile without its payout account.
	tx, err := server.conn.BeginTx(ctx, nil)
	if err != nil {
		internalError(ctx, err, "could not create seller account")
		return
	}
	defer tx.Rollback() // does nothing once Commit has succeeded

	qtx := server.store.WithTx(tx)

	profile, err := qtx.CreateSellerProfile(ctx, db.CreateSellerProfileParams{
		UserID:          int32(authPayload.UserID),
		AccountType:     req.AccountType,
		BusinessName:    strings.TrimSpace(req.BusinessName),
		BusinessPhone:   strings.TrimSpace(req.BusinessPhone),
		BusinessAddress: strings.TrimSpace(req.BusinessAddress),
	})
	if err != nil {
		var pqErr *pq.Error
		if errors.As(err, &pqErr) && pqErr.Code == "23505" {
			ctx.JSON(http.StatusConflict, gin.H{"error": "you already have a seller account"})
			return
		}
		internalError(ctx, err, "could not create seller account")
		return
	}

	err = qtx.CreatePayoutAccount(ctx, db.CreatePayoutAccountParams{
		SellerID:          profile.ID,
		AccountHolderName: strings.TrimSpace(req.AccountHolderName),
		BankName:          strings.TrimSpace(req.BankName),
		AccountNumber:     req.AccountNumber,
	})
	if err != nil {
		internalError(ctx, err, "could not save payout details")
		return
	}

	if err := tx.Commit(); err != nil {
		internalError(ctx, err, "could not create seller account")
		return
	}

	payout := &payoutAccountResponse{
		AccountHolderName:  strings.TrimSpace(req.AccountHolderName),
		BankName:           strings.TrimSpace(req.BankName),
		AccountNumberLast4: lastFour(req.AccountNumber),
	}
	ctx.JSON(http.StatusCreated, gin.H{"seller_profile": newSellerProfileResponse(profile, payout)})
}

func (server *Server) getSellerProfile(ctx *gin.Context) {
	authPayload := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

	profile, err := server.store.GetSellerProfileByUserID(ctx, int32(authPayload.UserID))
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			ctx.JSON(http.StatusNotFound, gin.H{"error": "seller profile not found"})
			return
		}
		internalError(ctx, err, "could not fetch seller profile")
		return
	}

	var payout *payoutAccountResponse
	account, err := server.store.GetPayoutAccountBySellerID(ctx, profile.ID)
	if err == nil {
		payout = &payoutAccountResponse{
			AccountHolderName:  account.AccountHolderName,
			BankName:           account.BankName,
			AccountNumberLast4: lastFour(account.AccountNumber),
		}
	} else if !errors.Is(err, sql.ErrNoRows) {
		internalError(ctx, err, "could not fetch payout details")
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"seller_profile": newSellerProfileResponse(profile, payout)})
}

// sellerOnly must run after authMiddleware. It checks the database on every
// request (nothing is read from the token), so a user who has just become a
// seller is recognised immediately. Not attached to any route yet; the
// add-product route will use it.
func sellerOnly(server *Server) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		claims := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

		profile, err := server.store.GetSellerProfileByUserID(ctx, int32(claims.UserID))
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				ctx.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "a seller account is required"})
				return
			}
			internalError(ctx, err, "could not verify seller account")
			ctx.Abort()
			return
		}

		ctx.Set(sellerProfileKey, profile)
		ctx.Next()
	}
}