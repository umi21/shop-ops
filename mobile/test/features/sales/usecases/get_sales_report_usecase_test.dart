import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';
import 'package:mobile/features/sales/domain/repositories/sales_repository.dart';
import 'package:mobile/features/sales/domain/usecases/get_sales_report_usecase.dart';

class MockSalesRepository extends Mock implements SalesRepository {}

void main() {
  late GetSalesReportUseCase useCase;
  late MockSalesRepository mockRepository;

  setUp(() {
    mockRepository = MockSalesRepository();
    useCase = GetSalesReportUseCase(mockRepository);
  });

  const tBusinessId = 'b1';
  final tDateRange = DateRange(
    from: DateTime(2024, 1, 1),
    to: DateTime(2024, 1, 31),
  );

  final tSales = [
    Sale(
      id: '1',
      businessId: 'b1',
      productId: 'p1',
      unitPrice: 25.00,
      quantity: 2,
      total: 50.00,
      createdAt: DateTime(2024, 1, 5),
    ),
    Sale(
      id: '2',
      businessId: 'b1',
      productId: 'p2',
      unitPrice: 30.00,
      quantity: 3,
      total: 90.00,
      createdAt: DateTime(2024, 1, 10),
    ),
  ];

  group('GetSalesReportUseCase', () {
    test('should return sales for date range when successful', () async {
      when(
        () => mockRepository.getSalesByDateRange(tBusinessId, tDateRange),
      ).thenAnswer((_) async => Right(tSales));

      final result = await useCase(
        SalesReportParams(businessId: tBusinessId, dateRange: tDateRange),
      );

      expect(result, Right(tSales));
      verify(
        () => mockRepository.getSalesByDateRange(tBusinessId, tDateRange),
      ).called(1);
    });

    test('should return empty list when no sales in date range', () async {
      when(
        () => mockRepository.getSalesByDateRange(tBusinessId, tDateRange),
      ).thenAnswer((_) async => const Right<Failure, List<Sale>>([]));

      final result = await useCase(
        SalesReportParams(businessId: tBusinessId, dateRange: tDateRange),
      );

      expect(result, const Right<Failure, List<Sale>>([]));
    });
  });
}
