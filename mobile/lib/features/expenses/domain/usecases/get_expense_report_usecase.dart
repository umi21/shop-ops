import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';
import 'package:mobile/features/expenses/domain/repositories/expense_repository.dart';

class GetExpenseReportUseCase
    implements UseCase<List<Expense>, ExpenseReportParams> {
  final ExpenseRepository repository;

  GetExpenseReportUseCase(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(
    ExpenseReportParams params,
  ) async {
    return await repository.getExpensesByDateRange(
      params.businessId,
      params.dateRange,
    );
  }
}

class ExpenseReportParams extends Equatable {
  final String businessId;
  final DateRange dateRange;

  const ExpenseReportParams({
    required this.businessId,
    required this.dateRange,
  });

  @override
  List<Object?> get props => [businessId, dateRange];
}
