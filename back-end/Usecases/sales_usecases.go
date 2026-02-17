package usecases

// SalesUsecases contains business logic for sales operations

/*
func (uc *salesUseCase) CreateSale(businessID, userID string, req Domain.CreateSaleRequest) (*Domain.Sale, error) {
	 ... existing code ...
	
	 After creating sale, update inventory
	if productID != nil {
		referenceID := sale.ID.Hex()
		if err := uc.inventoryRepo.AdjustStock(
			productID.Hex(),
			req.Quantity,
			Domain.MovementTypeSale,
			"Sale transaction",
			&referenceID,
			userID,
		); err != nil {
			fmt.Printf("Failed to update inventory for sale: %v\n", err)
		}
	}
	
	return sale, nil
}
*/

