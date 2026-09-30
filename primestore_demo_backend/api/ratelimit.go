package api

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

type visitor struct {
	count       int
	windowStart time.Time
}

type RateLimiter struct {
	mu       sync.Mutex
	visitors map[string]*visitor
	limit    int
	window   time.Duration
}

func NewRateLimiter(limit int, window time.Duration) *RateLimiter {
	return &RateLimiter{
		visitors: make(map[string]*visitor),
		limit:    limit,
		window:   window,
	}

}

func (rl *RateLimiter) Allow(key string) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	now := time.Now()
	v, ok := rl.visitors[key]

	if !ok || now.Sub(v.windowStart) >= rl.window {
		rl.visitors[key] = &visitor{
			count:       1,
			windowStart: now,
		}
		return true
	}
	if v.count >= rl.limit {
		return false
	}
	v.count++
	return true
}

func rateLimitMiddleware(rl *RateLimiter) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		if !rl.Allow(ctx.ClientIP()) {
			ctx.Header("Retry-After", "60")
			ctx.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{"error": "Too many attempts try again later"})
			return
		}
		ctx.Next()
	}
}
