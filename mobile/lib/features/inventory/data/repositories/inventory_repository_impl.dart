import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/inventory/data/datasources/inventory_local_datasource.dart';
import 'package:mobile/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:mobile/features/inventory/data/models/mappers/product_mapper.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';
import 'package:mobile/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts(String businessId) async {
    try {
      final products = await localDataSource.getProducts(businessId);
      return Right(products.map((m) => ProductMapper.toEntity(m)).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductDetail(String productId) async {
    try {
      final product = await localDataSource.getProduct(productId);
      if (product != null) {
        return Right(ProductMapper.toEntity(product));
      }
      return const Left(NotFoundFailure('Product not found'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> addProduct(Product product) async {
    try {
      final model = ProductMapper.toModel(product, isSynced: false);
      await localDataSource.saveProduct(model);

      try {
        final productData = ProductMapper.toJson(model);
        final response = await remoteDataSource.createProduct(productData);
        final syncedModel = ProductMapper.fromJson(response);
        await localDataSource.saveProduct(syncedModel);
        return Right(ProductMapper.toEntity(syncedModel));
      } on NetworkException {
        return Right(product);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    try {
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      final model = ProductMapper.toModel(updatedProduct, isSynced: false);
      await localDataSource.saveProduct(model);

      try {
        final productData = ProductMapper.toJson(model);
        final response = await remoteDataSource.updateProduct(productData);
        final syncedModel = ProductMapper.fromJson(response);
        await localDataSource.saveProduct(syncedModel);
        return Right(ProductMapper.toEntity(syncedModel));
      } on NetworkException {
        return Right(updatedProduct);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    try {
      await localDataSource.deleteProduct(productId);

      try {
        await remoteDataSource.deleteProduct(productId);
      } on NetworkException {
        // Product deleted locally, will sync later
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getLowStockProducts(
    String businessId,
  ) async {
    try {
      final products = await localDataSource.getLowStockProducts(businessId);
      return Right(products.map((m) => ProductMapper.toEntity(m)).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getOutOfStockProducts(
    String businessId,
  ) async {
    try {
      final products = await localDataSource.getOutOfStockProducts(businessId);
      return Right(products.map((m) => ProductMapper.toEntity(m)).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> adjustStock(
    String productId,
    int quantityChange,
  ) async {
    try {
      final product = await localDataSource.getProduct(productId);
      if (product == null) {
        return const Left(NotFoundFailure('Product not found'));
      }

      final newQuantity = product.stockQuantity + quantityChange;
      if (newQuantity < 0) {
        return const Left(ValidationFailure('Stock cannot be negative'));
      }

      final updatedProduct = product
        ..stockQuantity = newQuantity
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await localDataSource.saveProduct(updatedProduct);

      try {
        final productData = ProductMapper.toJson(updatedProduct);
        final response = await remoteDataSource.updateProduct(productData);
        final syncedModel = ProductMapper.fromJson(response);
        await localDataSource.saveProduct(syncedModel);
        return Right(ProductMapper.toEntity(syncedModel));
      } on NetworkException {
        return Right(ProductMapper.toEntity(updatedProduct));
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
