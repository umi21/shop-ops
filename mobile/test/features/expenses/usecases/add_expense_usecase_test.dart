import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/enums/expense_category.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';
import 'package:mobile/features/expenses/domain/repositories/expense_repository.dart';
import 'package:mobile/features/expenses/domain/usecases/add_expense_usecase.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  late AddExpenseUseCase useCase;
  late MockExpenseRepository mockRepository;

  setUp(() {
    mockRepository = MockExpenseRepository();
    useCase = AddExpenseUseCase(mockRepository);
  });

  final tExpense = Expense(
    id: '1',
    businessId: 'b1',
    category: ExpenseCategory.utilities,
    amount: 150.00,
    note: 'Monthly electricity bill',
    createdAt: DateTime(2024, 1, 15),
  );

  group('AddExpenseUseCase', () {
    test('should return expense when adding expense is successful', () async {
      when(
        () => mockRepository.addExpense(tExpense),
      ).thenAnswer((_) async => Right(tExpense));

      final result = await useCase(AddExpenseParams(expense: tExpense));

      expect(result, Right(tExpense));
      verify(() => mockRepository.addExpense(tExpense)).called(1);
    });

    test('should return CacheFailure when local storage fails', () async {
      const failure = CacheFailure('Failed to save expense');
      when(
        () => mockRepository.addExpense(tExpense),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(AddExpenseParams(expense: tExpense));

      expect(result, const Left(failure));
    });
  });
}
