package routers

import (
	"shop-ops/Delivery/controllers"
	infrastructure "shop-ops/Infrastructure"

	"github.com/gin-gonic/gin"
)

func SetupRouter(
	authController *controllers.AuthController,
	userController *controllers.UserController,
	businessController *controllers.BusinessController,
	jwtService *infrastructure.JWTService,
) *gin.Engine {
	r := gin.Default()

	// Auth Routes (Public)
	authGroup := r.Group("/auth")
	{
		authGroup.POST("/register", authController.Register)
		authGroup.POST("/login", authController.Login)
		authGroup.POST("/refresh", authController.RefreshToken)
	}

	// Protected Routes
	protected := r.Group("/")
	protected.Use(infrastructure.AuthMiddleware(jwtService))
	{
		// User Routes
		userGroup := protected.Group("/users")
		{
			userGroup.GET("/me", userController.GetProfile)
			userGroup.PATCH("/me", userController.UpdateProfile)
		}

		// Business Routes
		businessGroup := protected.Group("/businesses")
		{
			businessGroup.POST("", businessController.Create)
			businessGroup.GET("", businessController.List)
			businessGroup.GET("/:businessId", businessController.GetById)
			businessGroup.PATCH("/:businessId", businessController.Update)
		}
	}

	return r
}
