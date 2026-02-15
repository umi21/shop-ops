package domain

import (
	"errors"
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

// User represents a shop owner or user in the system
type User struct {
	ID           primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	Phone        string             `bson:"phone" json:"phone"`
	Email        string             `bson:"email" json:"email"`
	PasswordHash string             `bson:"password_hash" json:"-"` // Never return password hash in JSON
	Name         string             `bson:"name" json:"name"`
	CreatedAt    time.Time          `bson:"created_at" json:"created_at"`
	UpdatedAt    time.Time          `bson:"updated_at" json:"updated_at"`
}

// NewUser creates a new User instance
func NewUser(name, phone, email, passwordHash string) *User {
	now := time.Now()
	return &User{
		ID:           primitive.NewObjectID(),
		Name:         name,
		Phone:        phone,
		Email:        email,
		PasswordHash: passwordHash,
		CreatedAt:    now,
		UpdatedAt:    now,
	}
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if u.Name == "" {
		return errors.New("user name is required")
	}
	if u.Phone == "" && u.Email == "" {
		return errors.New("either phone or email is required")
	}
	if u.PasswordHash == "" {
		return errors.New("password hash is required")
	}
	return nil
}
