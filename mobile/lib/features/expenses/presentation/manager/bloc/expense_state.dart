import 'package:equatable/equatable.dart';
import 'expense_bloc.dart'; // Pour importer ExpenseEntity

abstract class ExpenseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExpenseLoadingState extends ExpenseState {}

class ExpenseLoadedState extends ExpenseState {
  final String selectedTab;
  final double totalSpent;
  final List<ExpenseEntity> expenses;

  ExpenseLoadedState({
    required this.selectedTab,
    required this.totalSpent,
    required this.expenses,
  });

  ExpenseLoadedState copyWith({
    String? selectedTab,
    double? totalSpent,
    List<ExpenseEntity>? expenses,
  }) {
    return ExpenseLoadedState(
      selectedTab: selectedTab ?? this.selectedTab,
      totalSpent: totalSpent ?? this.totalSpent,
      expenses: expenses ?? this.expenses,
    );
  }

  @override
  List<Object?> get props => [selectedTab, totalSpent, expenses];
}