import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/core/value_objects/profit_summary.dart';
import 'package:mobile/features/sales/domain/repositories/sales_repository.dart';

class CalculateProfitUseCase implements UseCase<ProfitSummary, ProfitParams> {
  final SalesRepository repository;

  CalculateProfitUseCase(this.repository);

  @override
  Future<Either<Failure, ProfitSummary>> call(ProfitParams params) async {
    return await repository.getProfitSummary(
      params.businessId,
      params.dateRange,
    );
  }
}

class ProfitParams extends Equatable {
  final String businessId;
  final DateRange dateRange;

  const ProfitParams({required this.businessId, required this.dateRange});

  @override
  List<Object?> get props => [businessId, dateRange];
}
