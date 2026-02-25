package domain

import (
	"time"

	"github.com/shopspring/decimal"
)

// DateRange represents a period of time
type DateRange struct {
	From time.Time `json:"from"`
	To   time.Time `json:"to"`
}

// ProfitSummary represents the calculated profit for a period
type ProfitSummary struct {
	TotalSales    decimal.Decimal `json:"total_sales"`
	TotalExpenses decimal.Decimal `json:"total_expenses"`
	Profit        decimal.Decimal `json:"profit"`
	StartDate     time.Time       `json:"start_date"`
	EndDate       time.Time       `json:"end_date"`
}

// NewProfitSummary creates a new ProfitSummary and calculates profit
func NewProfitSummary(sales, expenses decimal.Decimal, start, end time.Time) *ProfitSummary {
	profit := sales.Sub(expenses)
	return &ProfitSummary{
		TotalSales:    sales,
		TotalExpenses: expenses,
		Profit:        profit,
		StartDate:     start,
		EndDate:       end,
	}
}

// IsProfit checks if the business made a profit (greater than zero)
func (ps *ProfitSummary) IsProfit() bool {
	return ps.Profit.GreaterThan(decimal.Zero)
}
