package usecases

// ExpenseUsecases contains business logic for expense operations


/*
func (uc *expenseUseCase) CreateExpense(businessID, userID string, req Domain.CreateExpenseRequest) (*Domain.Expense, error) {
	 ... existing code ...
	
	
	if req.Category == Domain.ExpenseCategoryStockPurchase && req.ProductID != nil {
		referenceID := expense.ID.Hex()
		if err := uc.inventoryRepo.AdjustStock(
			*req.ProductID,
			req.Quantity, // Assume quantity field exists
			Domain.MovementTypePurchase,
			"Stock purchase",
			&referenceID,
			userID,
		); err != nil {
			fmt.Printf("Failed to update inventory for purchase: %v\n", err)
		}
	}
	
	return expense, nil
}
*/