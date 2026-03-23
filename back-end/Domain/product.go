package domain

import (
	"time"

	"github.com/shopspring/decimal"
	"go.mongodb.org/mongo-driver/bson/primitive"
)


type Product struct {
	ID                  primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	BusinessID          primitive.ObjectID `bson:"business_id" json:"business_id"`
	Name                string             `bson:"name" json:"name"`
	DefaultSellingPrice decimal.Decimal    `bson:"default_selling_price" json:"default_selling_price"`
	StockQuantity       int                `bson:"stock_quantity" json:"stock_quantity"`
	LowStockThreshold   int                `bson:"low_stock_threshold" json:"low_stock_threshold"`
	CreatedAt           time.Time          `bson:"created_at" json:"created_at"`
	UpdatedAt           time.Time          `bson:"updated_at" json:"updated_at"`
}

// IsLowStock checks if the product stock is at or below the low stock threshold
func (p *Product) IsLowStock() bool {
	return p.StockQuantity <= p.LowStockThreshold
}

// StockMovement represents history of stock changes
type StockMovement struct {
	ID          primitive.ObjectID  `bson:"_id,omitempty" json:"id"`
	BusinessID  primitive.ObjectID  `bson:"business_id" json:"business_id"`
	ProductID   primitive.ObjectID  `bson:"product_id" json:"product_id"`
	Type        MovementType        `bson:"type" json:"type"`
	Quantity    int                 `bson:"quantity" json:"quantity"`
	Reason      string              `bson:"reason,omitempty" json:"reason,omitempty"`
	ReferenceID *primitive.ObjectID `bson:"reference_id,omitempty" json:"reference_id,omitempty"` // Links to sale/expense ID
	CreatedBy   primitive.ObjectID  `bson:"created_by" json:"created_by"`
	CreatedAt   time.Time           `bson:"created_at" json:"created_at"`
}

type MovementType string

const (
	MovementTypePurchase MovementType = "purchase" // Stock increase from purchase
	MovementTypeSale     MovementType = "sale"     // Stock decrease from sale
	MovementTypeAdjust   MovementType = "adjust"   // Manual adjustment
	MovementTypeDamage   MovementType = "damage"   // Stock decrease from damage
	MovementTypeTheft    MovementType = "theft"    // Stock decrease from theft
	MovementTypeReturn   MovementType = "return"   // Stock increase from customer return
)

// StockMovementResponse for API responses
type StockMovementResponse struct {
	ID          string       `json:"id"`
	Type        MovementType `json:"type"`
	Quantity    int          `json:"quantity"` // Positive for increase, negative for decrease
	Reason      string       `json:"reason,omitempty"`
	ReferenceID *string      `json:"reference_id,omitempty"` // Only present if linked to a transaction
	CreatedBy   string       `json:"created_by"`
	CreatedAt   time.Time    `json:"created_at"`

	// Optional: Include product info for list views
	ProductID   string `json:"product_id,omitempty"`
	ProductName string `json:"product_name,omitempty"`
}

// Request/Response structs
type CreateProductRequest struct {
	BusinessID          string  `json:"business_id" binding:"required"`
	Name                string  `json:"name" binding:"required"`
	DefaultSellingPrice float64 `json:"default_selling_price" binding:"required,gt=0"`
	StockQuantity       int     `json:"stock_quantity" binding:"gte=0"`
	LowStockThreshold   int     `json:"low_stock_threshold" binding:"gte=0"`
}

type UpdateProductRequest struct {
	BusinessID          string   `json:"business_id" binding:"required"`
	Name                *string  `json:"name,omitempty"`
	DefaultSellingPrice *float64 `json:"default_selling_price,omitempty" binding:"omitempty,gt=0"`
	LowStockThreshold   *int     `json:"low_stock_threshold,omitempty" binding:"omitempty,gte=0"`
}

type AdjustStockRequest struct {
	BusinessID string       `json:"business_id" binding:"required"`
	Quantity   int          `json:"quantity" binding:"required"`
	Type       MovementType `json:"type" binding:"required"`
	Reason     string       `json:"reason" binding:"required"`
}

type ProductResponse struct {
	ID                  string          `json:"id"`
	Name                string          `json:"name"`
	DefaultSellingPrice decimal.Decimal `json:"default_selling_price"`
	StockQuantity       int             `json:"stock_quantity"`
	LowStockThreshold   int             `json:"low_stock_threshold"`
	IsLowStock          bool            `json:"is_low_stock"`
	CreatedAt           time.Time       `json:"created_at"`
	UpdatedAt           time.Time       `json:"updated_at"`
}

type ProductListResponse struct {
	Products   []ProductResponse  `json:"products"`
	Pagination PaginationMetadata `json:"pagination"`
}

type PaginationMetadata struct {
	Page       int `json:"page"`
	Limit      int `json:"limit"`
	Total      int `json:"total"`
	TotalPages int `json:"total_pages"`
}

// Query parameters for list products
type ProductListQuery struct {
	Search       string `form:"search"`
	LowStockOnly bool   `form:"low_stock_only"`
	Page         int    `form:"page,default=1"`
	Limit        int    `form:"limit,default=50"`
	Sort         string `form:"sort,default=name"`
	Order        string `form:"order,default=asc"`
}

// Repository interface
type ProductRepository interface {
	Create(product *Product) error
	FindByID(id string) (*Product, error)
	FindByBusinessID(businessID string, query ProductListQuery) ([]Product, int64, error)
	FindAllByBusinessID(businessID string) ([]Product, error)
	FindSince(businessID string, since time.Time) ([]Product, error)
	Update(product *Product) error
	Delete(id string) error
	AdjustStock(productID string, quantity int, movementType MovementType, reason string, referenceID *string, userID string) error
	GetLowStock(businessID string) ([]Product, error)
	GetStockHistory(productID string, limit int) ([]StockMovement, error)
}
