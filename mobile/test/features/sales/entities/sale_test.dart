import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';

void main() {
  group('Sale Entity', () {
    test('should create a Sale with all required fields', () {
      final sale = Sale(
        id: '1',
        businessId: 'b1',
        productId: 'p1',
        unitPrice: 25.00,
        quantity: 2,
        total: 50.00,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(sale.id, '1');
      expect(sale.businessId, 'b1');
      expect(sale.productId, 'p1');
      expect(sale.unitPrice, 25.00);
      expect(sale.quantity, 2);
      expect(sale.total, 50.00);
      expect(sale.isVoided, false);
    });

    test('should calculate total from unitPrice and quantity', () {
      final sale = Sale(
        id: '1',
        businessId: 'b1',
        productId: 'p1',
        unitPrice: 25.00,
        quantity: 3,
        total: 75.00,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(sale.total, 75.00);
    });

    test('should have default isVoided as false', () {
      final sale = Sale(
        id: '1',
        businessId: 'b1',
        productId: 'p1',
        unitPrice: 25.00,
        quantity: 1,
        total: 25.00,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(sale.isVoided, false);
    });

    test('Sale.create factory should calculate total automatically', () {
      final sale = Sale.create(
        id: '1',
        businessId: 'b1',
        productId: 'p1',
        unitPrice: 30.00,
        quantity: 4,
      );

      expect(sale.total, 120.00);
    });

    test('copyWith should create a new Sale with updated fields', () {
      final original = Sale(
        id: '1',
        businessId: 'b1',
        productId: 'p1',
        unitPrice: 25.00,
        quantity: 2,
        total: 50.00,
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(
        quantity: 5,
        total: 125.00,
        isVoided: true,
      );

      expect(updated.id, '1');
      expect(updated.quantity, 5);
      expect(updated.total, 125.00);
      expect(updated.isVoided, true);
    });

    test('two Sales with same props should be equal', () {
      final sale1 = Sale(
        id: '1',
        businessId: 'b1',
        productId: 'p1',
        unitPrice: 25.00,
        quantity: 2,
        total: 50.00,
        createdAt: DateTime(2024, 1, 1),
      );

      final sale2 = Sale(
        id: '1',
        businessId: 'b1',
        productId: 'p1',
        unitPrice: 25.00,
        quantity: 2,
        total: 50.00,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(sale1, equals(sale2));
    });
  });
}
