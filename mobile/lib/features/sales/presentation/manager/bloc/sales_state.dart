import 'package:equatable/equatable.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';

abstract class SalesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesInitialState extends SalesState {}

class SalesLoadingState extends SalesState {}

class SalesLoadedState extends SalesState {
  final List<Sale> allSales;
  final List<Sale> filteredSales;
  final Map<String, List<Sale>> groupedSales;
  final String selectedPeriod;
  final DateRange dateRange;
  final double totalRevenue;
  final int transactionCount;
  final double averageSale;
  final String searchQuery;
  final String? errorMessage;

  SalesLoadedState({
    required this.allSales,
    required this.filteredSales,
    required this.groupedSales,
    required this.selectedPeriod,
    required this.dateRange,
    required this.totalRevenue,
    required this.transactionCount,
    required this.averageSale,
    this.searchQuery = '',
    this.errorMessage,
  });

  SalesLoadedState copyWith({
    List<Sale>? allSales,
    List<Sale>? filteredSales,
    Map<String, List<Sale>>? groupedSales,
    String? selectedPeriod,
    DateRange? dateRange,
    double? totalRevenue,
    int? transactionCount,
    double? averageSale,
    String? searchQuery,
    String? errorMessage,
  }) {
    return SalesLoadedState(
      allSales: allSales ?? this.allSales,
      filteredSales: filteredSales ?? this.filteredSales,
      groupedSales: groupedSales ?? this.groupedSales,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      dateRange: dateRange ?? this.dateRange,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      transactionCount: transactionCount ?? this.transactionCount,
      averageSale: averageSale ?? this.averageSale,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    allSales,
    filteredSales,
    groupedSales,
    selectedPeriod,
    dateRange,
    totalRevenue,
    transactionCount,
    averageSale,
    searchQuery,
    errorMessage,
  ];
}

class SalesErrorState extends SalesState {
  final String message;

  SalesErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
