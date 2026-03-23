import 'package:isar/isar.dart';
import 'package:mobile/features/auth/data/models/business_model.dart';

abstract class BusinessLocalDataSource {
  Future<BusinessModel?> getBusiness(String userId);
  Future<List<BusinessModel>> getAllBusinesses();
  Future<void> saveBusiness(BusinessModel business);
  Future<void> deleteBusiness(String businessId);
  Future<List<BusinessModel>> getUnsyncedBusinesses();
}

class BusinessLocalDataSourceImpl implements BusinessLocalDataSource {
  final Isar isar;

  BusinessLocalDataSourceImpl(this.isar);

  @override
  Future<BusinessModel?> getBusiness(String userId) async {
    return await isar.businessModels.filter().userIdEqualTo(userId).findFirst();
  }

  @override
  Future<List<BusinessModel>> getAllBusinesses() async {
    return await isar.businessModels.where().findAll();
  }

  @override
  Future<void> saveBusiness(BusinessModel business) async {
    await isar.writeTxn(() async {
      await isar.businessModels.put(business);
    });
  }

  @override
  Future<void> deleteBusiness(String businessId) async {
    await isar.writeTxn(() async {
      final business = await isar.businessModels
          .filter()
          .idEqualTo(businessId)
          .findFirst();
      if (business != null) {
        await isar.businessModels.delete(business.isarId);
      }
    });
  }

  @override
  Future<List<BusinessModel>> getUnsyncedBusinesses() async {
    return await isar.businessModels.filter().isSyncedEqualTo(false).findAll();
  }
}
