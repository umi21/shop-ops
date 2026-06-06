import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';
import 'package:mobile/features/expenses/domain/repositories/expense_repository.dart';

class UpdateExpenseUseCase implements UseCase<Expense, UpdateExpenseParams> {
  final ExpenseRepository repository;

  UpdateExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, Expense>> call(UpdateExpenseParams params) async {
    return await repository.updateExpense(params.expense);
  }
}

class UpdateExpenseParams extends Equatable {
  final Expense expense;

  const UpdateExpenseParams({required this.expense});

  @override
  List<Object?> get props => [expense];
}
