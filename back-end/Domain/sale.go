package domain

import (
	"errors"
	"time"

	"github.com/shopspring/decimal"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Sale represents a sales transaction
type Sale struct {
	ID         primitive.ObjectID  `bson:"_id,omitempty" json:"id"`
	BusinessID primitive.ObjectID  `bson:"business_id" json:"business_id"`
	ProductID  *primitive.ObjectID `bson:"product_id,omitempty" json:"product_id,omitempty"` // Pointer for optional
	UnitPrice  decimal.Decimal     `bson:"unit_price" json:"unit_price"`
	Quantity   int                 `bson:"quantity" json:"quantity"`
	Total      decimal.Decimal     `bson:"total" json:"total"`
	CreatedAt  time.Time           `bson:"created_at" json:"created_at"`
	IsVoided   bool                `bson:"is_voided" json:"is_voided"`
}

// NewSale creates a new Sale instance and calculates the total
func NewSale(businessID primitive.ObjectID, productID *primitive.ObjectID, unitPrice decimal.Decimal, quantity int) *Sale {
	sale := &Sale{
		ID:         primitive.NewObjectID(),
		BusinessID: businessID,
		ProductID:  productID,
		UnitPrice:  unitPrice,
		Quantity:   quantity,
		CreatedAt:  time.Now(),
		IsVoided:   false,
	}
	sale.CalculateTotal()
	return sale
}

// CalculateTotal computes the total amount based on unit price and quantity
func (s *Sale) CalculateTotal() decimal.Decimal {
	s.Total = s.UnitPrice.Mul(decimal.NewFromInt(int64(s.Quantity)))
	return s.Total
}

// Validate checks if the sale data is valid
func (s *Sale) Validate() error {
	if s.BusinessID.IsZero() {
		return errors.New("business ID is required")
	}
	if s.UnitPrice.LessThan(decimal.Zero) {
		return errors.New("unit price cannot be negative")
	}
	if s.Quantity <= 0 {
		return errors.New("quantity must be positive")
	}
	// Check if total matches calculation? Maybe redundant but good for data integrity
	expectedTotal := s.UnitPrice.Mul(decimal.NewFromInt(int64(s.Quantity)))
	if !s.Total.Equal(expectedTotal) {
		return errors.New("total amount mismatch")
	}
	return nil
}
