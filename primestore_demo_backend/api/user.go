package api

import (
	"database/sql"
	"errors"
	"log"
	"net/http"
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/util"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lib/pq"
)

type createUserRequest struct {
	Name            string `json:"name" binding:"required"`
	Email           string `json:"email" binding:"required,email"`
	Password        string `json:"password" binding:"required,min=6"`
	ConfirmPassword string `json:"confirm_password" binding:"required,min=6"`
	Phone           string `json:"phone"`
}

type userResponse struct {
	ID    int64  `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
	Phone string `json:"phone"`
}
type loginResponse struct {
	AccessToken  string       `json:"access_token"`
	RefreshToken string       `json:"refresh_token"`
	User         userResponse `json:"user"`
}

type sendOtpRequest struct {
	Email string `json:"email" binding:"required,email"`
}

type sendOtpResponse struct {
	OtpToken string `json:"otp_token"`
}

func (server *Server) createUser(ctx *gin.Context) {
	var req createUserRequest

	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.Password != req.ConfirmPassword {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "passwords do not match"})
		return
	}

	hashedPassword, err := util.HashPassword(req.Password)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	arg := db.CreateUserParams{
		Name:         req.Name,
		Email:        req.Email,
		PasswordHash: sql.NullString{String: hashedPassword, Valid: true},
		Phone:        sql.NullString{String: req.Phone, Valid: req.Phone != ""},
	}

	user, err := server.store.CreateUser(ctx, arg)
	if err != nil {
		var pqErr *pq.Error
		if errors.As(err, &pqErr) && pqErr.Code == "23505" {
			ctx.JSON(http.StatusConflict, gin.H{"error": "an account with this email already exists"})
			return
		}
		internalError(ctx, err, "could not create account")
		return
	}

	res := userResponse{
		ID:    int64(user.ID),
		Name:  user.Name,
		Email: user.Email,
		Phone: user.Phone.String,
	}

	ctx.JSON(http.StatusCreated, res)
}

type loginRequest struct {
	Email    string `json:"email,omitempty" binding:"omitempty,email"`
	Phone    string `json:"phone,omitempty"`
	Password string `json:"password" binding:"required"`
}

func (server *Server) login(ctx *gin.Context) {
	var req loginRequest

	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.Email == "" && req.Phone == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "email or phone is required"})
		return
	}

	var user db.User
	var err error

	if req.Email != "" {
		user, err = server.store.GetUserByEmail(ctx, req.Email)
	} else {
		user, err = server.store.GetUserByPhone(ctx, sql.NullString{String: req.Phone, Valid: true})
	}

	if err != nil {
		if err == sql.ErrNoRows {
			ctx.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
			return
		}
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if !user.PasswordHash.Valid {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "this account uses Google sign-in, not a password"})
		return
	}

	if err := util.CheckPassword(req.Password, user.PasswordHash.String); err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	if !user.IsVerified {
		ctx.JSON(http.StatusForbidden, gin.H{"error": "email not verified"})
		return
	}

	accessToken, err := server.tokenMaker.CreateToken(int64(user.ID), 1*time.Hour)
	if err != nil {
		internalError(ctx, err, "something went wrong")

		return
	}

	refreshToken, err := util.GenerateRefreshToken()
	if err != nil {
		internalError(ctx, err, "something went wrong")
		return
	}

	_, err = server.store.CreateRefreshToken(ctx, db.CreateRefreshTokenParams{
		UserID:    user.ID,
		Token:     refreshToken,
		ExpiresAt: time.Now().Add(30 * 24 * time.Hour),
	})
	if err != nil {
		internalError(ctx, err, "something went wrong")
		return
	}

	rsp := loginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		User: userResponse{
			ID:    int64(user.ID),
			Name:  user.Name,
			Email: user.Email,
			Phone: user.Phone.String,
		},
	}
	ctx.JSON(http.StatusOK, rsp)

}
func (server *Server) sendOtp(ctx *gin.Context) {
	var req sendOtpRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := server.store.GetUserByEmail(ctx, req.Email)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	otp, err := util.GenerateOTP()
	if err != nil {
		internalError(ctx, err, "something went wrong")
		return
	}

	otpToken, err := server.tokenMaker.CreateOTPToken(int64(user.ID), otp, 10*time.Minute)
	if err != nil {
		internalError(ctx, err, "something went wrong")
		return
	}

	if err := server.mailer.SendOTP(user.Email, otp); err != nil {
		log.Println("mailer error:", err) // temporary debug line
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "failed to send email"})
		return
	}

	ctx.JSON(http.StatusOK, sendOtpResponse{OtpToken: otpToken})
}

type confirmOtpRequest struct {
	OtpToken string `json:"otp_token" binding:"required"`
	Otp      string `json:"otp" binding:"required"`
}

func (server *Server) confirmOtp(ctx *gin.Context) {
	var req confirmOtpRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	claims, err := server.tokenMaker.VerifyOTPToken(req.OtpToken)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "invalid or expired code"})
		return
	}

	if !server.tokenMaker.OTPMatches(claims, req.Otp) {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "invalid or expired code"})
		return
	}

	if err := server.store.VerifyUserEmail(ctx, int32(claims.UserID)); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "email verified"})
}

type refreshRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

type refreshResponse struct {
	AccessToken  string       `json:"access_token"`
	RefreshToken string       `json:"refresh_token"`
	User         userResponse `json:"user"`
}

func (server *Server) refresh(ctx *gin.Context) {
	var req refreshRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	stored, err := server.store.GetRefreshToken(ctx, req.RefreshToken)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "invalid or expired refresh token"})
		return
	}

	if time.Now().After(stored.ExpiresAt) {
		server.store.DeleteRefreshToken(ctx, req.RefreshToken)
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "invalid or expired refresh token"})
		return
	}

	if err := server.store.DeleteRefreshToken(ctx, req.RefreshToken); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	newAccessToken, err := server.tokenMaker.CreateToken(int64(stored.UserID), 1*time.Hour)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	newRefreshToken, err := util.GenerateRefreshToken()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	_, err = server.store.CreateRefreshToken(ctx, db.CreateRefreshTokenParams{
		UserID:    stored.UserID,
		Token:     newRefreshToken,
		ExpiresAt: time.Now().Add(30 * 24 * time.Hour),
	})
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// NEW: fetch the user so the response can carry their info too
	user, err := server.store.GetUser(ctx, stored.UserID)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, refreshResponse{
		AccessToken:  newAccessToken,
		RefreshToken: newRefreshToken,
		User: userResponse{
			ID:    int64(user.ID),
			Name:  user.Name,
			Email: user.Email,
			Phone: user.Phone.String,
		},
	})
}

type logoutRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

func (server *Server) logout(ctx *gin.Context) {
	var req logoutRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := server.store.DeleteRefreshToken(ctx, req.RefreshToken); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "logged out"})
}

type googleSignInRequest struct {
	IDToken string `json:"id_token" binding:"required"`
}

func (server *Server) googleSignIn(ctx *gin.Context) {
	var req googleSignInRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	claims, err := util.VerifyGoogleIDToken(ctx, req.IDToken, server.googleClientID)
	if err != nil {
		log.Printf("google token verification failed: %v", err)
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "invalid google token"})
		return
	}

	if !claims.EmailVerified {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "google account email is not verified"})
		return
	}

	googleID := sql.NullString{String: claims.Subject, Valid: true}

	user, err := server.store.GetUserByGoogleID(ctx, googleID)
	if err != nil {
		if err != sql.ErrNoRows {
			ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		// no account linked to this google id yet - does an account with this
		// email already exist? if so, link it instead of creating a duplicate.
		existing, existingErr := server.store.GetUserByEmail(ctx, claims.Email)
		switch {
		case existingErr == nil:
			user, err = server.store.LinkGoogleAccount(ctx, db.LinkGoogleAccountParams{
				ID:       existing.ID,
				GoogleID: googleID,
			})
			if err != nil {
				ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
				return
			}
		case existingErr == sql.ErrNoRows:
			name := claims.Name
			if name == "" {
				name = claims.Email
			}
			user, err = server.store.CreateGoogleUser(ctx, db.CreateGoogleUserParams{
				Name:     name,
				Email:    claims.Email,
				GoogleID: googleID,
			})
			if err != nil {
				ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
				return
			}
		default:
			ctx.JSON(http.StatusInternalServerError, gin.H{"error": existingErr.Error()})
			return
		}
	}

	accessToken, err := server.tokenMaker.CreateToken(int64(user.ID), 1*time.Hour)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	refreshToken, err := util.GenerateRefreshToken()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	_, err = server.store.CreateRefreshToken(ctx, db.CreateRefreshTokenParams{
		UserID:    user.ID,
		Token:     refreshToken,
		ExpiresAt: time.Now().Add(30 * 24 * time.Hour),
	})
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, loginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		User: userResponse{
			ID:    int64(user.ID),
			Name:  user.Name,
			Email: user.Email,
			Phone: user.Phone.String,
		},
	})
}

func (server *Server) getMe(ctx *gin.Context) {
	claims := ctx.MustGet(authorizationPayloadKey).(*util.UserClaims)

	user, err := server.store.GetUser(ctx, int32(claims.UserID))
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	ctx.JSON(http.StatusOK, userResponse{
		ID:    int64(user.ID),
		Name:  user.Name,
		Email: user.Email,
		Phone: user.Phone.String,
	})
}
