import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/core/value_objects/profit_summary.dart';
import 'package:mobile/features/expenses/domain/usecases/get_expense_report_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/get_low_stock_alerts_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/get_out_of_stock_alerts_usecase.dart';
import 'package:mobile/features/sales/domain/usecases/calculate_profit_usecase.dart';
import 'package:mobile/features/sales/domain/usecases/get_sales_report_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final CalculateProfitUseCase calculateProfitUseCase;
  final GetSalesReportUseCase getSalesReportUseCase;
  final GetExpenseReportUseCase getExpenseReportUseCase;
  final GetLowStockAlertsUseCase getLowStockAlertsUseCase;
  final GetOutOfStockAlertsUseCase getOutOfStockAlertsUseCase;

  DashboardBloc({
    required this.calculateProfitUseCase,
    required this.getSalesReportUseCase,
    required this.getExpenseReportUseCase,
    required this.getLowStockAlertsUseCase,
    required this.getOutOfStockAlertsUseCase,
  }) : super(DashboardInitialState()) {
    on<LoadDashboardDataEvent>(_onLoadDashboardData);
    on<ChangeDashboardPeriodEvent>(_onChangePeriod);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
  }

  DateRange _getDateRangeForPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Weekly':
        return DateRange.weekly(now);
      case 'Monthly':
        return DateRange.monthly(now);
      case 'Daily':
      default:
        return DateRange.daily(now);
    }
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoadingState());

    try {
      await _loadData(event.businessId, 'Weekly', emit);
    } catch (e) {
      emit(DashboardErrorState(e.toString()));
    }
  }

  Future<void> _onChangePeriod(
    ChangeDashboardPeriodEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoadedState) {
      final currentState = state as DashboardLoadedState;
      emit(DashboardLoadingState());

      try {
        await _loadData(
          currentState.profitSummary.totalSales > 0
              ? 'default_business_id'
              : 'default_business_id',
          event.period,
          emit,
        );
      } catch (e) {
        emit(DashboardErrorState(e.toString()));
      }
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final currentPeriod = state is DashboardLoadedState
        ? (state as DashboardLoadedState).selectedPeriod
        : 'Weekly';

    try {
      await _loadData(event.businessId, currentPeriod, emit);
    } catch (e) {
      emit(DashboardErrorState(e.toString()));
    }
  }

  Future<void> _loadData(
    String businessId,
    String period,
    Emitter<DashboardState> emit,
  ) async {
    final dateRange = _getDateRangeForPeriod(period);

    final profitResult = await calculateProfitUseCase(
      ProfitParams(businessId: businessId, dateRange: dateRange),
    );

    final salesResult = await getSalesReportUseCase(
      SalesReportParams(businessId: businessId, dateRange: dateRange),
    );

    final expensesResult = await getExpenseReportUseCase(
      ExpenseReportParams(businessId: businessId, dateRange: dateRange),
    );

    final lowStockResult = await getLowStockAlertsUseCase(businessId);
    final outOfStockResult = await getOutOfStockAlertsUseCase(businessId);

    ProfitSummary profitSummary = ProfitSummary.empty();
    List<dynamic> recentSales = [];
    List<dynamic> recentExpenses = [];
    List<dynamic> lowStockProducts = [];
    List<dynamic> outOfStockProducts = [];

    profitResult.fold((failure) {}, (summary) => profitSummary = summary);

    salesResult.fold((failure) {}, (sales) => recentSales = sales);

    expensesResult.fold((failure) {}, (expenses) => recentExpenses = expenses);

    lowStockResult.fold(
      (failure) {},
      (products) => lowStockProducts = products,
    );

    outOfStockResult.fold(
      (failure) {},
      (products) => outOfStockProducts = products,
    );

    final activity = _buildActivityList(recentSales, recentExpenses);

    double salesChange = 0;
    double expensesChange = 0;

    emit(
      DashboardLoadedState(
        profitSummary: profitSummary,
        dateRange: dateRange,
        selectedPeriod: period,
        recentSales: recentSales.cast(),
        recentExpenses: recentExpenses.cast(),
        lowStockProducts: lowStockProducts.cast(),
        outOfStockProducts: outOfStockProducts.cast(),
        recentActivity: activity,
        salesChange: salesChange,
        expensesChange: expensesChange,
      ),
    );
  }

  List<ActivityItem> _buildActivityList(
    List<dynamic> sales,
    List<dynamic> expenses,
  ) {
    final List<ActivityItem> activity = [];

    for (final sale in sales.take(3)) {
      activity.add(
        ActivityItem(
          type: ActivityType.sale,
          title: 'Sale: ${sale.productName}',
          subtitle: 'Today',
          amount: sale.total,
          timestamp: sale.createdAt,
          isPositive: true,
        ),
      );
    }

    for (final expense in expenses.take(3)) {
      activity.add(
        ActivityItem(
          type: ActivityType.expense,
          title: 'Expense: ${expense.category?.displayName ?? "Other"}',
          subtitle: 'Today',
          amount: expense.amount,
          timestamp: expense.createdAt,
          isPositive: false,
        ),
      );
    }

    activity.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activity.take(5).toList();
  }
}
