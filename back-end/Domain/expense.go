package domain

import (
	"errors"
	"time"

	"github.com/shopspring/decimal"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// ExpenseCategory represents the type of expense
type ExpenseCategory string

const (
	ExpenseRent          ExpenseCategory = "RENT"
	ExpenseUtilities     ExpenseCategory = "UTILITIES"
	ExpenseSalary        ExpenseCategory = "SALARY"
	ExpenseStockPurchase ExpenseCategory = "STOCK_PURCHASE"
	ExpenseTransport     ExpenseCategory = "TRANSPORT"
	ExpenseMarketing     ExpenseCategory = "MARKETING"
	ExpenseMaintenance   ExpenseCategory = "MAINTENANCE"
	ExpenseOther         ExpenseCategory = "OTHER"
)

// Expense represents a business expense
type Expense struct {
	ID         primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	BusinessID primitive.ObjectID `bson:"business_id" json:"business_id"`
	Category   ExpenseCategory    `bson:"category" json:"category"`
	Amount     decimal.Decimal    `bson:"amount" json:"amount"`
	Note       string             `bson:"note" json:"note"`
	CreatedAt  time.Time          `bson:"created_at" json:"created_at"`
	IsVoided   bool               `bson:"is_voided" json:"is_voided"`
}

// NewExpense creates a new Expense instance
func NewExpense(businessID primitive.ObjectID, category ExpenseCategory, amount decimal.Decimal, note string) *Expense {
	now := time.Now()
	// Default to OTHER if invalid/empty? Or enforce validation?
	// For now, let's allow caller to set it, validation will catch it if needed.
	return &Expense{
		ID:         primitive.NewObjectID(),
		BusinessID: businessID,
		Category:   category,
		Amount:     amount,
		Note:       note,
		CreatedAt:  now,
		IsVoided:   false,
	}
}

// Validate checks if the expense data is valid
func (e *Expense) Validate() error {
	if e.BusinessID.IsZero() {
		return errors.New("business ID is required")
	}
	if e.Amount.LessThan(decimal.Zero) {
		return errors.New("amount cannot be negative")
	}
	if e.Category == "" {
		return errors.New("expense category is required")
	}
	return nil
}
