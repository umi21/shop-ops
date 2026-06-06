import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';
import 'package:mobile/features/inventory/domain/repositories/inventory_repository.dart';

class GetOutOfStockAlertsUseCase implements UseCase<List<Product>, String> {
  final InventoryRepository repository;

  GetOutOfStockAlertsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(String businessId) async {
    return await repository.getOutOfStockProducts(businessId);
  }
}
