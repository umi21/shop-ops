enum ExpenseCategory {
  rent,
  utilities,
  stockPurchase,
  transport,
  maintenance,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.stockPurchase:
        return 'Stock Purchase';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.maintenance:
        return 'Maintenance';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }
}
