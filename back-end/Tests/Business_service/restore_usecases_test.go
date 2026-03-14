package tests

import (
	"testing"
	"time"

	Domain "shop-ops/Domain"
	repositories "shop-ops/Repositories"
	usecases "shop-ops/Usecases"

	"context"

	"github.com/shopspring/decimal"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// --- Mock SaleRepository ---

type MockSaleRepository struct {
	mock.Mock
}

func (m *MockSaleRepository) Create(sale *Domain.Sale) error {
	args := m.Called(sale)
	return args.Error(0)
}

func (m *MockSaleRepository) FindByID(id string) (*Domain.Sale, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*Domain.Sale), args.Error(1)
}

func (m *MockSaleRepository) FindByBusinessID(businessID string, query Domain.SaleListQuery) ([]Domain.Sale, int64, error) {
	args := m.Called(businessID, query)
	return args.Get(0).([]Domain.Sale), args.Get(1).(int64), args.Error(2)
}

func (m *MockSaleRepository) FindAllByBusinessID(businessID string) ([]Domain.Sale, error) {
	args := m.Called(businessID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]Domain.Sale), args.Error(1)
}

func (m *MockSaleRepository) FindSince(businessID string, since time.Time) ([]Domain.Sale, error) {
	args := m.Called(businessID, since)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]Domain.Sale), args.Error(1)
}

func (m *MockSaleRepository) UpdateNote(id string, note string) error {
	args := m.Called(id, note)
	return args.Error(0)
}

func (m *MockSaleRepository) VoidSale(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *MockSaleRepository) GetSummary(businessID string, startDate, endDate time.Time) (*Domain.SaleSummaryResponse, error) {
	args := m.Called(businessID, startDate, endDate)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*Domain.SaleSummaryResponse), args.Error(1)
}

// --- Mock ExpenseRepository ---

type MockExpenseRepository struct {
	mock.Mock
}

func (m *MockExpenseRepository) Create(ctx context.Context, expense *Domain.Expense) error {
	args := m.Called(ctx, expense)
	return args.Error(0)
}

func (m *MockExpenseRepository) GetByID(ctx context.Context, id primitive.ObjectID) (*Domain.Expense, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*Domain.Expense), args.Error(1)
}

func (m *MockExpenseRepository) GetByBusinessID(ctx context.Context, filter repositories.ExpenseFilter) ([]*Domain.Expense, int64, error) {
	args := m.Called(ctx, filter)
	return args.Get(0).([]*Domain.Expense), args.Get(1).(int64), args.Error(2)
}

func (m *MockExpenseRepository) GetAllByBusinessID(ctx context.Context, businessID primitive.ObjectID) ([]*Domain.Expense, error) {
	args := m.Called(ctx, businessID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]*Domain.Expense), args.Error(1)
}

func (m *MockExpenseRepository) GetSince(ctx context.Context, businessID primitive.ObjectID, since time.Time) ([]*Domain.Expense, error) {
	args := m.Called(ctx, businessID, since)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]*Domain.Expense), args.Error(1)
}

func (m *MockExpenseRepository) Update(ctx context.Context, expense *Domain.Expense) error {
	args := m.Called(ctx, expense)
	return args.Error(0)
}

func (m *MockExpenseRepository) Void(ctx context.Context, id primitive.ObjectID) error {
	args := m.Called(ctx, id)
	return args.Error(0)
}

func (m *MockExpenseRepository) GetSummaryByCategory(ctx context.Context, businessID primitive.ObjectID, startDate, endDate *time.Time) (map[Domain.ExpenseCategory]decimal.Decimal, decimal.Decimal, error) {
	args := m.Called(ctx, businessID, startDate, endDate)
	return args.Get(0).(map[Domain.ExpenseCategory]decimal.Decimal), args.Get(1).(decimal.Decimal), args.Error(2)
}

// --- Mock ProductRepository ---

type MockProductRepository struct {
	mock.Mock
}

func (m *MockProductRepository) Create(product *Domain.Product) error {
	args := m.Called(product)
	return args.Error(0)
}

func (m *MockProductRepository) FindByID(id string) (*Domain.Product, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*Domain.Product), args.Error(1)
}

func (m *MockProductRepository) FindByBusinessID(businessID string, query Domain.ProductListQuery) ([]Domain.Product, int64, error) {
	args := m.Called(businessID, query)
	return args.Get(0).([]Domain.Product), args.Get(1).(int64), args.Error(2)
}

func (m *MockProductRepository) FindAllByBusinessID(businessID string) ([]Domain.Product, error) {
	args := m.Called(businessID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]Domain.Product), args.Error(1)
}

func (m *MockProductRepository) FindSince(businessID string, since time.Time) ([]Domain.Product, error) {
	args := m.Called(businessID, since)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]Domain.Product), args.Error(1)
}

func (m *MockProductRepository) Update(product *Domain.Product) error {
	args := m.Called(product)
	return args.Error(0)
}

func (m *MockProductRepository) Delete(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *MockProductRepository) AdjustStock(productID string, quantity int, movementType Domain.MovementType, reason string, referenceID *string, userID string) error {
	args := m.Called(productID, quantity, movementType, reason, referenceID, userID)
	return args.Error(0)
}

func (m *MockProductRepository) GetLowStock(businessID string) ([]Domain.Product, error) {
	args := m.Called(businessID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]Domain.Product), args.Error(1)
}

func (m *MockProductRepository) GetStockHistory(productID string, limit int) ([]Domain.StockMovement, error) {
	args := m.Called(productID, limit)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]Domain.StockMovement), args.Error(1)
}

// --- Tests ---

func TestRestoreFullRestore(t *testing.T) {
	businessID := primitive.NewObjectID()

	sales := []Domain.Sale{
		{ID: primitive.NewObjectID(), BusinessID: businessID, UnitPrice: 10, Quantity: 2, Total: 20},
	}
	expenses := []*Domain.Expense{
		{ID: primitive.NewObjectID(), BusinessID: businessID, Amount: decimal.NewFromFloat(50)},
	}
	products := []Domain.Product{
		{ID: primitive.NewObjectID(), BusinessID: businessID, Name: "Widget"},
	}

	t.Run("All includes (default)", func(t *testing.T) {
		mockSales := new(MockSaleRepository)
		mockExpenses := new(MockExpenseRepository)
		mockProducts := new(MockProductRepository)

		mockSales.On("FindAllByBusinessID", businessID.Hex()).Return(sales, nil).Once()
		mockExpenses.On("GetAllByBusinessID", mock.Anything, businessID).Return(expenses, nil).Once()
		mockProducts.On("FindAllByBusinessID", businessID.Hex()).Return(products, nil).Once()

		uc := usecases.NewRestoreUseCases(mockSales, mockExpenses, mockProducts)
		result, err := uc.FullRestore(businessID.Hex(), nil)

		assert.NoError(t, err)
		assert.NotNil(t, result)
		assert.Len(t, result.Sales, 1)
		assert.Len(t, result.Expenses, 1)
		assert.Len(t, result.Products, 1)
		assert.Nil(t, result.Since)
		assert.False(t, result.RestoredAt.IsZero())
		mockSales.AssertExpectations(t)
		mockExpenses.AssertExpectations(t)
		mockProducts.AssertExpectations(t)
	})

	t.Run("Include only sales", func(t *testing.T) {
		mockSales := new(MockSaleRepository)
		mockExpenses := new(MockExpenseRepository)
		mockProducts := new(MockProductRepository)

		mockSales.On("FindAllByBusinessID", businessID.Hex()).Return(sales, nil).Once()

		uc := usecases.NewRestoreUseCases(mockSales, mockExpenses, mockProducts)
		result, err := uc.FullRestore(businessID.Hex(), []string{"sales"})

		assert.NoError(t, err)
		assert.NotNil(t, result)
		assert.Len(t, result.Sales, 1)
		assert.Nil(t, result.Expenses)
		assert.Nil(t, result.Products)
		mockSales.AssertExpectations(t)
		mockExpenses.AssertNotCalled(t, "GetAllByBusinessID")
		mockProducts.AssertNotCalled(t, "FindAllByBusinessID")
	})

	t.Run("Include sales and products", func(t *testing.T) {
		mockSales := new(MockSaleRepository)
		mockExpenses := new(MockExpenseRepository)
		mockProducts := new(MockProductRepository)

		mockSales.On("FindAllByBusinessID", businessID.Hex()).Return(sales, nil).Once()
		mockProducts.On("FindAllByBusinessID", businessID.Hex()).Return(products, nil).Once()

		uc := usecases.NewRestoreUseCases(mockSales, mockExpenses, mockProducts)
		result, err := uc.FullRestore(businessID.Hex(), []string{"sales", "products"})

		assert.NoError(t, err)
		assert.Len(t, result.Sales, 1)
		assert.Nil(t, result.Expenses)
		assert.Len(t, result.Products, 1)
		mockSales.AssertExpectations(t)
		mockExpenses.AssertNotCalled(t, "GetAllByBusinessID")
		mockProducts.AssertExpectations(t)
	})

	t.Run("Empty result set", func(t *testing.T) {
		mockSales := new(MockSaleRepository)
		mockExpenses := new(MockExpenseRepository)
		mockProducts := new(MockProductRepository)

		mockSales.On("FindAllByBusinessID", businessID.Hex()).Return([]Domain.Sale{}, nil).Once()
		mockExpenses.On("GetAllByBusinessID", mock.Anything, businessID).Return([]*Domain.Expense{}, nil).Once()
		mockProducts.On("FindAllByBusinessID", businessID.Hex()).Return([]Domain.Product{}, nil).Once()

		uc := usecases.NewRestoreUseCases(mockSales, mockExpenses, mockProducts)
		result, err := uc.FullRestore(businessID.Hex(), nil)

		assert.NoError(t, err)
		assert.NotNil(t, result)
		assert.Len(t, result.Sales, 0)
		assert.Len(t, result.Expenses, 0)
		assert.Len(t, result.Products, 0)
	})

	t.Run("Sales repo error propagation", func(t *testing.T) {
		mockSales := new(MockSaleRepository)
		mockExpenses := new(MockExpenseRepository)
		mockProducts := new(MockProductRepository)

		mockSales.On("FindAllByBusinessID", businessID.Hex()).Return(nil, assert.AnError).Once()

		uc := usecases.NewRestoreUseCases(mockSales, mockExpenses, mockProducts)
		result, err := uc.FullRestore(businessID.Hex(), nil)

		assert.Error(t, err)
		assert.Nil(t, result)
		assert.Contains(t, err.Error(), "failed to restore sales")
	})
}

func TestRestoreIncrementalRestore(t *testing.T) {
	businessID := primitive.NewObjectID()
	since := time.Now().Add(-24 * time.Hour)

	sales := []Domain.Sale{
		{ID: primitive.NewObjectID(), BusinessID: businessID, UnitPrice: 25, Quantity: 1, Total: 25},
	}
	expenses := []*Domain.Expense{
		{ID: primitive.NewObjectID(), BusinessID: businessID, Amount: decimal.NewFromFloat(100)},
	}
	products := []Domain.Product{
		{ID: primitive.NewObjectID(), BusinessID: businessID, Name: "Updated Product"},
	}

	t.Run("All includes (default)", func(t *testing.T) {
		mockSales := new(MockSaleRepository)
		mockExpenses := new(MockExpenseRepository)
		mockProducts := new(MockProductRepository)

		mockSales.On("FindSince", businessID.Hex(), since).Return(sales, nil).Once()
		mockExpenses.On("GetSince", mock.Anything, businessID, since).Return(expenses, nil).Once()
		mockProducts.On("FindSince", businessID.Hex(), since).Return(products, nil).Once()

		uc := usecases.NewRestoreUseCases(mockSales, mockExpenses, mockProducts)
		result, err := uc.IncrementalRestore(businessID.Hex(), since, nil)

		assert.NoError(t, err)
		assert.NotNil(t, result)
		assert.Len(t, result.Sales, 1)
		assert.Len(t, result.Expenses, 1)
		assert.Len(t, result.Products, 1)
		assert.NotNil(t, result.Since)
		assert.False(t, result.RestoredAt.IsZero())
		mockSales.AssertExpectations(t)
		mockExpenses.AssertExpectations(t)
		mockProducts.AssertExpectations(t)
	})

	t.Run("Include only expenses", func(t *testing.T) {
		mockSales := new(MockSaleRepository)
		mockExpenses := new(MockExpenseRepository)
		mockProducts := new(MockProductRepository)

		mockExpenses.On("GetSince", mock.Anything, businessID, since).Return(expenses, nil).Once()

		uc := usecases.NewRestoreUseCases(mockSales, mockExpenses, mockProducts)
		result, err := uc.IncrementalRestore(businessID.Hex(), since, []string{"expenses"})

		assert.NoError(t, err)
		assert.Nil(t, result.Sales)
		assert.Len(t, result.Expenses, 1)
		assert.Nil(t, result.Products)
		mockSales.AssertNotCalled(t, "FindSince")
		mockProducts.AssertNotCalled(t, "FindSince")
	})

	t.Run("Product repo error propagation", func(t *testing.T) {
		mockSales := new(MockSaleRepository)
		mockExpenses := new(MockExpenseRepository)
		mockProducts := new(MockProductRepository)

		mockProducts.On("FindSince", businessID.Hex(), since).Return(nil, assert.AnError).Once()

		uc := usecases.NewRestoreUseCases(mockSales, mockExpenses, mockProducts)
		result, err := uc.IncrementalRestore(businessID.Hex(), since, []string{"products"})

		assert.Error(t, err)
		assert.Nil(t, result)
		assert.Contains(t, err.Error(), "failed to restore products")
	})
}
