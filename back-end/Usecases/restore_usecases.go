package usecases

import (
	"context"
	"fmt"
	"time"

	Domain "shop-ops/Domain"
	repositories "shop-ops/Repositories"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

// RestoreUseCases defines the business logic for data restore operations
type RestoreUseCases interface {
	FullRestore(businessID string, include []string) (*Domain.RestoreResponse, error)
	IncrementalRestore(businessID string, since time.Time, include []string) (*Domain.RestoreResponse, error)
}

type restoreUseCases struct {
	salesRepo     Domain.SaleRepository
	expenseRepo   repositories.ExpenseRepository
	productRepo   Domain.ProductRepository
}

// NewRestoreUseCases creates a new RestoreUseCases instance
func NewRestoreUseCases(
	salesRepo Domain.SaleRepository,
	expenseRepo repositories.ExpenseRepository,
	productRepo Domain.ProductRepository,
) RestoreUseCases {
	return &restoreUseCases{
		salesRepo:   salesRepo,
		expenseRepo: expenseRepo,
		productRepo: productRepo,
	}
}

// shouldInclude checks if an entity type is in the include list.
// If include is empty, all types are included by default.
func shouldInclude(include []string, entity string) bool {
	if len(include) == 0 {
		return true
	}
	for _, item := range include {
		if item == entity {
			return true
		}
	}
	return false
}

// FullRestore fetches all data for a business, filtered by the include list
func (uc *restoreUseCases) FullRestore(businessID string, include []string) (*Domain.RestoreResponse, error) {
	response := &Domain.RestoreResponse{
		RestoredAt: time.Now(),
	}

	if shouldInclude(include, "sales") {
		sales, err := uc.salesRepo.FindAllByBusinessID(businessID)
		if err != nil {
			return nil, fmt.Errorf("failed to restore sales: %w", err)
		}
		response.Sales = sales
	}

	if shouldInclude(include, "expenses") {
		objBusinessID, err := primitive.ObjectIDFromHex(businessID)
		if err != nil {
			return nil, fmt.Errorf("invalid business ID: %w", err)
		}
		expenses, err := uc.expenseRepo.GetAllByBusinessID(context.Background(), objBusinessID)
		if err != nil {
			return nil, fmt.Errorf("failed to restore expenses: %w", err)
		}
		// Convert []*Expense to []Expense for response consistency
		expenseList := make([]Domain.Expense, len(expenses))
		for i, e := range expenses {
			expenseList[i] = *e
		}
		response.Expenses = expenseList
	}

	if shouldInclude(include, "products") {
		products, err := uc.productRepo.FindAllByBusinessID(businessID)
		if err != nil {
			return nil, fmt.Errorf("failed to restore products: %w", err)
		}
		response.Products = products
	}

	return response, nil
}

// IncrementalRestore fetches data modified since the given timestamp, filtered by the include list
func (uc *restoreUseCases) IncrementalRestore(businessID string, since time.Time, include []string) (*Domain.RestoreResponse, error) {
	sinceStr := since.Format(time.RFC3339)
	response := &Domain.RestoreResponse{
		Since:      &sinceStr,
		RestoredAt: time.Now(),
	}

	if shouldInclude(include, "sales") {
		sales, err := uc.salesRepo.FindSince(businessID, since)
		if err != nil {
			return nil, fmt.Errorf("failed to restore sales: %w", err)
		}
		response.Sales = sales
	}

	if shouldInclude(include, "expenses") {
		objBusinessID, err := primitive.ObjectIDFromHex(businessID)
		if err != nil {
			return nil, fmt.Errorf("invalid business ID: %w", err)
		}
		expenses, err := uc.expenseRepo.GetSince(context.Background(), objBusinessID, since)
		if err != nil {
			return nil, fmt.Errorf("failed to restore expenses: %w", err)
		}
		expenseList := make([]Domain.Expense, len(expenses))
		for i, e := range expenses {
			expenseList[i] = *e
		}
		response.Expenses = expenseList
	}

	if shouldInclude(include, "products") {
		products, err := uc.productRepo.FindSince(businessID, since)
		if err != nil {
			return nil, fmt.Errorf("failed to restore products: %w", err)
		}
		response.Products = products
	}

	return response, nil
}
