package domain

import "time"

// RestoreResponse holds the data for a business restore operation.
// Only requested entity types will be populated (controlled by the `include` filter).
type RestoreResponse struct {
	Sales      []Sale    `json:"sales,omitempty"`
	Expenses   []Expense `json:"expenses,omitempty"`
	Products   []Product `json:"products,omitempty"`
	Since      *string   `json:"since,omitempty"`
	RestoredAt time.Time `json:"restored_at"`
}
