import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';

abstract class InventoryRepository {
  Future<Either<Failure, List<Product>>> getProducts(String businessId);
  Future<Either<Failure, Product>> getProductDetail(String productId);
  Future<Either<Failure, Product>> addProduct(Product product);
  Future<Either<Failure, Product>> updateProduct(Product product);
  Future<Either<Failure, void>> deleteProduct(String productId);
  Future<Either<Failure, List<Product>>> getLowStockProducts(String businessId);
  Future<Either<Failure, List<Product>>> getOutOfStockProducts(
    String businessId,
  );
  Future<Either<Failure, Product>> adjustStock(
    String productId,
    int quantityChange,
  );
}
