import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/sales/domain/repositories/sales_repository.dart';

class VoidSaleUseCase implements UseCase<void, String> {
  final SalesRepository repository;

  VoidSaleUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String saleId) async {
    return await repository.voidSale(saleId);
  }
}
