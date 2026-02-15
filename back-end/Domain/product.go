package domain

import (
	"errors"
	"time"

	"github.com/shopspring/decimal"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Product represents an item in the business inventory
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

// NewProduct creates a new Product instance
func NewProduct(businessID primitive.ObjectID, name string, price decimal.Decimal, stock, threshold int) *Product {
	now := time.Now()
	return &Product{
		ID:                  primitive.NewObjectID(),
		BusinessID:          businessID,
		Name:                name,
		DefaultSellingPrice: price,
		StockQuantity:       stock,
		LowStockThreshold:   threshold,
		CreatedAt:           now,
		UpdatedAt:           now,
	}
}

// Validate checks if the product data is valid
func (p *Product) Validate() error {
	if p.BusinessID.IsZero() {
		return errors.New("business ID is required")
	}
	if p.Name == "" {
		return errors.New("product name is required")
	}
	if p.DefaultSellingPrice.LessThan(decimal.Zero) {
		return errors.New("price cannot be negative")
	}
	if p.StockQuantity < 0 {
		return errors.New("stock quantity cannot be negative")
	}
	return nil
}

// IsLowStock checks if the current stock is below or equal to the threshold
func (p *Product) IsLowStock() bool {
	return p.StockQuantity <= p.LowStockThreshold
}

// AdjustStock updates the stock quantity by a given amount (positive or negative)
func (p *Product) AdjustStock(quantity int) error {
	newStock := p.StockQuantity + quantity
	if newStock < 0 {
		return errors.New("insufficient stock")
	}
	p.StockQuantity = newStock
	p.UpdatedAt = time.Now()
	return nil
}
