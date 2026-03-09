import 'package:dio/dio.dart';
import 'package:mobile/features/sales/data/models/sale_model.dart';

abstract class SalesRemoteDataSource {
  Future<List<SaleModel>> getSalesHistory();
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final Dio dio;

  SalesRemoteDataSourceImpl(this.dio);

  @override
  Future<List<SaleModel>> getSalesHistory() async {
    final response = await dio.get('/sales/history');

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((e) => SaleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }
}
