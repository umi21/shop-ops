import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';
import 'package:mobile/features/inventory/domain/repositories/inventory_repository.dart';

class AdjustStockUseCase implements UseCase<Product, AdjustStockParams> {
  final InventoryRepository repository;

  AdjustStockUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(AdjustStockParams params) async {
    return await repository.adjustStock(
      params.productId,
      params.quantityChange,
    );
  }
}

class AdjustStockParams extends Equatable {
  final String productId;
  final int quantityChange;

  const AdjustStockParams({
    required this.productId,
    required this.quantityChange,
  });

  @override
  List<Object?> get props => [productId, quantityChange];
}
