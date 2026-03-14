package controllers

import (
	"net/http"
	"strings"
	"time"

	Usecases "shop-ops/Usecases"

	"github.com/gin-gonic/gin"
)

// RestoreController handles HTTP requests for the data restore feature
type RestoreController struct {
	restoreUC  Usecases.RestoreUseCases
	businessUC Usecases.BusinessUseCases
}

// NewRestoreController creates a new RestoreController
func NewRestoreController(restoreUC Usecases.RestoreUseCases, businessUC Usecases.BusinessUseCases) *RestoreController {
	return &RestoreController{restoreUC: restoreUC, businessUC: businessUC}
}

// verifyBusinessOwnership checks that the authenticated user owns the business.
// Returns true if access is denied (caller should return early).
func (c *RestoreController) verifyBusinessOwnership(ctx *gin.Context, businessID, userID string) bool {
	business, err := c.businessUC.GetById(businessID)
	if err != nil || business == nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Business not found"})
		return true
	}
	if business.UserID.Hex() != userID {
		ctx.JSON(http.StatusForbidden, gin.H{"error": "You don't have permission to access this business"})
		return true
	}
	return false
}

// parseInclude parses the comma-separated include query parameter.
// Returns nil if not provided (meaning include all).
func parseInclude(raw string) []string {
	if raw == "" {
		return nil
	}
	valid := map[string]bool{"sales": true, "expenses": true, "products": true}
	parts := strings.Split(raw, ",")
	var result []string
	for _, p := range parts {
		p = strings.TrimSpace(strings.ToLower(p))
		if valid[p] {
			result = append(result, p)
		}
	}
	return result
}

// FullRestore godoc
// @Summary      Full data restore
// @Description  Returns all sales, expenses, and products for a business. Use the include filter to select specific entity types.
// @Tags         restore
// @Produce      json
// @Param        businessId  path   string  true   "Business ID"
// @Param        include     query  string  false  "Comma-separated list of entity types to include (sales, expenses, products)"
// @Success      200  {object}  domain.RestoreResponse
// @Failure      400  {object}  map[string]interface{}
// @Failure      401  {object}  map[string]interface{}
// @Failure      403  {object}  map[string]interface{}
// @Router       /api/businesses/{businessId}/restore [get]
// @Security     BearerAuth
func (c *RestoreController) FullRestore(ctx *gin.Context) {
	businessID := ctx.Param("businessId")
	if businessID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Business ID is required"})
		return
	}

	userID := ctx.GetString("user_id")
	if userID == "" {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}
	if c.verifyBusinessOwnership(ctx, businessID, userID) {
		return
	}

	include := parseInclude(ctx.Query("include"))

	response, err := c.restoreUC.FullRestore(businessID, include)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, response)
}

// IncrementalRestore godoc
// @Summary      Incremental data restore
// @Description  Returns sales, expenses, and products modified since a given timestamp. Use the include filter to select entity types.
// @Tags         restore
// @Produce      json
// @Param        businessId  path   string  true   "Business ID"
// @Param        since       query  string  true   "Timestamp in RFC3339 format (e.g. 2024-01-15T10:30:00Z)"
// @Param        include     query  string  false  "Comma-separated list of entity types to include (sales, expenses, products)"
// @Success      200  {object}  domain.RestoreResponse
// @Failure      400  {object}  map[string]interface{}
// @Failure      401  {object}  map[string]interface{}
// @Failure      403  {object}  map[string]interface{}
// @Router       /api/businesses/{businessId}/restore/incremental [get]
// @Security     BearerAuth
func (c *RestoreController) IncrementalRestore(ctx *gin.Context) {
	businessID := ctx.Param("businessId")
	if businessID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Business ID is required"})
		return
	}

	sinceStr := ctx.Query("since")
	if sinceStr == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "since query parameter is required (RFC3339 format)"})
		return
	}

	since, err := time.Parse(time.RFC3339, sinceStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid since format. Use RFC3339 (e.g. 2024-01-15T10:30:00Z)"})
		return
	}

	userID := ctx.GetString("user_id")
	if userID == "" {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}
	if c.verifyBusinessOwnership(ctx, businessID, userID) {
		return
	}

	include := parseInclude(ctx.Query("include"))

	response, err := c.restoreUC.IncrementalRestore(businessID, since, include)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, response)
}
