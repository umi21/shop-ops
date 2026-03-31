import 'package:isar/isar.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getUser();
  Future<void> saveUser(UserModel user);
  Future<void> deleteUser();
  Future<bool> hasUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Isar isar;

  AuthLocalDataSourceImpl(this.isar);

  @override
  Future<UserModel?> getUser() async {
    return await isar.userModels.where().findFirst();
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await isar.writeTxn(() async {
      await isar.userModels.clear();
      await isar.userModels.put(user);
    });
  }

  @override
  Future<void> deleteUser() async {
    await isar.writeTxn(() async {
      await isar.userModels.clear();
    });
  }

  @override
  Future<bool> hasUser() async {
    final count = await isar.userModels.count();
    return count > 0;
  }
}
