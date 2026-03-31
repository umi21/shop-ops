import 'package:isar/isar.dart';

part 'user_model.g.dart';

@collection
class UserModel {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  late String phone;

  @Index(unique: true)
  late String email;

  String? passwordHash;
  late String name;
  late DateTime createdAt;
  late DateTime updatedAt;
  late DateTime syncedAt;
  late bool isSynced;
}

int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}
