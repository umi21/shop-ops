import 'package:equatable/equatable.dart';
import 'expense_bloc.dart'; // Pour importer ExpenseEntity

abstract class ExpenseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadExpensesEvent extends ExpenseEvent {}

class ChangeExpenseTabEvent extends ExpenseEvent {
  final String tab; 
  ChangeExpenseTabEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}

class AddNewExpenseEvent extends ExpenseEvent {
  final ExpenseEntity newExpense;
  AddNewExpenseEvent(this.newExpense);
  @override
  List<Object?> get props => [newExpense];
}