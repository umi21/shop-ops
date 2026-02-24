package main

import (
	"log"
	"os"

	"shop-ops/Delivery/controllers"
	"shop-ops/Delivery/routers"
	infrastructure "shop-ops/Infrastructure"
	repositories "shop-ops/Repositories"
	usecases "shop-ops/Usecases"

	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using default environment variables")
	}

	// Initialize Database
	db, err := infrastructure.NewDatabase()
	if err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer db.Close()

	// ── Repositories ──────────────────────────────────────────
	businessRepo := repositories.NewBusinessRepository(db.DB)
	inventoryRepo := repositories.NewInventoryRepository(db.DB)
	salesRepo := repositories.NewSalesRepository(db.DB)

	// ── Use Cases ─────────────────────────────────────────────
	inventoryUC := usecases.NewInventoryUseCase(inventoryRepo, businessRepo)
	salesUC := usecases.NewSalesUseCase(salesRepo, inventoryRepo, businessRepo)

	// ── Controllers ───────────────────────────────────────────
	inventoryController := controllers.NewInventoryController(inventoryUC)
	salesController := controllers.NewSalesController(salesUC)

	// ── Router ────────────────────────────────────────────────
	r := routers.SetupRouter(inventoryController, salesController)

	// Get port from environment variable
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Run Server
	log.Printf("Server starting on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
