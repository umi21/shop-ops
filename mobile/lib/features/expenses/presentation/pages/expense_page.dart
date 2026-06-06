import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import 'package:mobile/injection_container.dart' as di;
import '../../../../core/widgets/expandable_fab.dart';
import '../manager/bloc/expense_bloc.dart';
import '../manager/bloc/expense_event.dart';
import '../manager/bloc/expense_state.dart';
import '../widgets/expense_card.dart';
import '../widgets/quick_add_expense_modal.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({Key? key}) : super(key: key);

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  bool _avatarPressed = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseBloc(
        getExpensesUseCase: di.sl(),
        getExpenseReportUseCase: di.sl(),
        addExpenseUseCase: di.sl(),
        updateExpenseUseCase: di.sl(),
        deleteExpenseUseCase: di.sl(),
      )..add(LoadExpensesEvent('default_business_id')),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Expenses',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (_) =>
                              setState(() => _avatarPressed = true),
                          onTapUp: (_) {
                            setState(() => _avatarPressed = false);
                            Navigator.pushNamed(
                              context,
                              AppRoutes.profileRoute,
                            );
                          },
                          onTapCancel: () =>
                              setState(() => _avatarPressed = false),
                          child: AnimatedScale(
                            scale: _avatarPressed ? 0.88 : 1.0,
                            duration: const Duration(milliseconds: 100),
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFFE2E8F0),
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: BlocBuilder<ExpenseBloc, ExpenseState>(
                      builder: (context, state) {
                        if (state is ExpenseLoadingState ||
                            state is ExpenseInitialState) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is ExpenseLoadedState) {
                          return ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    _buildTab(
                                      context,
                                      'Daily',
                                      state.selectedTab,
                                    ),
                                    _buildTab(
                                      context,
                                      'Weekly',
                                      state.selectedTab,
                                    ),
                                    _buildTab(
                                      context,
                                      'Monthly',
                                      state.selectedTab,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E5EFE),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF1E5EFE,
                                      ).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total spent ${state.selectedTab.toLowerCase()}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '\$${state.totalSpent.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.trending_up,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '12% vs last period',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Recent Costs',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'View All',
                                      style: TextStyle(
                                        color: Color(0xFF1E5EFE),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              if (state.filteredExpenses.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.receipt_long_outlined,
                                          color: Color(0xFF94A3B8),
                                          size: 48,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'No expenses for this period',
                                          style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...state.filteredExpenses
                                    .map(
                                      (expense) =>
                                          ExpenseCard(expense: expense),
                                    )
                                    .toList(),

                              const SizedBox(height: 100),
                            ],
                          );
                        }

                        if (state is ExpenseErrorState) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: ${state.message}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),

            floatingActionButton: Padding(
              padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
              child: ExpandableFab(
                icon: const Icon(Icons.add, color: Colors.white),
                label: 'Add Expense',
                backgroundColor: const Color(0xFF1E5EFE),
                onTap: () {
                  final bloc = context.read<ExpenseBloc>();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (bottomSheetContext) {
                      return BlocProvider.value(
                        value: bloc,
                        child: const QuickAddExpenseModal(),
                      );
                    },
                  );
                },
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, String selectedTab) {
    final isSelected = title == selectedTab;
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            context.read<ExpenseBloc>().add(ChangeExpenseTabEvent(title)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF1E5EFE)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
