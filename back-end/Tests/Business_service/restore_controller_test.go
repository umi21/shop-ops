package tests

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	Domain "shop-ops/Domain"
	"shop-ops/Delivery/controllers"
	usecases "shop-ops/Usecases"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// --- Mock RestoreUseCases ---

type MockRestoreUseCases struct {
	mock.Mock
}

func (m *MockRestoreUseCases) FullRestore(businessID string, include []string) (*Domain.RestoreResponse, error) {
	args := m.Called(businessID, include)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*Domain.RestoreResponse), args.Error(1)
}

func (m *MockRestoreUseCases) IncrementalRestore(businessID string, since time.Time, include []string) (*Domain.RestoreResponse, error) {
	args := m.Called(businessID, since, include)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*Domain.RestoreResponse), args.Error(1)
}

// --- Mock BusinessUseCases for RestoreController ---

type MockRestoreBusinessUseCases struct {
	mock.Mock
}

func (m *MockRestoreBusinessUseCases) Create(userId string, req *usecases.CreateBusinessRequest) (*Domain.Business, error) {
	args := m.Called(userId, req)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*Domain.Business), args.Error(1)
}

func (m *MockRestoreBusinessUseCases) GetByUserId(userId string) ([]*Domain.Business, error) {
	args := m.Called(userId)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]*Domain.Business), args.Error(1)
}

func (m *MockRestoreBusinessUseCases) GetById(businessId string) (*Domain.Business, error) {
	args := m.Called(businessId)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*Domain.Business), args.Error(1)
}

func (m *MockRestoreBusinessUseCases) Update(businessId string, userId string, req *usecases.UpdateBusinessRequest) (*Domain.Business, error) {
	args := m.Called(businessId, userId, req)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*Domain.Business), args.Error(1)
}

// --- Helper ---

func setupRestoreRouter(restoreUC *MockRestoreUseCases, businessUC *MockRestoreBusinessUseCases) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	controller := controllers.NewRestoreController(restoreUC, businessUC)

	protected := r.Group("/")
	protected.Use(func(c *gin.Context) {
		// Simulate auth middleware – set user_id if header present
		userID := c.GetHeader("X-Test-User-ID")
		if userID != "" {
			c.Set("user_id", userID)
		}
		c.Next()
	})

	restoreGroup := protected.Group("/businesses/:businessId/restore")
	{
		restoreGroup.GET("", controller.FullRestore)
		restoreGroup.GET("/incremental", controller.IncrementalRestore)
	}

	return r
}

// --- Tests ---

func TestRestoreControllerFullRestore(t *testing.T) {
	userID := primitive.NewObjectID()
	businessID := primitive.NewObjectID()
	business := &Domain.Business{
		ID:     businessID,
		UserID: userID,
		Name:   "Test Shop",
	}

	t.Run("Success - Full Restore", func(t *testing.T) {
		mockRestoreUC := new(MockRestoreUseCases)
		mockBusinessUC := new(MockRestoreBusinessUseCases)

		restoreResp := &Domain.RestoreResponse{
			Sales:      []Domain.Sale{{ID: primitive.NewObjectID(), BusinessID: businessID}},
			Expenses:   []Domain.Expense{{ID: primitive.NewObjectID(), BusinessID: businessID}},
			Products:   []Domain.Product{{ID: primitive.NewObjectID(), BusinessID: businessID, Name: "Widget"}},
			RestoredAt: time.Now(),
		}

		mockBusinessUC.On("GetById", businessID.Hex()).Return(business, nil).Once()
		mockRestoreUC.On("FullRestore", businessID.Hex(), []string(nil)).Return(restoreResp, nil).Once()

		router := setupRestoreRouter(mockRestoreUC, mockBusinessUC)
		req, _ := http.NewRequest("GET", "/businesses/"+businessID.Hex()+"/restore", nil)
		req.Header.Set("X-Test-User-ID", userID.Hex())
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)

		var resp Domain.RestoreResponse
		err := json.Unmarshal(w.Body.Bytes(), &resp)
		assert.NoError(t, err)
		assert.Len(t, resp.Sales, 1)
		assert.Len(t, resp.Expenses, 1)
		assert.Len(t, resp.Products, 1)
		mockRestoreUC.AssertExpectations(t)
		mockBusinessUC.AssertExpectations(t)
	})

	t.Run("Success - With Include Filter", func(t *testing.T) {
		mockRestoreUC := new(MockRestoreUseCases)
		mockBusinessUC := new(MockRestoreBusinessUseCases)

		restoreResp := &Domain.RestoreResponse{
			Sales:      []Domain.Sale{{ID: primitive.NewObjectID(), BusinessID: businessID}},
			RestoredAt: time.Now(),
		}

		mockBusinessUC.On("GetById", businessID.Hex()).Return(business, nil).Once()
		mockRestoreUC.On("FullRestore", businessID.Hex(), []string{"sales"}).Return(restoreResp, nil).Once()

		router := setupRestoreRouter(mockRestoreUC, mockBusinessUC)
		req, _ := http.NewRequest("GET", "/businesses/"+businessID.Hex()+"/restore?include=sales", nil)
		req.Header.Set("X-Test-User-ID", userID.Hex())
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		mockRestoreUC.AssertExpectations(t)
	})

	t.Run("Unauthorized - No Auth", func(t *testing.T) {
		mockRestoreUC := new(MockRestoreUseCases)
		mockBusinessUC := new(MockRestoreBusinessUseCases)

		router := setupRestoreRouter(mockRestoreUC, mockBusinessUC)
		req, _ := http.NewRequest("GET", "/businesses/"+businessID.Hex()+"/restore", nil)
		// No X-Test-User-ID header
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("Forbidden - Non-owner", func(t *testing.T) {
		mockRestoreUC := new(MockRestoreUseCases)
		mockBusinessUC := new(MockRestoreBusinessUseCases)
		otherUserID := primitive.NewObjectID()

		mockBusinessUC.On("GetById", businessID.Hex()).Return(business, nil).Once()

		router := setupRestoreRouter(mockRestoreUC, mockBusinessUC)
		req, _ := http.NewRequest("GET", "/businesses/"+businessID.Hex()+"/restore", nil)
		req.Header.Set("X-Test-User-ID", otherUserID.Hex())
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusForbidden, w.Code)
	})
}

func TestRestoreControllerIncrementalRestore(t *testing.T) {
	userID := primitive.NewObjectID()
	businessID := primitive.NewObjectID()
	business := &Domain.Business{
		ID:     businessID,
		UserID: userID,
		Name:   "Test Shop",
	}
	sinceTime := time.Date(2026, 3, 10, 0, 0, 0, 0, time.UTC)
	sinceStr := sinceTime.Format(time.RFC3339)

	t.Run("Success - Incremental Restore", func(t *testing.T) {
		mockRestoreUC := new(MockRestoreUseCases)
		mockBusinessUC := new(MockRestoreBusinessUseCases)

		restoreResp := &Domain.RestoreResponse{
			Sales:      []Domain.Sale{{ID: primitive.NewObjectID(), BusinessID: businessID}},
			Since:      &sinceStr,
			RestoredAt: time.Now(),
		}

		mockBusinessUC.On("GetById", businessID.Hex()).Return(business, nil).Once()
		mockRestoreUC.On("IncrementalRestore", businessID.Hex(), sinceTime, []string(nil)).Return(restoreResp, nil).Once()

		router := setupRestoreRouter(mockRestoreUC, mockBusinessUC)
		req, _ := http.NewRequest("GET", "/businesses/"+businessID.Hex()+"/restore/incremental?since="+sinceStr, nil)
		req.Header.Set("X-Test-User-ID", userID.Hex())
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		mockRestoreUC.AssertExpectations(t)
		mockBusinessUC.AssertExpectations(t)
	})

	t.Run("Bad Request - Missing since", func(t *testing.T) {
		mockRestoreUC := new(MockRestoreUseCases)
		mockBusinessUC := new(MockRestoreBusinessUseCases)

		router := setupRestoreRouter(mockRestoreUC, mockBusinessUC)
		req, _ := http.NewRequest("GET", "/businesses/"+businessID.Hex()+"/restore/incremental", nil)
		req.Header.Set("X-Test-User-ID", userID.Hex())
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		var body map[string]string
		json.Unmarshal(w.Body.Bytes(), &body)
		assert.Contains(t, body["error"], "since query parameter is required")
	})

	t.Run("Bad Request - Invalid since format", func(t *testing.T) {
		mockRestoreUC := new(MockRestoreUseCases)
		mockBusinessUC := new(MockRestoreBusinessUseCases)

		router := setupRestoreRouter(mockRestoreUC, mockBusinessUC)
		req, _ := http.NewRequest("GET", "/businesses/"+businessID.Hex()+"/restore/incremental?since=not-a-date", nil)
		req.Header.Set("X-Test-User-ID", userID.Hex())
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		var body map[string]string
		json.Unmarshal(w.Body.Bytes(), &body)
		assert.Contains(t, body["error"], "Invalid since format")
	})

	t.Run("Success - With include filter", func(t *testing.T) {
		mockRestoreUC := new(MockRestoreUseCases)
		mockBusinessUC := new(MockRestoreBusinessUseCases)

		restoreResp := &Domain.RestoreResponse{
			Products:   []Domain.Product{{ID: primitive.NewObjectID(), BusinessID: businessID, Name: "Widget"}},
			Since:      &sinceStr,
			RestoredAt: time.Now(),
		}

		mockBusinessUC.On("GetById", businessID.Hex()).Return(business, nil).Once()
		mockRestoreUC.On("IncrementalRestore", businessID.Hex(), sinceTime, []string{"products"}).Return(restoreResp, nil).Once()

		router := setupRestoreRouter(mockRestoreUC, mockBusinessUC)
		req, _ := http.NewRequest("GET", "/businesses/"+businessID.Hex()+"/restore/incremental?since="+sinceStr+"&include=products", nil)
		req.Header.Set("X-Test-User-ID", userID.Hex())
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		mockRestoreUC.AssertExpectations(t)
	})
}
