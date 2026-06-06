import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';
import 'package:mobile/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:mobile/features/inventory/domain/usecases/get_products_usecase.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late GetProductsUseCase useCase;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = GetProductsUseCase(mockRepository);
  });

  const tBusinessId = 'b1';
  final tProducts = [
    Product(
      id: '1',
      businessId: 'b1',
      name: 'Product 1',
      defaultSellingPrice: 10.0,
      stockQuantity: 50,
      lowStockThreshold: 5,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Product(
      id: '2',
      businessId: 'b1',
      name: 'Product 2',
      defaultSellingPrice: 20.0,
      stockQuantity: 3,
      lowStockThreshold: 5,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  group('GetProductsUseCase', () {
    test('should return list of products when successful', () async {
      when(
        () => mockRepository.getProducts(tBusinessId),
      ).thenAnswer((_) async => Right(tProducts));

      final result = await useCase(tBusinessId);

      expect(result, Right(tProducts));
      verify(() => mockRepository.getProducts(tBusinessId)).called(1);
    });

    test('should return empty list when no products exist', () async {
      when(
        () => mockRepository.getProducts(tBusinessId),
      ).thenAnswer((_) async => const Right<Failure, List<Product>>([]));

      final result = await useCase(tBusinessId);

      expect(result, const Right<Failure, List<Product>>([]));
    });

    test('should return CacheFailure when local storage fails', () async {
      const failure = CacheFailure('Failed to get products');
      when(
        () => mockRepository.getProducts(tBusinessId),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(tBusinessId);

      expect(result, const Left(failure));
    });
  });
}
