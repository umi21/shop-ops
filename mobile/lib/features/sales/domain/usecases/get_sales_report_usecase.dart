import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';
import 'package:mobile/features/sales/domain/repositories/sales_repository.dart';

class GetSalesReportUseCase implements UseCase<List<Sale>, SalesReportParams> {
  final SalesRepository repository;

  GetSalesReportUseCase(this.repository);

  @override
  Future<Either<Failure, List<Sale>>> call(SalesReportParams params) async {
    return await repository.getSalesByDateRange(
      params.businessId,
      params.dateRange,
    );
  }
}

class SalesReportParams extends Equatable {
  final String businessId;
  final DateRange dateRange;

  const SalesReportParams({required this.businessId, required this.dateRange});

  @override
  List<Object?> get props => [businessId, dateRange];
}
