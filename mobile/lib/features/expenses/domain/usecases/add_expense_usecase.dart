import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';
import 'package:mobile/features/expenses/domain/repositories/expense_repository.dart';

class AddExpenseUseCase implements UseCase<Expense, AddExpenseParams> {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, Expense>> call(AddExpenseParams params) async {
    return await repository.addExpense(params.expense);
  }
}

class AddExpenseParams extends Equatable {
  final Expense expense;

  const AddExpenseParams({required this.expense});

  @override
  List<Object?> get props => [expense];
}
