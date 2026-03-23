import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/resources/api_constants.dart';
import 'package:mobile/features/auth/data/models/mappers/user_mapper.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  });
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? email,
  });
  Future<Map<String, dynamic>> syncUser(Map<String, dynamic> userData);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await apiClient.post(
      ApiConstants.loginEndpoint,
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final response = await apiClient.post(
      ApiConstants.registerEndpoint,
      data: {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? email,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;

    final response = await apiClient.patch(
      '${ApiConstants.profileEndpoint}/$userId',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> syncUser(Map<String, dynamic> userData) async {
    final response = await apiClient.post(
      '${ApiConstants.syncEndpoint}/user',
      data: userData,
    );
    return response.data as Map<String, dynamic>;
  }
}
