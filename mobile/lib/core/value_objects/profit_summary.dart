import 'package:equatable/equatable.dart';

class ProfitSummary extends Equatable {
  final double totalSales;
  final double totalExpenses;
  final double profit;
  final DateTime startDate;
  final DateTime endDate;

  const ProfitSummary({
    required this.totalSales,
    required this.totalExpenses,
    required this.profit,
    required this.startDate,
    required this.endDate,
  });

  bool get isProfit => profit > 0;

  factory ProfitSummary.empty() {
    final now = DateTime.now();
    return ProfitSummary(
      totalSales: 0,
      totalExpenses: 0,
      profit: 0,
      startDate: now,
      endDate: now,
    );
  }

  @override
  List<Object?> get props => [
    totalSales,
    totalExpenses,
    profit,
    startDate,
    endDate,
  ];
}
