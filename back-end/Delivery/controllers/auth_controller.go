package controllers

import (
	"net/http"
	"net/mail"
	"regexp"

	usecases "shop-ops/Usecases"

	"github.com/gin-gonic/gin"
)

type AuthController struct {
	userUseCases usecases.UserUseCases
}

func NewAuthController(u usecases.UserUseCases) *AuthController {
	return &AuthController{
		userUseCases: u,
	}
}

func (c *AuthController) Register(ctx *gin.Context) {
	var req usecases.RegisterRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body", "details": err.Error(), "code": "VAL_001"})
		return
	}

	if req.Phone == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "phone is required", "code": "VAL_002"})
		return
	}

	validPhone := regexp.MustCompile(`^\+[1-9]\d{1,14}$`)
	if !validPhone.MatchString(req.Phone) {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid phone format", "code": "VAL_002"})
		return
	}

	if req.Email != "" {
		if _, err := mail.ParseAddress(req.Email); err != nil {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid email format", "code": "VAL_002"})
			return
		}
	}

	if len(req.Password) < 8 {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "password must be at least 8 characters", "code": "VAL_002"})
		return
	}

	user, err := c.userUseCases.Register(&req)
	if err != nil {
		status := http.StatusBadRequest
		if err.Error() == "user with this phone already exists" || err.Error() == "user with this email already exists" {
			status = http.StatusConflict
		}
		ctx.JSON(status, gin.H{"error": err.Error(), "code": "AUTH_001"})
		return
	}

	ctx.JSON(http.StatusCreated, user)
}

func (c *AuthController) Login(ctx *gin.Context) {
	var req struct {
		Phone    string `json:"phone" binding:"required"`
		Password string `json:"password" binding:"required"`
	}
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Phone and password are required", "code": "VAL_002"})
		return
	}

	resp, err := c.userUseCases.Login(req.Phone, req.Password)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials", "code": "AUTH_002"})
		return
	}

	ctx.JSON(http.StatusOK, resp)
}

func (c *AuthController) RefreshToken(ctx *gin.Context) {
	var req struct {
		RefreshToken string `json:"refresh_token" binding:"required"`
	}
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Refresh token is required", "code": "VAL_003"})
		return
	}

	resp, err := c.userUseCases.RefreshToken(req.RefreshToken)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": err.Error(), "code": "AUTH_003"})
		return
	}

	ctx.JSON(http.StatusOK, resp)
}
