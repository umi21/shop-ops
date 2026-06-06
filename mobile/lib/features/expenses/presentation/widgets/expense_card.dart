import 'package:flutter/material.dart';
import 'package:mobile/core/enums/expense_category.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseCard({Key? key, required this.expense, this.onTap})
    : super(key: key);

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

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getColorForCategory(expense.category);
    final icon = _getIconForCategory(expense.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.note ?? expense.category.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expense.category.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-\$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(expense.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
