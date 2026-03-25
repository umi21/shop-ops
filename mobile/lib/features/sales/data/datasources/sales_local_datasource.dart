import 'package:isar/isar.dart';
import 'package:mobile/features/sales/data/models/sale_model.dart';

abstract class SalesLocalDataSource {
  Future<List<SaleModel>> getSales(String businessId);
  Future<SaleModel?> getSale(String saleId);
  Future<void> saveSale(SaleModel sale);
  Future<void> deleteSale(String saleId);
  Future<List<SaleModel>> getSalesByDateRange(
    String businessId,
    DateTime from,
    DateTime to,
  );
  Future<List<SaleModel>> getUnsyncedSales();
}

class SalesLocalDataSourceImpl implements SalesLocalDataSource {
  final Isar isar;

  SalesLocalDataSourceImpl(this.isar);

  @override
  Future<List<SaleModel>> getSales(String businessId) async {
    return await isar.saleModels
        .filter()
        .businessIdEqualTo(businessId)
        .isVoidedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<SaleModel?> getSale(String saleId) async {
    return await isar.saleModels.filter().idEqualTo(saleId).findFirst();
  }

  @override
  Future<void> saveSale(SaleModel sale) async {
    await isar.writeTxn(() async {
      await isar.saleModels.put(sale);
    });
  }

  @override
  Future<void> deleteSale(String saleId) async {
    await isar.writeTxn(() async {
      final sale = await isar.saleModels.filter().idEqualTo(saleId).findFirst();
      if (sale != null) {
        await isar.saleModels.delete(sale.isarId);
      }
    });
  }

  @override
  Future<List<SaleModel>> getSalesByDateRange(
    String businessId,
    DateTime from,
    DateTime to,
  ) async {
    return await isar.saleModels
        .filter()
        .businessIdEqualTo(businessId)
        .createdAtBetween(from, to)
        .isVoidedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<List<SaleModel>> getUnsyncedSales() async {
    return await isar.saleModels.filter().isSyncedEqualTo(false).findAll();
  }
}
