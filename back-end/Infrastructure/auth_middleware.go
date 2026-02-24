package infrastructure

import (
	"github.com/gin-gonic/gin"
)

// AuthMiddleware handles authentication for protected routes

// DevAuthMiddleware is a temporary middleware for local development/testing.
// It sets a fake userID in the context so endpoints that require authentication can be tested.
// TODO: Replace with real JWT auth middleware before deploying to production.
func DevAuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Set("userID", "000000000000000000000001")
		c.Next()
	}
}
