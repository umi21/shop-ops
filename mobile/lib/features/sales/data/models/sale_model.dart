import 'package:isar/isar.dart';

part 'sale_model.g.dart';

@collection
class SaleModel {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  @Index()
  late String businessId;

  @Index()
  late String productId;

  late double unitPrice;
  late int quantity;
  late double total;

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
