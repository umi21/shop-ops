import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';
import 'package:mobile/features/inventory/domain/repositories/inventory_repository.dart';

class GetProductDetailUseCase implements UseCase<Product, String> {
  final InventoryRepository repository;

  GetProductDetailUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(String productId) async {
    return await repository.getProductDetail(productId);
  }
}
