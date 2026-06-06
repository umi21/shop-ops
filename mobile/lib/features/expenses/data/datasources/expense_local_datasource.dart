import 'package:isar/isar.dart';
import 'package:mobile/features/expenses/data/models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses(String businessId);
  Future<ExpenseModel?> getExpense(String expenseId);
  Future<void> saveExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String businessId,
    DateTime from,
    DateTime to,
  );
  Future<List<ExpenseModel>> getUnsyncedExpenses();
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final Isar isar;

  ExpenseLocalDataSourceImpl(this.isar);

  @override
  Future<List<ExpenseModel>> getExpenses(String businessId) async {
    return await isar.expenseModels
        .filter()
        .businessIdEqualTo(businessId)
        .isVoidedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<ExpenseModel?> getExpense(String expenseId) async {
    return await isar.expenseModels.filter().idEqualTo(expenseId).findFirst();
  }

  @override
  Future<void> saveExpense(ExpenseModel expense) async {
    await isar.writeTxn(() async {
      await isar.expenseModels.put(expense);
    });
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await isar.writeTxn(() async {
      final expense = await isar.expenseModels
          .filter()
          .idEqualTo(expenseId)
          .findFirst();
      if (expense != null) {
        await isar.expenseModels.delete(expense.isarId);
      }
    });
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String businessId,
    DateTime from,
    DateTime to,
  ) async {
    return await isar.expenseModels
        .filter()
        .businessIdEqualTo(businessId)
        .createdAtBetween(from, to)
        .isVoidedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<List<ExpenseModel>> getUnsyncedExpenses() async {
    return await isar.expenseModels.filter().isSyncedEqualTo(false).findAll();
  }
}
