package repositories

import (
	"context"
	"fmt"
	"time"

	Domain "shop-ops/Domain"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

// BusinessRepository handles data access for businesses
type BusinessRepository struct {
	collection *mongo.Collection
}

// NewBusinessRepository creates a new BusinessRepository backed by the "businesses" collection
func NewBusinessRepository(db *mongo.Database) Domain.BusinessRepository {
	return &BusinessRepository{
		collection: db.Collection("businesses"),
	}
}

// FindByID retrieves a business by its ObjectID hex string
func (r *BusinessRepository) FindByID(id string) (*Domain.Business, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return nil, fmt.Errorf("invalid business ID: %w", err)
	}

	var business Domain.Business
	err = r.collection.FindOne(ctx, bson.M{"_id": objID}).Decode(&business)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to find business: %w", err)
	}

	return &business, nil
}
