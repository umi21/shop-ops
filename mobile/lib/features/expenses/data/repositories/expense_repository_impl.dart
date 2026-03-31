import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:mobile/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:mobile/features/expenses/data/models/mappers/expense_mapper.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';
import 'package:mobile/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Expense>>> getExpenses(String businessId) async {
    try {
      final expenses = await localDataSource.getExpenses(businessId);
      return Right(expenses.map((m) => ExpenseMapper.toEntity(m)).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> addExpense(Expense expense) async {
    try {
      final model = ExpenseMapper.toModel(expense, isSynced: false);
      await localDataSource.saveExpense(model);

      try {
        final expenseData = ExpenseMapper.toJson(model);
        final response = await remoteDataSource.createExpense(expenseData);
        final syncedModel = ExpenseMapper.fromJson(response);
        await localDataSource.saveExpense(syncedModel);
        return Right(ExpenseMapper.toEntity(syncedModel));
      } on NetworkException {
        return Right(expense);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> updateExpense(Expense expense) async {
    try {
      final model = ExpenseMapper.toModel(expense, isSynced: false);
      await localDataSource.saveExpense(model);

      try {
        final expenseData = ExpenseMapper.toJson(model);
        final response = await remoteDataSource.updateExpense(expenseData);
        final syncedModel = ExpenseMapper.fromJson(response);
        await localDataSource.saveExpense(syncedModel);
        return Right(ExpenseMapper.toEntity(syncedModel));
      } on NetworkException {
        return Right(expense);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      await localDataSource.deleteExpense(expenseId);

      try {
        await remoteDataSource.deleteExpense(expenseId);
      } on NetworkException {
        // Already deleted locally
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(
    String businessId,
    DateRange dateRange,
  ) async {
    try {
      final expenses = await localDataSource.getExpensesByDateRange(
        businessId,
        dateRange.from,
        dateRange.to,
      );
      return Right(expenses.map((m) => ExpenseMapper.toEntity(m)).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalExpensesByDateRange(
    String businessId,
    DateRange dateRange,
  ) async {
    final result = await getExpensesByDateRange(businessId, dateRange);
    return result.fold(
      (failure) => Left(failure),
      (expenses) =>
          Right(expenses.fold(0.0, (sum, expense) => sum + expense.amount)),
    );
  }

  @override
  Future<Either<Failure, Map<String, double>>> getExpensesByCategory(
    String businessId,
    DateRange dateRange,
  ) async {
    final result = await getExpensesByDateRange(businessId, dateRange);
    return result.fold((failure) => Left(failure), (expenses) {
      final Map<String, double> categoryTotals = {};
      for (final expense in expenses) {
        final categoryName = expense.category.displayName;
        categoryTotals[categoryName] =
            (categoryTotals[categoryName] ?? 0) + expense.amount;
      }
      return Right(categoryTotals);
    });
  }
}
