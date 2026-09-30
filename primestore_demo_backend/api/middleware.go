package api

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

const authorizationHeaderKey = "Authorization"
const authorizationTypeBearer = "bearer"
const authorizationPayloadKey = "authorization_payload"

func authMiddleware(server *Server) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		authHeader := ctx.GetHeader(authorizationHeaderKey)
		if len(authHeader) == 0 {
			ctx.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "authorization header is required"})
			return
		}

		fields := strings.Fields(authHeader)
		if len(fields) < 2 || strings.ToLower(fields[0]) != authorizationTypeBearer {
			ctx.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid authorization header format"})
			return
		}

		accessToken := fields[1]
		claims, err := server.tokenMaker.VerifyToken(accessToken)
		if err != nil {
			ctx.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid or expired token"})
			return
		}

		ctx.Set(authorizationPayloadKey, claims)
		ctx.Next()
	}
}
