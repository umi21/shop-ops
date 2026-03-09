import 'package:mobile/core/resources/data_state.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';
import 'package:mobile/features/sales/domain/repositories/sales_repository.dart';

class GetSalesHistory {
  final SalesRepository repository;

  GetSalesHistory(this.repository);

  Future<DataState<List<Sale>>> call() async {
    return repository.getSalesHistory();
  }
}
