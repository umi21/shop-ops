import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile/core/enums/expense_category.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';
import 'package:mobile/features/expenses/presentation/manager/bloc/expense_bloc.dart';
import 'package:mobile/features/expenses/presentation/manager/bloc/expense_event.dart';

class QuickAddExpenseModal extends StatefulWidget {
  const QuickAddExpenseModal({Key? key}) : super(key: key);

  @override
  State<QuickAddExpenseModal> createState() => _QuickAddExpenseModalState();
}

class _QuickAddExpenseModalState extends State<QuickAddExpenseModal> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.transport;

  IconData _getIconForCategory(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.rent:
        return Icons.storefront_outlined;
      case ExpenseCategory.utilities:
        return Icons.bolt;
      case ExpenseCategory.stockPurchase:
        return Icons.inventory_2_outlined;
      case ExpenseCategory.transport:
        return Icons.local_shipping;
      case ExpenseCategory.maintenance:
        return Icons.build_outlined;
      case ExpenseCategory.other:
        return Icons.receipt_long_outlined;
    }
  }

  Color _getColorForCategory(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.rent:
        return const Color(0xFFF97316);
      case ExpenseCategory.utilities:
        return const Color(0xFFA855F7);
      case ExpenseCategory.stockPurchase:
        return const Color(0xFF16A34A);
      case ExpenseCategory.transport:
        return const Color(0xFF1E5EFE);
      case ExpenseCategory.maintenance:
        return const Color(0xFF64748B);
      case ExpenseCategory.other:
        return const Color(0xFF64748B);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 24,
        right: 24,
        bottom: bottomPadding + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Expense',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Center(
            child: Column(
              children: [
                const Text(
                  'AMOUNT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '\$',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E5EFE),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(color: Color(0xFFE2E8F0)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Select Category',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ExpenseCategory.values.take(4).map((cat) {
              final isSelected = _selectedCategory == cat;
              final color = _getColorForCategory(cat);
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isSelected ? color : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? null
                            : Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Icon(
                        _getIconForCategory(cat),
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF64748B),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                icon: Icon(
                  Icons.receipt_long_outlined,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                hintText: 'Add a note (optional)...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  final expense = Expense(
                    id: const Uuid().v4(),
                    businessId: 'default_business_id',
                    category: _selectedCategory,
                    amount: amount,
                    note: _noteController.text.isNotEmpty
                        ? _noteController.text
                        : null,
                    createdAt: DateTime.now(),
                  );

                  context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
                  Navigator.pop(context);
                }
              },
              icon: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Save Expense',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E5EFE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
