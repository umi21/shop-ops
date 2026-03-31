import 'package:isar/isar.dart';
import 'package:mobile/features/inventory/data/models/product_model.dart';

abstract class InventoryLocalDataSource {
  Future<List<ProductModel>> getProducts(String businessId);
  Future<ProductModel?> getProduct(String productId);
  Future<void> saveProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
  Future<List<ProductModel>> getLowStockProducts(String businessId);
  Future<List<ProductModel>> getOutOfStockProducts(String businessId);
  Future<List<ProductModel>> getUnsyncedProducts();
}

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  final Isar isar;

  InventoryLocalDataSourceImpl(this.isar);

  @override
  Future<List<ProductModel>> getProducts(String businessId) async {
    return await isar.productModels
        .filter()
        .businessIdEqualTo(businessId)
        .sortByNameDesc()
        .findAll();
  }

  @override
  Future<ProductModel?> getProduct(String productId) async {
    return await isar.productModels.filter().idEqualTo(productId).findFirst();
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    await isar.writeTxn(() async {
      await isar.productModels.put(product);
    });
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await isar.writeTxn(() async {
      final product = await isar.productModels
          .filter()
          .idEqualTo(productId)
          .findFirst();
      if (product != null) {
        await isar.productModels.delete(product.isarId);
      }
    });
  }

  @override
  Future<List<ProductModel>> getLowStockProducts(String businessId) async {
    return await isar.productModels
        .filter()
        .businessIdEqualTo(businessId)
        .stockQuantityLessThan(await _getThreshold(businessId), include: true)
        .stockQuantityGreaterThan(0)
        .findAll();
  }

  @override
  Future<List<ProductModel>> getOutOfStockProducts(String businessId) async {
    return await isar.productModels
        .filter()
        .businessIdEqualTo(businessId)
        .stockQuantityEqualTo(0)
        .findAll();
  }

  Future<int> _getThreshold(String businessId) async {
    final products = await getProducts(businessId);
    if (products.isEmpty) return 5;
    return products.first.lowStockThreshold;
  }

  @override
  Future<List<ProductModel>> getUnsyncedProducts() async {
    return await isar.productModels.filter().isSyncedEqualTo(false).findAll();
  }
}
