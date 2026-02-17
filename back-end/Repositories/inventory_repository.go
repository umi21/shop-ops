package repositories

import (
	"context"
	"fmt"
	"time"

	Domain "shop-ops/Domain"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type InventoryRepository struct {
	productsCollection  *mongo.Collection
	movementsCollection *mongo.Collection
}

func NewInventoryRepository(db *mongo.Database) Domain.ProductRepository {
	return &InventoryRepository{
		productsCollection:  db.Collection("products"),
		movementsCollection: db.Collection("stock_movements"),
	}
}

func (r *InventoryRepository) Create(product *Domain.Product) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	product.CreatedAt = time.Now()
	product.UpdatedAt = time.Now()

	result, err := r.productsCollection.InsertOne(ctx, product)
	if err != nil {
		return fmt.Errorf("failed to create product: %w", err)
	}

	product.ID = result.InsertedID.(primitive.ObjectID)

	// Create initial stock movement if stock > 0
	if product.StockQuantity > 0 {
		movement := Domain.StockMovement{
			BusinessID:  product.BusinessID,
			ProductID:   product.ID,
			Type:        Domain.MovementTypePurchase,
			Quantity:    product.StockQuantity,
			Reason:      "Initial stock",
			CreatedBy:   product.BusinessID, // Using BusinessID as fallback
			CreatedAt:   time.Now(),
		}

		_, err = r.movementsCollection.InsertOne(ctx, movement)
		if err != nil {
			// Log error but don't fail product creation
			fmt.Printf("Failed to create stock movement: %v\n", err)
		}
	}

	return nil
}

func (r *InventoryRepository) FindByID(id string) (*Domain.Product, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return nil, fmt.Errorf("invalid product ID: %w", err)
	}

	var product Domain.Product
	err = r.productsCollection.FindOne(ctx, bson.M{"_id": objID}).Decode(&product)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to find product: %w", err)
	}

	return &product, nil
}

func (r *InventoryRepository) FindByBusinessID(businessID string, query Domain.ProductListQuery) ([]Domain.Product, int64, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	objBusinessID, err := primitive.ObjectIDFromHex(businessID)
	if err != nil {
		return nil, 0, fmt.Errorf("invalid business ID: %w", err)
	}

	// Build filter
	filter := bson.M{"business_id": objBusinessID}

	// Search by name
	if query.Search != "" {
		filter["name"] = bson.M{
			"$regex":   query.Search,
			"$options": "i",
		}
	}

	// Low stock filter
	if query.LowStockOnly {
		filter["$expr"] = bson.M{
			"$lte": []interface{}{"$stock_quantity", "$low_stock_threshold"},
		}
	}

	// Set default pagination values
	if query.Page < 1 {
		query.Page = 1
	}
	if query.Limit < 1 {
		query.Limit = 50
	}
	skip := (query.Page - 1) * query.Limit

	// Set sort order
	sortField := query.Sort
	if sortField == "" {
		sortField = "name"
	}
	sortOrder := 1
	if query.Order == "desc" {
		sortOrder = -1
	}
	sort := bson.D{{Key: sortField, Value: sortOrder}}

	// Get total count
	total, err := r.productsCollection.CountDocuments(ctx, filter)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count products: %w", err)
	}

	// Find products with pagination
	opts := options.Find().
		SetSort(sort).
		SetSkip(int64(skip)).
		SetLimit(int64(query.Limit))

	cursor, err := r.productsCollection.Find(ctx, filter, opts)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to find products: %w", err)
	}
	defer cursor.Close(ctx)

	var products []Domain.Product
	if err := cursor.All(ctx, &products); err != nil {
		return nil, 0, fmt.Errorf("failed to decode products: %w", err)
	}

	return products, total, nil
}

func (r *InventoryRepository) Update(product *Domain.Product) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	product.UpdatedAt = time.Now()

	update := bson.M{
		"$set": bson.M{
			"name":                   product.Name,
			"default_selling_price":  product.DefaultSellingPrice,
			"low_stock_threshold":    product.LowStockThreshold,
			"updated_at":             product.UpdatedAt,
		},
	}

	_, err := r.productsCollection.UpdateByID(ctx, product.ID, update)
	if err != nil {
		return fmt.Errorf("failed to update product: %w", err)
	}

	return nil
}

func (r *InventoryRepository) Delete(id string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return fmt.Errorf("invalid product ID: %w", err)
	}

	// Hard delete for products
	_, err = r.productsCollection.DeleteOne(ctx, bson.M{"_id": objID})
	return err
}

func (r *InventoryRepository) AdjustStock(productID string, quantity int, movementType Domain.MovementType, reason string, referenceID *string, userID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	objProductID, err := primitive.ObjectIDFromHex(productID)
	if err != nil {
		return fmt.Errorf("invalid product ID: %w", err)
	}

	objUserID, err := primitive.ObjectIDFromHex(userID)
	if err != nil {
		return fmt.Errorf("invalid user ID: %w", err)
	}

	// Get current product
	var product Domain.Product
	err = r.productsCollection.FindOne(ctx, bson.M{"_id": objProductID}).Decode(&product)
	if err != nil {
		return fmt.Errorf("failed to find product: %w", err)
	}

	// Calculate new stock based on movement type
	var newStock int
	var quantityChange int

	switch movementType {
	case Domain.MovementTypePurchase, Domain.MovementTypeReturn:
		// Purchase and Return increase stock
		newStock = product.StockQuantity + quantity
		quantityChange = quantity // Positive
	case Domain.MovementTypeSale, Domain.MovementTypeDamage, Domain.MovementTypeTheft:
		// Sale, Damage, Theft decrease stock
		newStock = product.StockQuantity - quantity
		if newStock < 0 {
			return fmt.Errorf("insufficient stock. Available: %d, Required: %d", product.StockQuantity, quantity)
		}
		quantityChange = -quantity // Negative
	case Domain.MovementTypeAdjust:
		// Adjust can set to any value - quantity becomes the new stock
		newStock = quantity
		quantityChange = quantity - product.StockQuantity // Calculate the change (could be positive or negative)
	default:
		return fmt.Errorf("invalid movement type: %s", movementType)
	}

	// Update product stock
	update := bson.M{
		"$set": bson.M{
			"stock_quantity": newStock,
			"updated_at":     time.Now(),
		},
	}

	_, err = r.productsCollection.UpdateByID(ctx, objProductID, update)
	if err != nil {
		return fmt.Errorf("failed to update product stock: %w", err)
	}

	// Create stock movement record
	movement := Domain.StockMovement{
		BusinessID:  product.BusinessID,
		ProductID:   objProductID,
		Type:        movementType,
		Quantity:    quantityChange, // Positive for increase, negative for decrease
		Reason:      reason,
		CreatedBy:   objUserID,
		CreatedAt:   time.Now(),
	}

	if referenceID != nil {
		objReferenceID, err := primitive.ObjectIDFromHex(*referenceID)
		if err == nil {
			movement.ReferenceID = &objReferenceID
		}
	}

	_, err = r.movementsCollection.InsertOne(ctx, movement)
	if err != nil {
		return fmt.Errorf("failed to create stock movement: %w", err)
	}

	return nil
}

func (r *InventoryRepository) GetLowStock(businessID string) ([]Domain.Product, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	objBusinessID, err := primitive.ObjectIDFromHex(businessID)
	if err != nil {
		return nil, fmt.Errorf("invalid business ID: %w", err)
	}

	// Products where stock_quantity <= low_stock_threshold
	filter := bson.M{
		"business_id": objBusinessID,
		"$expr": bson.M{
			"$lte": []interface{}{"$stock_quantity", "$low_stock_threshold"},
		},
	}

	cursor, err := r.productsCollection.Find(ctx, filter)
	if err != nil {
		return nil, fmt.Errorf("failed to find low stock products: %w", err)
	}
	defer cursor.Close(ctx)

	var products []Domain.Product
	if err := cursor.All(ctx, &products); err != nil {
		return nil, fmt.Errorf("failed to decode products: %w", err)
	}

	return products, nil
}

func (r *InventoryRepository) GetStockHistory(productID string, limit int) ([]Domain.StockMovement, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	objProductID, err := primitive.ObjectIDFromHex(productID)
	if err != nil {
		return nil, fmt.Errorf("invalid product ID: %w", err)
	}

	if limit <= 0 {
		limit = 50
	}

	opts := options.Find().
		SetSort(bson.M{"created_at": -1}).
		SetLimit(int64(limit))

	cursor, err := r.movementsCollection.Find(ctx, bson.M{"product_id": objProductID}, opts)
	if err != nil {
		return nil, fmt.Errorf("failed to find stock history: %w", err)
	}
	defer cursor.Close(ctx)

	var movements []Domain.StockMovement
	if err := cursor.All(ctx, &movements); err != nil {
		return nil, fmt.Errorf("failed to decode movements: %w", err)
	}

	return movements, nil
}