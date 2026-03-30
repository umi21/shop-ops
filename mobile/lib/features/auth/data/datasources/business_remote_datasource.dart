import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/resources/api_constants.dart';
//import 'package:mobile/features/auth/data/models/mappers/business_mapper.dart';

abstract class BusinessRemoteDataSource {
  Future<Map<String, dynamic>> getBusiness(String userId);
  Future<Map<String, dynamic>> createBusiness(
    Map<String, dynamic> businessData,
  );
  Future<Map<String, dynamic>> updateBusiness(
    Map<String, dynamic> businessData,
  );
  Future<List<Map<String, dynamic>>> syncBusinesses(
    List<Map<String, dynamic>> businesses,
  );
}

class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  final ApiClient apiClient;

  BusinessRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Map<String, dynamic>> getBusiness(String userId) async {
    final response = await apiClient.get(
      '${ApiConstants.businessEndpoint}/$userId',
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> createBusiness(
    Map<String, dynamic> businessData,
  ) async {
    final response = await apiClient.post(
      ApiConstants.businessEndpoint,
      data: businessData,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateBusiness(
    Map<String, dynamic> businessData,
  ) async {
    final businessId = businessData['id'];
    final response = await apiClient.put(
      '${ApiConstants.businessEndpoint}/$businessId',
      data: businessData,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> syncBusinesses(
    List<Map<String, dynamic>> businesses,
  ) async {
    final response = await apiClient.post(
      '${ApiConstants.syncEndpoint}/businesses',
      data: {'businesses': businesses},
    );
    return List<Map<String, dynamic>>.from(response.data['businesses']);
  }
}
