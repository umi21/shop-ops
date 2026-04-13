import 'package:isar/isar.dart';

part 'product_model.g.dart';

@collection
class ProductModel {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  @Index()
  late String businessId;

  late String name;
  String? imageUrl;
  late double defaultSellingPrice;
  double costPrice = 0.0;
  late int stockQuantity;
  late int lowStockThreshold;
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
