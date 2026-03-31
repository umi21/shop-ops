import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';
import 'package:mobile/features/inventory/domain/repositories/inventory_repository.dart';

class AddProductUseCase implements UseCase<Product, AddProductParams> {
  final InventoryRepository repository;

  AddProductUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(AddProductParams params) async {
    return await repository.addProduct(params.product);
  }
}

class AddProductParams extends Equatable {
  final Product product;

  const AddProductParams({required this.product});

  @override
  List<Object?> get props => [product];
}
