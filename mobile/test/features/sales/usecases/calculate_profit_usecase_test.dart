import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/core/value_objects/profit_summary.dart';
import 'package:mobile/features/sales/domain/repositories/sales_repository.dart';
import 'package:mobile/features/sales/domain/usecases/calculate_profit_usecase.dart';

class MockSalesRepository extends Mock implements SalesRepository {}

void main() {
  late CalculateProfitUseCase useCase;
  late MockSalesRepository mockRepository;

  setUp(() {
    mockRepository = MockSalesRepository();
    useCase = CalculateProfitUseCase(mockRepository);
  });

  const tBusinessId = 'b1';
  final tDateRange = DateRange(
    from: DateTime(2024, 1, 1),
    to: DateTime(2024, 1, 31),
  );

  final tProfitSummary = ProfitSummary(
    totalSales: 1000.00,
    totalExpenses: 400.00,
    profit: 600.00,
    startDate: tDateRange.from,
    endDate: tDateRange.to,
  );

  group('CalculateProfitUseCase', () {
    test(
      'should return profit summary when calculation is successful',
      () async {
        when(
          () => mockRepository.getProfitSummary(tBusinessId, tDateRange),
        ).thenAnswer((_) async => Right(tProfitSummary));

        final result = await useCase(
          ProfitParams(businessId: tBusinessId, dateRange: tDateRange),
        );

        expect(result, Right(tProfitSummary));
        expect(result.fold((l) => null, (r) => r.profit), 600.00);
        verify(
          () => mockRepository.getProfitSummary(tBusinessId, tDateRange),
        ).called(1);
      },
    );

    test(
      'should return profit summary with negative profit when expenses exceed sales',
      () async {
        final tLossSummary = ProfitSummary(
          totalSales: 300.00,
          totalExpenses: 500.00,
          profit: -200.00,
          startDate: tDateRange.from,
          endDate: tDateRange.to,
        );
        when(
          () => mockRepository.getProfitSummary(tBusinessId, tDateRange),
        ).thenAnswer((_) async => Right(tLossSummary));

        final result = await useCase(
          ProfitParams(businessId: tBusinessId, dateRange: tDateRange),
        );

        expect(result.fold((l) => null, (r) => r.profit), -200.00);
        expect(result.fold((l) => null, (r) => r.isProfit), false);
      },
    );

    test('should return failure when repository fails', () async {
      const failure = CacheFailure('Failed to calculate profit');
      when(
        () => mockRepository.getProfitSummary(tBusinessId, tDateRange),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        ProfitParams(businessId: tBusinessId, dateRange: tDateRange),
      );

      expect(result, const Left(failure));
    });
  });
}
