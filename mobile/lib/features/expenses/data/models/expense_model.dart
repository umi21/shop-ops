import 'package:isar/isar.dart';
import 'package:mobile/core/enums/expense_category.dart';

part 'expense_model.g.dart';

@collection
class ExpenseModel {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  @Index()
  late String businessId;

  @enumerated
  late ExpenseCategory category;

  late double amount;
  String? note;

  @Index()
  late DateTime createdAt;

  late bool isVoided;
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
