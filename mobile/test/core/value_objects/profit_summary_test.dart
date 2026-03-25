import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/value_objects/profit_summary.dart';

void main() {
  group('ProfitSummary Value Object', () {
    test('should create ProfitSummary with all fields', () {
      final summary = ProfitSummary(
        totalSales: 1000.00,
        totalExpenses: 400.00,
        profit: 600.00,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      expect(summary.totalSales, 1000.00);
      expect(summary.totalExpenses, 400.00);
      expect(summary.profit, 600.00);
    });

    test('isProfit should return true when profit is positive', () {
      final profitSummary = ProfitSummary(
        totalSales: 1000.00,
        totalExpenses: 400.00,
        profit: 600.00,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      expect(profitSummary.isProfit, true);
    });

    test('isProfit should return false when profit is zero or negative', () {
      final zeroProfitSummary = ProfitSummary(
        totalSales: 400.00,
        totalExpenses: 400.00,
        profit: 0.00,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final lossSummary = ProfitSummary(
        totalSales: 300.00,
        totalExpenses: 500.00,
        profit: -200.00,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      expect(zeroProfitSummary.isProfit, false);
      expect(lossSummary.isProfit, false);
    });

    test('empty factory should create summary with zero values', () {
      final emptySummary = ProfitSummary.empty();

      expect(emptySummary.totalSales, 0);
      expect(emptySummary.totalExpenses, 0);
      expect(emptySummary.profit, 0);
      expect(emptySummary.isProfit, false);
    });

    test('two ProfitSummaries with same props should be equal', () {
      final summary1 = ProfitSummary(
        totalSales: 1000.00,
        totalExpenses: 400.00,
        profit: 600.00,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final summary2 = ProfitSummary(
        totalSales: 1000.00,
        totalExpenses: 400.00,
        profit: 600.00,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      expect(summary1, equals(summary2));
    });
  });
}
