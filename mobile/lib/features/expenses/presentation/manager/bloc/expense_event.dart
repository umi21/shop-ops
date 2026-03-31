import 'package:equatable/equatable.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';

abstract class ExpenseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadExpensesEvent extends ExpenseEvent {
  final String businessId;
  LoadExpensesEvent(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

class ChangeExpenseTabEvent extends ExpenseEvent {
  final String tab;
  ChangeExpenseTabEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class AddExpenseEvent extends ExpenseEvent {
  final Expense expense;
  AddExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class UpdateExpenseEvent extends ExpenseEvent {
  final Expense expense;
  UpdateExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String expenseId;
  DeleteExpenseEvent(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

class FilterExpensesByDateEvent extends ExpenseEvent {
  final DateRange dateRange;
  FilterExpensesByDateEvent(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}
