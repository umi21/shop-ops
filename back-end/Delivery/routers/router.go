package routers

import (
	"shop-ops/Delivery/controllers"
	infrastructure "shop-ops/Infrastructure"

	"github.com/gin-gonic/gin"
)

// SetupRouter initializes the Gin engine and defines all routes
func SetupRouter(
	inventoryController *controllers.InventoryController,
	salesController *controllers.SalesController,
) *gin.Engine {
	r := gin.Default()

	// Health check
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "pong"})
	})

	api := r.Group("/api")
	{
		v1 := api.Group("/v1")
		{
			v1.GET("/health", func(c *gin.Context) {
				c.JSON(200, gin.H{"status": "ok"})
			})

			// ─── Business-scoped routes ────────────────────────────
			businesses := v1.Group("/businesses/:businessId")
			businesses.Use(infrastructure.DevAuthMiddleware())
			{
				// ── Inventory ──────────────────────────────────────
				inventory := businesses.Group("/inventory")
				{
					products := inventory.Group("/products")
					{
						products.POST("", inventoryController.CreateProduct)
						products.GET("", inventoryController.GetProducts)
						products.GET("/low-stock", inventoryController.GetLowStock)
						products.GET("/:productId", inventoryController.GetProduct)
						products.PATCH("/:productId", inventoryController.UpdateProduct)
						products.DELETE("/:productId", inventoryController.DeleteProduct)
						products.POST("/:productId/adjust", inventoryController.AdjustStock)
						products.GET("/:productId/history", inventoryController.GetStockHistory)
					}
				}

				// ── Sales ──────────────────────────────────────────
				sales := businesses.Group("/sales")
				{
					sales.POST("", salesController.CreateSale)
					sales.GET("", salesController.GetSales)
					sales.GET("/summary", salesController.GetSalesSummary)
					sales.GET("/stats", salesController.GetSalesStats)
					sales.GET("/:saleId", salesController.GetSale)
					sales.PATCH("/:saleId", salesController.UpdateSale)
					sales.POST("/:saleId/void", salesController.VoidSale)
				}
			}
		}
	}

	return r
}
