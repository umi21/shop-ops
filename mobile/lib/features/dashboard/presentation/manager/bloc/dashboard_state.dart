import 'package:equatable/equatable.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/core/value_objects/profit_summary.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitialState extends DashboardState {}

class DashboardLoadingState extends DashboardState {}

class DashboardLoadedState extends DashboardState {
  final ProfitSummary profitSummary;
  final DateRange dateRange;
  final String selectedPeriod;
  final List<Sale> recentSales;
  final List<Expense> recentExpenses;
  final List<Product> lowStockProducts;
  final List<Product> outOfStockProducts;
  final List<ActivityItem> recentActivity;
  final double salesChange;
  final double expensesChange;
  final String? errorMessage;

  DashboardLoadedState({
    required this.profitSummary,
    required this.dateRange,
    required this.selectedPeriod,
    required this.recentSales,
    required this.recentExpenses,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.recentActivity,
    this.salesChange = 0,
    this.expensesChange = 0,
    this.errorMessage,
  });

  DashboardLoadedState copyWith({
    ProfitSummary? profitSummary,
    DateRange? dateRange,
    String? selectedPeriod,
    List<Sale>? recentSales,
    List<Expense>? recentExpenses,
    List<Product>? lowStockProducts,
    List<Product>? outOfStockProducts,
    List<ActivityItem>? recentActivity,
    double? salesChange,
    double? expensesChange,
    String? errorMessage,
  }) {
    return DashboardLoadedState(
      profitSummary: profitSummary ?? this.profitSummary,
      dateRange: dateRange ?? this.dateRange,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      recentSales: recentSales ?? this.recentSales,
      recentExpenses: recentExpenses ?? this.recentExpenses,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      outOfStockProducts: outOfStockProducts ?? this.outOfStockProducts,
      recentActivity: recentActivity ?? this.recentActivity,
      salesChange: salesChange ?? this.salesChange,
      expensesChange: expensesChange ?? this.expensesChange,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    profitSummary,
    dateRange,
    selectedPeriod,
    recentSales,
    recentExpenses,
    lowStockProducts,
    outOfStockProducts,
    recentActivity,
    salesChange,
    expensesChange,
    errorMessage,
  ];
}

class DashboardErrorState extends DashboardState {
  final String message;

  DashboardErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

enum ActivityType { sale, expense, inventory }

class ActivityItem extends Equatable {
  final ActivityType type;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime timestamp;
  final bool isPositive;

  const ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.timestamp,
    required this.isPositive,
  });

  @override
  List<Object?> get props => [
    type,
    title,
    subtitle,
    amount,
    timestamp,
    isPositive,
  ];
}
