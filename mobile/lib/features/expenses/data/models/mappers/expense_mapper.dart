import 'package:mobile/core/enums/expense_category.dart';
import 'package:mobile/features/expenses/data/models/expense_model.dart';
import 'package:mobile/features/expenses/domain/entities/expense.dart';

class ExpenseMapper {
  static Expense toEntity(ExpenseModel model) {
    return Expense(
      id: model.id,
      businessId: model.businessId,
      category: model.category,
      amount: model.amount,
      note: model.note,
      createdAt: model.createdAt,
      isVoided: model.isVoided,
    );
  }

  static ExpenseModel toModel(
    Expense entity, {
    DateTime? syncedAt,
    bool isSynced = false,
  }) {
    return ExpenseModel()
      ..id = entity.id
      ..businessId = entity.businessId
      ..category = entity.category
      ..amount = entity.amount
      ..note = entity.note
      ..createdAt = entity.createdAt
      ..isVoided = entity.isVoided
      ..syncedAt = syncedAt ?? DateTime.now()
      ..isSynced = isSynced;
  }

  static Map<String, dynamic> toJson(ExpenseModel model) {
    return {
      'id': model.id,
      'businessId': model.businessId,
      'category': model.category.name,
      'amount': model.amount,
      'note': model.note,
      'createdAt': model.createdAt.toIso8601String(),
      'isVoided': model.isVoided,
    };
  }

  static ExpenseModel fromJson(Map<String, dynamic> json) {
    return ExpenseModel()
      ..id = json['id']
      ..businessId = json['businessId']
      ..category = ExpenseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExpenseCategory.other,
      )
      ..amount = (json['amount'] as num).toDouble()
      ..note = json['note']
      ..createdAt = DateTime.parse(json['createdAt'])
      ..isVoided = json['isVoided'] ?? false
      ..syncedAt = DateTime.now()
      ..isSynced = true;
  }
}
