import 'package:dio/dio.dart';
import 'package:mobile/core/resources/data_state.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';
import 'package:mobile/features/sales/domain/repositories/sales_repository.dart';
import 'package:mobile/features/sales/data/datasources/sales_remote_data_source.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource _remoteDataSource;

  SalesRepositoryImpl(this._remoteDataSource);

  @override
  Future<DataState<List<Sale>>> getSalesHistory() async {
    try {
      final remoteSales = await _remoteDataSource.getSalesHistory();
      return DataSuccess(remoteSales);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
