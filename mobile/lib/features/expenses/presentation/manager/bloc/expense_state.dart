import 'package:equatable/equatable.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';

abstract class ExpenseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExpenseInitialState extends ExpenseState {}

class ExpenseLoadingState extends ExpenseState {}

class ExpenseLoadedState extends ExpenseState {
  final List<Expense> expenses;
  final List<Expense> filteredExpenses;
  final String selectedTab;
  final DateRange dateRange;
  final double totalSpent;
  final String? errorMessage;

  ExpenseLoadedState({
    required this.expenses,
    required this.filteredExpenses,
    required this.selectedTab,
    required this.dateRange,
    required this.totalSpent,
    this.errorMessage,
  });

  ExpenseLoadedState copyWith({
    List<Expense>? expenses,
    List<Expense>? filteredExpenses,
    String? selectedTab,
    DateRange? dateRange,
    double? totalSpent,
    String? errorMessage,
  }) {
    return ExpenseLoadedState(
      expenses: expenses ?? this.expenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      selectedTab: selectedTab ?? this.selectedTab,
      dateRange: dateRange ?? this.dateRange,
      totalSpent: totalSpent ?? this.totalSpent,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    expenses,
    filteredExpenses,
    selectedTab,
    dateRange,
    totalSpent,
    errorMessage,
  ];
}

class ExpenseErrorState extends ExpenseState {
  final String message;

  ExpenseErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
