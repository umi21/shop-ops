import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';
import 'package:mobile/features/sales/domain/usecases/add_sale_usecase.dart';
import 'package:mobile/features/sales/domain/usecases/get_sales_usecase.dart';
import 'package:mobile/features/sales/domain/usecases/void_sale_usecase.dart';
import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final GetSalesUseCase getSalesUseCase;
  final AddSaleUseCase addSaleUseCase;
  final VoidSaleUseCase voidSaleUseCase;

  List<Sale> _allSales = [];

  SalesBloc({
    required this.getSalesUseCase,
    required this.addSaleUseCase,
    required this.voidSaleUseCase,
  }) : super(SalesInitialState()) {
    on<LoadSalesEvent>(_onLoadSales);
    on<ChangeSalesPeriodEvent>(_onChangePeriod);
    on<AddSaleEvent>(_onAddSale);
    on<VoidSaleEvent>(_onVoidSale);
    on<FilterSalesByDateEvent>(_onFilterByDate);
    on<SearchSalesEvent>(_onSearchSales);
  }

  DateRange _getDateRangeForPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Daily':
        return DateRange.daily(now);
      case 'Weekly':
        return DateRange.weekly(now);
      case 'Monthly':
        return DateRange.monthly(now);
      default:
        return DateRange.daily(now);
    }
  }

  List<Sale> _filterSalesByDate(List<Sale> sales, DateRange dateRange) {
    return sales.where((sale) {
      return sale.createdAt.isAfter(
            dateRange.from.subtract(const Duration(days: 1)),
          ) &&
          sale.createdAt.isBefore(dateRange.to.add(const Duration(days: 1)));
    }).toList();
  }

  Map<String, List<Sale>> _groupSalesByDate(List<Sale> sales) {
    final Map<String, List<Sale>> grouped = {};
    final dateFormat = DateFormat('EEEE, MMM d');

    for (final sale in sales) {
      final dateKey = dateFormat.format(sale.createdAt);
      if (grouped.containsKey(dateKey)) {
        grouped[dateKey]!.add(sale);
      } else {
        grouped[dateKey] = [sale];
      }
    }
    return grouped;
  }

  Future<void> _onLoadSales(
    LoadSalesEvent event,
    Emitter<SalesState> emit,
  ) async {
    emit(SalesLoadingState());

    final result = await getSalesUseCase(event.businessId);

    result.fold((failure) => emit(SalesErrorState(failure.message)), (sales) {
      _allSales = sales;
      final dateRange = _getDateRangeForPeriod('Daily');
      final filtered = _filterSalesByDate(sales, dateRange);
      final grouped = _groupSalesByDate(filtered);
      final total = filtered.fold(0.0, (sum, s) => sum + s.total);
      final avg = filtered.isEmpty ? 0.0 : total / filtered.length;

      emit(
        SalesLoadedState(
          allSales: sales,
          filteredSales: filtered,
          groupedSales: grouped,
          selectedPeriod: 'Daily',
          dateRange: dateRange,
          totalRevenue: total,
          transactionCount: filtered.length,
          averageSale: avg,
        ),
      );
    });
  }

  void _onChangePeriod(ChangeSalesPeriodEvent event, Emitter<SalesState> emit) {
    if (state is SalesLoadedState) {
      final currentState = state as SalesLoadedState;
      final dateRange = _getDateRangeForPeriod(event.period);
      final filtered = _filterSalesByDate(_allSales, dateRange);
      final grouped = _groupSalesByDate(filtered);
      final total = filtered.fold(0.0, (sum, s) => sum + s.total);
      final avg = filtered.isEmpty ? 0.0 : total / filtered.length;

      emit(
        currentState.copyWith(
          selectedPeriod: event.period,
          dateRange: dateRange,
          filteredSales: filtered,
          groupedSales: grouped,
          totalRevenue: total,
          transactionCount: filtered.length,
          averageSale: avg,
        ),
      );
    }
  }

  Future<void> _onAddSale(AddSaleEvent event, Emitter<SalesState> emit) async {
    if (state is SalesLoadedState) {
      final currentState = state as SalesLoadedState;

      final result = await addSaleUseCase(AddSaleParams(sale: event.sale));

      result.fold(
        (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
        (sale) {
          _allSales = [..._allSales, sale];
          final filtered = _filterSalesByDate(
            _allSales,
            currentState.dateRange,
          );
          final grouped = _groupSalesByDate(filtered);
          final total = filtered.fold(0.0, (sum, s) => sum + s.total);
          final avg = filtered.isEmpty ? 0.0 : total / filtered.length;

          emit(
            currentState.copyWith(
              allSales: _allSales,
              filteredSales: filtered,
              groupedSales: grouped,
              totalRevenue: total,
              transactionCount: filtered.length,
              averageSale: avg,
            ),
          );
        },
      );
    }
  }

  Future<void> _onVoidSale(
    VoidSaleEvent event,
    Emitter<SalesState> emit,
  ) async {
    if (state is SalesLoadedState) {
      final currentState = state as SalesLoadedState;

      final result = await voidSaleUseCase(event.saleId);

      result.fold(
        (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
        (_) {
          _allSales = _allSales.map((s) {
            if (s.id == event.saleId) {
              return s.copyWith(isVoided: true);
            }
            return s;
          }).toList();

          final filtered = _filterSalesByDate(
            _allSales,
            currentState.dateRange,
          );
          final grouped = _groupSalesByDate(filtered);
          final total = filtered.fold(0.0, (sum, s) => sum + s.total);
          final avg = filtered.isEmpty ? 0.0 : total / filtered.length;

          emit(
            currentState.copyWith(
              allSales: _allSales,
              filteredSales: filtered,
              groupedSales: grouped,
              totalRevenue: total,
              transactionCount: filtered.length,
              averageSale: avg,
            ),
          );
        },
      );
    }
  }

  void _onSearchSales(SearchSalesEvent event, Emitter<SalesState> emit) {
    if (state is SalesLoadedState) {
      final currentState = state as SalesLoadedState;

      List<Sale> filtered;
      if (event.query.isEmpty) {
        filtered = _filterSalesByDate(_allSales, currentState.dateRange);
      } else {
        filtered = _allSales.where((s) {
          final query = event.query.toLowerCase();
          return s.productId.toLowerCase().contains(query);
        }).toList();
        filtered = _filterSalesByDate(filtered, currentState.dateRange);
      }

      final grouped = _groupSalesByDate(filtered);

      emit(
        currentState.copyWith(
          searchQuery: event.query,
          filteredSales: filtered,
          groupedSales: grouped,
        ),
      );
    }
  }

  void _onFilterByDate(FilterSalesByDateEvent event, Emitter<SalesState> emit) {
    if (state is SalesLoadedState) {
      final currentState = state as SalesLoadedState;
      final filtered = _filterSalesByDate(_allSales, event.dateRange);
      final grouped = _groupSalesByDate(filtered);
      final total = filtered.fold(0.0, (sum, s) => sum + s.total);
      final avg = filtered.isEmpty ? 0.0 : total / filtered.length;

      String period = 'Daily';
      final days = event.dateRange.to.difference(event.dateRange.from).inDays;
      if (days > 7) {
        period = 'Monthly';
      } else if (days > 1) {
        period = 'Weekly';
      }

      emit(
        currentState.copyWith(
          selectedPeriod: period,
          dateRange: event.dateRange,
          filteredSales: filtered,
          groupedSales: grouped,
          totalRevenue: total,
          transactionCount: filtered.length,
          averageSale: avg,
        ),
      );
    }
  }
}
