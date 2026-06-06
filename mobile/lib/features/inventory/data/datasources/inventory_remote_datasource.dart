import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/resources/api_constants.dart';
import 'package:mobile/features/inventory/data/models/mappers/product_mapper.dart';

abstract class InventoryRemoteDataSource {
  Future<List<Map<String, dynamic>>> getProducts(String businessId);
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData);
  Future<Map<String, dynamic>> updateProduct(Map<String, dynamic> productData);
  Future<void> deleteProduct(String productId);
  Future<List<Map<String, dynamic>>> syncProducts(
    List<Map<String, dynamic>> products,
  );
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient apiClient;

  InventoryRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<Map<String, dynamic>>> getProducts(String businessId) async {
    final response = await apiClient.get(
      '${ApiConstants.productsEndpoint}/$businessId',
    );
    return List<Map<String, dynamic>>.from(response.data['products']);
  }

  @override
  Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> productData,
  ) async {
    final response = await apiClient.post(
      ApiConstants.productsEndpoint,
      data: productData,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateProduct(
    Map<String, dynamic> productData,
  ) async {
    final productId = productData['id'];
    final response = await apiClient.put(
      '${ApiConstants.productsEndpoint}/$productId',
      data: productData,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await apiClient.delete('${ApiConstants.productsEndpoint}/$productId');
  }

  @override
  Future<List<Map<String, dynamic>>> syncProducts(
    List<Map<String, dynamic>> products,
  ) async {
    final response = await apiClient.post(
      '${ApiConstants.syncEndpoint}/products',
      data: {'products': products},
    );
    return List<Map<String, dynamic>>.from(response.data['products']);
  }
}
