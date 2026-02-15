package routers

import (
	"github.com/gin-gonic/gin"
)

// SetupRouter initializes the Gin engine and defines routes
func SetupRouter() *gin.Engine {
	r := gin.Default()

	// Health check
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})

	api := r.Group("/api")
	{
		v1 := api.Group("/v1")
		{
			// Health check for v1
			v1.GET("/health", func(c *gin.Context) {
				c.JSON(200, gin.H{"status": "ok"})
			})

			// Auth routes (Example)
			// auth := v1.Group("/auth")
			// {
			// 	auth.POST("/register", controllers.Register)
			// 	auth.POST("/login", controllers.Login)
			// }

		}
	}

	return r
}
