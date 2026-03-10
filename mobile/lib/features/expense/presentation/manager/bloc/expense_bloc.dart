import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseEntity {
  final String title;
  final String category;
  final String description;
  final double amount;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  ExpenseEntity({
    required this.title,
    required this.category,
    required this.description,
    required this.amount,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final List<ExpenseEntity> _mockExpenses = [
    ExpenseEntity(
      title: 'Store Rent',
      category: 'Rent',
      description: 'Monthly Payment',
      amount: 850.00,
      time: '10:30 AM',
      icon: Icons.store_outlined,
      iconColor: const Color(0xFF1E5EFE),
      iconBgColor: const Color(0xFFEFF6FF),
    ),
    ExpenseEntity(
      title: 'Shell Station',
      category: 'Transport',
      description: 'Delivery Van',
      amount: 45.20,
      time: '12:40 PM',
      icon: Icons.local_gas_station_outlined,
      iconColor: const Color(0xFFF97316),
      iconBgColor: const Color(0xFFFFF7ED),
    ),
    ExpenseEntity(
      title: 'Electricity Bill',
      category: 'Utilities',
      description: 'Commercial Rate',
      amount: 312.30,
      time: '2:10 PM',
      icon: Icons.bolt_outlined,
      iconColor: const Color(0xFFA855F7),
      iconBgColor: const Color(0xFFFAF5FF),
    ),
    ExpenseEntity(
      title: 'Wholesale Restock',
      category: 'Inventory',
      description: 'New Arrivals',
      amount: 33.00,
      time: '4:00 PM',
      icon: Icons.inventory_2_outlined,
      iconColor: const Color(0xFF16A34A),
      iconBgColor: const Color(0xFFF0FDF4),
    ),
  ];

  ExpenseBloc() : super(ExpenseLoadingState()) {
    on<LoadExpensesEvent>((event, emit) {
      emit(
        ExpenseLoadedState(
          selectedTab: 'Daily',
          totalSpent: 1240.50,
          expenses: _mockExpenses,
        ),
      );
    });

    on<ChangeExpenseTabEvent>((event, emit) {
      if (state is ExpenseLoadedState) {
        final currentState = state as ExpenseLoadedState;
        emit(currentState.copyWith(selectedTab: event.tab));
      }
    });

    on<AddNewExpenseEvent>((event, emit) {
      if (state is ExpenseLoadedState) {
        final currentState = state as ExpenseLoadedState;

        final updatedExpenses = List<ExpenseEntity>.from(currentState.expenses)
          ..insert(0, event.newExpense);

        final newTotal = currentState.totalSpent + event.newExpense.amount;

        emit(
          currentState.copyWith(
            expenses: updatedExpenses,
            totalSpent: newTotal,
          ),
        );
      }
    });
  }
}
