import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';

void main() {
  group('Product Entity', () {
    test('should create a Product with all required fields', () {
      final product = Product(
        id: '1',
        businessId: 'b1',
        name: 'Test Product',
        defaultSellingPrice: 29.99,
        stockQuantity: 100,
        lowStockThreshold: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(product.id, '1');
      expect(product.businessId, 'b1');
      expect(product.name, 'Test Product');
      expect(product.defaultSellingPrice, 29.99);
      expect(product.stockQuantity, 100);
      expect(product.lowStockThreshold, 5);
    });

    test(
      'isLowStock should return true when stock is at or below threshold',
      () {
        final lowStockProduct = Product(
          id: '1',
          businessId: 'b1',
          name: 'Low Stock Product',
          defaultSellingPrice: 29.99,
          stockQuantity: 3,
          lowStockThreshold: 5,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final normalStockProduct = Product(
          id: '2',
          businessId: 'b1',
          name: 'Normal Stock Product',
          defaultSellingPrice: 29.99,
          stockQuantity: 10,
          lowStockThreshold: 5,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        expect(lowStockProduct.isLowStock, true);
        expect(normalStockProduct.isLowStock, false);
      },
    );

    test('isOutOfStock should return true when stock is zero', () {
      final outOfStockProduct = Product(
        id: '1',
        businessId: 'b1',
        name: 'Out of Stock Product',
        defaultSellingPrice: 29.99,
        stockQuantity: 0,
        lowStockThreshold: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final inStockProduct = Product(
        id: '2',
        businessId: 'b1',
        name: 'In Stock Product',
        defaultSellingPrice: 29.99,
        stockQuantity: 10,
        lowStockThreshold: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(outOfStockProduct.isOutOfStock, true);
      expect(inStockProduct.isOutOfStock, false);
    });

    test('copyWith should create a new Product with updated fields', () {
      final original = Product(
        id: '1',
        businessId: 'b1',
        name: 'Original Product',
        defaultSellingPrice: 29.99,
        stockQuantity: 100,
        lowStockThreshold: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(
        name: 'Updated Product',
        stockQuantity: 50,
      );

      expect(updated.id, '1');
      expect(updated.name, 'Updated Product');
      expect(updated.stockQuantity, 50);
      expect(updated.defaultSellingPrice, 29.99);
    });

    test('two Products with same props should be equal', () {
      final product1 = Product(
        id: '1',
        businessId: 'b1',
        name: 'Test Product',
        defaultSellingPrice: 29.99,
        stockQuantity: 100,
        lowStockThreshold: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final product2 = Product(
        id: '1',
        businessId: 'b1',
        name: 'Test Product',
        defaultSellingPrice: 29.99,
        stockQuantity: 100,
        lowStockThreshold: 5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(product1, equals(product2));
    });
  });
}
