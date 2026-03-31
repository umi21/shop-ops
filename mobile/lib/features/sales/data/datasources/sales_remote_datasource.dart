import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/resources/api_constants.dart';

abstract class SalesRemoteDataSource {
  Future<List<Map<String, dynamic>>> getSales(String businessId);
  Future<Map<String, dynamic>> createSale(Map<String, dynamic> saleData);
  Future<Map<String, dynamic>> updateSale(Map<String, dynamic> saleData);
  Future<void> deleteSale(String saleId);
  Future<List<Map<String, dynamic>>> syncSales(
    List<Map<String, dynamic>> sales,
  );
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final ApiClient apiClient;

  SalesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<Map<String, dynamic>>> getSales(String businessId) async {
    final response = await apiClient.get(
      '${ApiConstants.salesEndpoint}/$businessId',
    );
    return List<Map<String, dynamic>>.from(response.data['sales']);
  }

  @override
  Future<Map<String, dynamic>> createSale(Map<String, dynamic> saleData) async {
    final response = await apiClient.post(
      ApiConstants.salesEndpoint,
      data: saleData,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateSale(Map<String, dynamic> saleData) async {
    final saleId = saleData['id'];
    final response = await apiClient.put(
      '${ApiConstants.salesEndpoint}/$saleId',
      data: saleData,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> deleteSale(String saleId) async {
    await apiClient.delete('${ApiConstants.salesEndpoint}/$saleId');
  }

  @override
  Future<List<Map<String, dynamic>>> syncSales(
    List<Map<String, dynamic>> sales,
  ) async {
    final response = await apiClient.post(
      '${ApiConstants.syncEndpoint}/sales',
      data: {'sales': sales},
    );
    return List<Map<String, dynamic>>.from(response.data['sales']);
  }
}
