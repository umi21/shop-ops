import 'package:isar/isar.dart';
import 'package:mobile/core/enums/subscription_tier.dart';

part 'business_model.g.dart';

@collection
class BusinessModel {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  @Index()
  late String userId;

  late String name;
  late String currency;
  late String language;

  @enumerated
  late SubscriptionTier tier;

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
