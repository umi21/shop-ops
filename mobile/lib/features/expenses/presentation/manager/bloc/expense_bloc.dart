import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';
import 'package:mobile/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:mobile/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:mobile/features/expenses/domain/usecases/get_expense_report_usecase.dart';
import 'package:mobile/features/expenses/domain/usecases/get_expenses_usecase.dart';
import 'package:mobile/features/expenses/domain/usecases/update_expense_usecase.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpensesUseCase getExpensesUseCase;
  final GetExpenseReportUseCase getExpenseReportUseCase;
  final AddExpenseUseCase addExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  List<Expense> _allExpenses = [];

  ExpenseBloc({
    required this.getExpensesUseCase,
    required this.getExpenseReportUseCase,
    required this.addExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
  }) : super(ExpenseInitialState()) {
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<ChangeExpenseTabEvent>(_onChangeTab);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<FilterExpensesByDateEvent>(_onFilterByDate);
  }

  DateRange _getDateRangeForTab(String tab) {
    final now = DateTime.now();
    switch (tab) {
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

  List<Expense> _filterExpensesByDate(
    List<Expense> expenses,
    DateRange dateRange,
  ) {
    return expenses.where((expense) {
      return expense.createdAt.isAfter(dateRange.from) &&
          expense.createdAt.isBefore(dateRange.to.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> _onLoadExpenses(
    LoadExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoadingState());

    final result = await getExpensesUseCase(event.businessId);

    result.fold((failure) => emit(ExpenseErrorState(failure.message)), (
      expenses,
    ) {
      _allExpenses = expenses;
      final dateRange = _getDateRangeForTab('Daily');
      final filtered = _filterExpensesByDate(expenses, dateRange);
      final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

      emit(
        ExpenseLoadedState(
          expenses: expenses,
          filteredExpenses: filtered,
          selectedTab: 'Daily',
          dateRange: dateRange,
          totalSpent: total,
        ),
      );
    });
  }

  void _onChangeTab(ChangeExpenseTabEvent event, Emitter<ExpenseState> emit) {
    if (state is ExpenseLoadedState) {
      final currentState = state as ExpenseLoadedState;
      final dateRange = _getDateRangeForTab(event.tab);
      final filtered = _filterExpensesByDate(_allExpenses, dateRange);
      final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

      emit(
        currentState.copyWith(
          selectedTab: event.tab,
          dateRange: dateRange,
          filteredExpenses: filtered,
          totalSpent: total,
        ),
      );
    }
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state is ExpenseLoadedState) {
      final currentState = state as ExpenseLoadedState;

      final result = await addExpenseUseCase(
        AddExpenseParams(expense: event.expense),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
        (expense) {
          _allExpenses = [..._allExpenses, expense];
          final filtered = _filterExpensesByDate(
            _allExpenses,
            currentState.dateRange,
          );
          final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

          emit(
            currentState.copyWith(
              expenses: _allExpenses,
              filteredExpenses: filtered,
              totalSpent: total,
            ),
          );
        },
      );
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state is ExpenseLoadedState) {
      final currentState = state as ExpenseLoadedState;

      final result = await updateExpenseUseCase(
        UpdateExpenseParams(expense: event.expense),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
        (expense) {
          _allExpenses = _allExpenses.map((e) {
            return e.id == expense.id ? expense : e;
          }).toList();

          final filtered = _filterExpensesByDate(
            _allExpenses,
            currentState.dateRange,
          );
          final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

          emit(
            currentState.copyWith(
              expenses: _allExpenses,
              filteredExpenses: filtered,
              totalSpent: total,
            ),
          );
        },
      );
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state is ExpenseLoadedState) {
      final currentState = state as ExpenseLoadedState;

      final result = await deleteExpenseUseCase(event.expenseId);

      result.fold(
        (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
        (_) {
          _allExpenses = _allExpenses
              .where((e) => e.id != event.expenseId)
              .toList();

          final filtered = _filterExpensesByDate(
            _allExpenses,
            currentState.dateRange,
          );
          final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

          emit(
            currentState.copyWith(
              expenses: _allExpenses,
              filteredExpenses: filtered,
              totalSpent: total,
            ),
          );
        },
      );
    }
  }

  void _onFilterByDate(
    FilterExpensesByDateEvent event,
    Emitter<ExpenseState> emit,
  ) {
    if (state is ExpenseLoadedState) {
      final currentState = state as ExpenseLoadedState;
      final filtered = _filterExpensesByDate(_allExpenses, event.dateRange);
      final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

      String tab = 'Daily';
      if (event.dateRange.to.difference(event.dateRange.from).inDays == 1) {
        tab = 'Daily';
      } else if (event.dateRange.to.difference(event.dateRange.from).inDays <=
          7) {
        tab = 'Weekly';
      } else {
        tab = 'Monthly';
      }

      emit(
        currentState.copyWith(
          selectedTab: tab,
          dateRange: event.dateRange,
          filteredExpenses: filtered,
          totalSpent: total,
        ),
      );
    }
  }
}
