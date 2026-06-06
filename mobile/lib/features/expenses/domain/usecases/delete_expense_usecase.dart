import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/expenses/domain/repositories/expense_repository.dart';

class DeleteExpenseUseCase implements UseCase<void, String> {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String expenseId) async {
    return await repository.deleteExpense(expenseId);
  }
}
