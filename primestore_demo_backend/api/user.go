package api

import (
	"net/http"
    "database/sql"
	"github.com/gin-gonic/gin"
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/util"
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
		PasswordHash: hashedPassword,
		Phone:        sql.NullString{String: req.Phone, Valid: req.Phone != ""},
	}


	user, err := server.store.CreateUser(ctx, arg)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	res := userResponse{
		ID:    int64(user.ID),
		Name:  user.Name,
		Email: user.Email,
		Phone: user.Phone.String,
	}

	ctx.JSON(http.StatusOK, res)
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

	if err := util.CheckPassword(req.Password, user.PasswordHash); err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	rsp := userResponse{
		ID:    int64(user.ID),
		Name:  user.Name,
		Email: user.Email,
		Phone: user.Phone.String,
	}
	ctx.JSON(http.StatusOK, rsp)
}