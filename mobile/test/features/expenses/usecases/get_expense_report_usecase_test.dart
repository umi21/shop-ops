import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/enums/expense_category.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';
import 'package:mobile/features/expenses/domain/repositories/expense_repository.dart';
import 'package:mobile/features/expenses/domain/usecases/get_expense_report_usecase.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  late GetExpenseReportUseCase useCase;
  late MockExpenseRepository mockRepository;

  setUp(() {
    mockRepository = MockExpenseRepository();
    useCase = GetExpenseReportUseCase(mockRepository);
  });

  const tBusinessId = 'b1';
  final tDateRange = DateRange(
    from: DateTime(2024, 1, 1),
    to: DateTime(2024, 1, 31),
  );

  final tExpenses = [
    Expense(
      id: '1',
      businessId: 'b1',
      category: ExpenseCategory.utilities,
      amount: 100.00,
      createdAt: DateTime(2024, 1, 5),
    ),
    Expense(
      id: '2',
      businessId: 'b1',
      category: ExpenseCategory.rent,
      amount: 500.00,
      createdAt: DateTime(2024, 1, 10),
    ),
  ];

  group('GetExpenseReportUseCase', () {
    test('should return expenses for date range when successful', () async {
      when(
        () => mockRepository.getExpensesByDateRange(tBusinessId, tDateRange),
      ).thenAnswer((_) async => Right(tExpenses));

      final result = await useCase(
        ExpenseReportParams(businessId: tBusinessId, dateRange: tDateRange),
      );

      expect(result, Right(tExpenses));
      verify(
        () => mockRepository.getExpensesByDateRange(tBusinessId, tDateRange),
      ).called(1);
    });

    test('should return empty list when no expenses in date range', () async {
      when(
        () => mockRepository.getExpensesByDateRange(tBusinessId, tDateRange),
      ).thenAnswer((_) async => const Right<Failure, List<Expense>>([]));

      final result = await useCase(
        ExpenseReportParams(businessId: tBusinessId, dateRange: tDateRange),
      );

      expect(result, const Right<Failure, List<Expense>>([]));
    });

    test('should return CacheFailure when local storage fails', () async {
      const failure = CacheFailure('Failed to get expenses');
      when(
        () => mockRepository.getExpensesByDateRange(tBusinessId, tDateRange),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        ExpenseReportParams(businessId: tBusinessId, dateRange: tDateRange),
      );

      expect(result, const Left(failure));
    });
  });
}
