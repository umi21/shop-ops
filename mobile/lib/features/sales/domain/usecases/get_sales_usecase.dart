import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';
import 'package:mobile/features/sales/domain/repositories/sales_repository.dart';

class GetSalesUseCase implements UseCase<List<Sale>, String> {
  final SalesRepository repository;

  GetSalesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Sale>>> call(String businessId) async {
    return await repository.getSales(businessId);
  }
}
