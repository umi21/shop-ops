import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';
import 'package:mobile/features/expenses/domain/repositories/expense_repository.dart';

class GetExpensesUseCase implements UseCase<List<Expense>, String> {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(String businessId) async {
    return await repository.getExpenses(businessId);
  }
}
