import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';
import 'package:mobile/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:mobile/features/inventory/domain/usecases/add_product_usecase.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late AddProductUseCase useCase;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = AddProductUseCase(mockRepository);
  });

  final tProduct = Product(
    id: '1',
    businessId: 'b1',
    name: 'Test Product',
    defaultSellingPrice: 99.99,
    stockQuantity: 100,
    lowStockThreshold: 5,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('AddProductUseCase', () {
    test('should return product when adding product is successful', () async {
      when(
        () => mockRepository.addProduct(tProduct),
      ).thenAnswer((_) async => Right(tProduct));

      final result = await useCase(AddProductParams(product: tProduct));

      expect(result, Right(tProduct));
      verify(() => mockRepository.addProduct(tProduct)).called(1);
    });

    test('should return CacheFailure when local storage fails', () async {
      const failure = CacheFailure('Failed to save product');
      when(
        () => mockRepository.addProduct(tProduct),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(AddProductParams(product: tProduct));

      expect(result, const Left(failure));
    });
  });
}
