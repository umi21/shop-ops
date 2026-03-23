import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/resources/api_constants.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<Map<String, dynamic>>> getExpenses(String businessId);
  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> expenseData);
  Future<Map<String, dynamic>> updateExpense(Map<String, dynamic> expenseData);
  Future<void> deleteExpense(String expenseId);
  Future<List<Map<String, dynamic>>> syncExpenses(
    List<Map<String, dynamic>> expenses,
  );
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final ApiClient apiClient;

  ExpenseRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<Map<String, dynamic>>> getExpenses(String businessId) async {
    final response = await apiClient.get(
      '${ApiConstants.expensesEndpoint}/$businessId',
    );
    return List<Map<String, dynamic>>.from(response.data['expenses']);
  }

  @override
  Future<Map<String, dynamic>> createExpense(
    Map<String, dynamic> expenseData,
  ) async {
    final response = await apiClient.post(
      ApiConstants.expensesEndpoint,
      data: expenseData,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateExpense(
    Map<String, dynamic> expenseData,
  ) async {
    final expenseId = expenseData['id'];
    final response = await apiClient.put(
      '${ApiConstants.expensesEndpoint}/$expenseId',
      data: expenseData,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await apiClient.delete('${ApiConstants.expensesEndpoint}/$expenseId');
  }

  @override
  Future<List<Map<String, dynamic>>> syncExpenses(
    List<Map<String, dynamic>> expenses,
  ) async {
    final response = await apiClient.post(
      '${ApiConstants.syncEndpoint}/expenses',
      data: {'expenses': expenses},
    );
    return List<Map<String, dynamic>>.from(response.data['expenses']);
  }
}
