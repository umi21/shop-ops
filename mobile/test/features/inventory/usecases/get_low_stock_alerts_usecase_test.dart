import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';
import 'package:mobile/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:mobile/features/inventory/domain/usecases/get_low_stock_alerts_usecase.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late GetLowStockAlertsUseCase useCase;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = GetLowStockAlertsUseCase(mockRepository);
  });

  const tBusinessId = 'b1';
  final tLowStockProducts = [
    Product(
      id: '1',
      businessId: 'b1',
      name: 'Low Stock Product',
      defaultSellingPrice: 10.0,
      stockQuantity: 3,
      lowStockThreshold: 5,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  group('GetLowStockAlertsUseCase', () {
    test('should return low stock products when alert is successful', () async {
      when(
        () => mockRepository.getLowStockProducts(tBusinessId),
      ).thenAnswer((_) async => Right(tLowStockProducts));

      final result = await useCase(tBusinessId);

      expect(result, Right(tLowStockProducts));
      verify(() => mockRepository.getLowStockProducts(tBusinessId)).called(1);
    });

    test('should return empty list when no low stock products', () async {
      when(
        () => mockRepository.getLowStockProducts(tBusinessId),
      ).thenAnswer((_) async => const Right<Failure, List<Product>>([]));

      final result = await useCase(tBusinessId);

      expect(result, const Right<Failure, List<Product>>([]));
    });
  });
}
