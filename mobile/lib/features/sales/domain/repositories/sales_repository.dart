import '../../../../core/resources/data_state.dart';
import '../entities/sale.dart';

abstract class SalesRepository {
  Future<DataState<List<Sale>>> getSalesHistory();
}
