import 'package:equatable/equatable.dart';
import 'package:mobile/core/enums/expense_category.dart';

class Expense extends Equatable {
  final String id;
  final String businessId;
  final ExpenseCategory category;
  final double amount;
  final String? note;
  final DateTime createdAt;
  final bool isVoided;

  const Expense({
    required this.id,
    required this.businessId,
    required this.category,
    required this.amount,
    this.note,
    required this.createdAt,
    this.isVoided = false,
  });

  Expense copyWith({
    String? id,
    String? businessId,
    ExpenseCategory? category,
    double? amount,
    String? note,
    DateTime? createdAt,
    bool? isVoided,
  }) {
    return Expense(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      isVoided: isVoided ?? this.isVoided,
    );
  }

  @override
  List<Object?> get props => [
    id,
    businessId,
    category,
    amount,
    note,
    createdAt,
    isVoided,
  ];
}
