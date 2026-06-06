import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/core/value_objects/profit_summary.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';

abstract class SalesRepository {
  Future<Either<Failure, List<Sale>>> getSales(String businessId);
  Future<Either<Failure, Sale>> addSale(Sale sale);
  Future<Either<Failure, Sale>> updateSale(Sale sale);
  Future<Either<Failure, void>> deleteSale(String saleId);
  Future<Either<Failure, void>> voidSale(String saleId);
  Future<Either<Failure, List<Sale>>> getSalesByDateRange(
    String businessId,
    DateRange dateRange,
  );
  Future<Either<Failure, double>> getTotalSalesByDateRange(
    String businessId,
    DateRange dateRange,
  );
  Future<Either<Failure, ProfitSummary>> getProfitSummary(
    String businessId,
    DateRange dateRange,
  );
}
