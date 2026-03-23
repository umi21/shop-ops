import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/enums/expense_category.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';

void main() {
  group('Expense Entity', () {
    test('should create an Expense with all required fields', () {
      final expense = Expense(
        id: '1',
        businessId: 'b1',
        category: ExpenseCategory.utilities,
        amount: 150.00,
        note: 'Electricity bill',
        createdAt: DateTime(2024, 1, 15),
      );

      expect(expense.id, '1');
      expect(expense.businessId, 'b1');
      expect(expense.category, ExpenseCategory.utilities);
      expect(expense.amount, 150.00);
      expect(expense.note, 'Electricity bill');
      expect(expense.isVoided, false);
    });

    test('should have default isVoided as false', () {
      final expense = Expense(
        id: '1',
        businessId: 'b1',
        category: ExpenseCategory.rent,
        amount: 500.00,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(expense.isVoided, false);
    });

    test('copyWith should create a new Expense with updated fields', () {
      final original = Expense(
        id: '1',
        businessId: 'b1',
        category: ExpenseCategory.utilities,
        amount: 100.00,
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(amount: 150.00, note: 'Updated note');

      expect(updated.id, '1');
      expect(updated.amount, 150.00);
      expect(updated.note, 'Updated note');
      expect(updated.category, ExpenseCategory.utilities);
    });

    test('two Expenses with same props should be equal', () {
      final expense1 = Expense(
        id: '1',
        businessId: 'b1',
        category: ExpenseCategory.transport,
        amount: 50.00,
        createdAt: DateTime(2024, 1, 1),
      );

      final expense2 = Expense(
        id: '1',
        businessId: 'b1',
        category: ExpenseCategory.transport,
        amount: 50.00,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(expense1, equals(expense2));
    });

    test('ExpenseCategory should have correct display names', () {
      expect(ExpenseCategory.rent.displayName, 'Rent');
      expect(ExpenseCategory.utilities.displayName, 'Utilities');
      expect(ExpenseCategory.stockPurchase.displayName, 'Stock Purchase');
      expect(ExpenseCategory.transport.displayName, 'Transport');
      expect(ExpenseCategory.maintenance.displayName, 'Maintenance');
      expect(ExpenseCategory.other.displayName, 'Other');
    });
  });
}
