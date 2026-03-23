package controllers

import (
	"net/http"
	domain "shop-ops/Domain"
	usecases "shop-ops/Usecases"

	"github.com/gin-gonic/gin"
)

type ProfitController struct {
	profitUseCase    usecases.ProfitUseCase
	businessUseCase  usecases.BusinessUseCases
}

func NewProfitController(useCase usecases.ProfitUseCase, businessUseCase usecases.BusinessUseCases) *ProfitController {
	return &ProfitController{
		profitUseCase:   useCase,
		businessUseCase: businessUseCase,
	}
}

// verifyBusinessOwnership checks that the authenticated user owns the business.
func (pc *ProfitController) verifyBusinessOwnership(c *gin.Context, businessID, userID string) bool {
	business, err := pc.businessUseCase.GetById(businessID)
	if err != nil || business == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Business not found"})
		return true
	}
	if business.UserID.Hex() != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "You don't have permission to access this business"})
		return true
	}
	return false
}

// GetSummary handles fetching profit summary for a period
func (pc *ProfitController) GetSummary(c *gin.Context) {
	businessID := c.Query("business_id")
	if businessID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "business_id query parameter is required"})
		return
	}

	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}
	if pc.verifyBusinessOwnership(c, businessID, userID) {
		return
	}

	var query domain.ProfitQuery
	if err := c.ShouldBindQuery(&query); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	summary, err := pc.profitUseCase.GetSummary(businessID, query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, summary)
}

// GetTrends handles fetching profit trends over time
func (pc *ProfitController) GetTrends(c *gin.Context) {
	businessID := c.Query("business_id")
	if businessID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "business_id query parameter is required"})
		return
	}

	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}
	if pc.verifyBusinessOwnership(c, businessID, userID) {
		return
	}

	var query domain.ProfitQuery
	if err := c.ShouldBindQuery(&query); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	trends, err := pc.profitUseCase.GetTrends(businessID, query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, trends)
}

// GetComparison handles comparing profit between two periods
func (pc *ProfitController) GetComparison(c *gin.Context) {
	businessID := c.Query("business_id")
	if businessID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "business_id query parameter is required"})
		return
	}

	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}
	if pc.verifyBusinessOwnership(c, businessID, userID) {
		return
	}

	var query domain.ProfitQuery
	if err := c.ShouldBindQuery(&query); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	comparison, err := pc.profitUseCase.GetComparison(businessID, query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, comparison)
}
