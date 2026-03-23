import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';
import 'package:mobile/features/sales/domain/repositories/sales_repository.dart';
import 'package:mobile/features/sales/domain/usecases/add_sale_usecase.dart';

class MockSalesRepository extends Mock implements SalesRepository {}

void main() {
  late AddSaleUseCase useCase;
  late MockSalesRepository mockRepository;

  setUp(() {
    mockRepository = MockSalesRepository();
    useCase = AddSaleUseCase(mockRepository);
  });

  final tSale = Sale(
    id: '1',
    businessId: 'b1',
    productId: 'p1',
    unitPrice: 25.00,
    quantity: 2,
    total: 50.00,
    createdAt: DateTime(2024, 1, 15),
  );

  group('AddSaleUseCase', () {
    test('should return sale when adding sale is successful', () async {
      when(
        () => mockRepository.addSale(tSale),
      ).thenAnswer((_) async => Right(tSale));

      final result = await useCase(AddSaleParams(sale: tSale));

      expect(result, Right(tSale));
      verify(() => mockRepository.addSale(tSale)).called(1);
    });

    test('should return CacheFailure when local storage fails', () async {
      const failure = CacheFailure('Failed to save sale');
      when(
        () => mockRepository.addSale(tSale),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(AddSaleParams(sale: tSale));

      expect(result, const Left(failure));
    });
  });
}
