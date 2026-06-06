import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getExpenses(String businessId);
  Future<Either<Failure, Expense>> addExpense(Expense expense);
  Future<Either<Failure, Expense>> updateExpense(Expense expense);
  Future<Either<Failure, void>> deleteExpense(String expenseId);
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(
    String businessId,
    DateRange dateRange,
  );
  Future<Either<Failure, double>> getTotalExpensesByDateRange(
    String businessId,
    DateRange dateRange,
  );
  Future<Either<Failure, Map<String, double>>> getExpensesByCategory(
    String businessId,
    DateRange dateRange,
  );
}
