package api

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

func internalError(ctx *gin.Context, err error, message string) {
	log.Printf("%s %s: %v", ctx.Request.Method, ctx.FullPath(), err)
	ctx.JSON(http.StatusInternalServerError, gin.H{"error": message})
}
