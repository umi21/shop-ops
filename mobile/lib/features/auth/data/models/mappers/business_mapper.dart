import 'package:mobile/core/enums/subscription_tier.dart';
import 'package:mobile/features/auth/data/models/business_model.dart';
import 'package:mobile/features/auth/domain/entities/business.dart';

class BusinessMapper {
  static Business toEntity(BusinessModel model) {
    return Business(
      id: model.id,
      userId: model.userId,
      name: model.name,
      currency: model.currency,
      language: model.language,
      tier: model.tier,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static BusinessModel toModel(
    Business entity, {
    DateTime? syncedAt,
    bool isSynced = false,
  }) {
    return BusinessModel()
      ..id = entity.id
      ..userId = entity.userId
      ..name = entity.name
      ..currency = entity.currency
      ..language = entity.language
      ..tier = entity.tier
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..syncedAt = syncedAt ?? DateTime.now()
      ..isSynced = isSynced;
  }

  static Map<String, dynamic> toJson(BusinessModel model) {
    return {
      'id': model.id,
      'userId': model.userId,
      'name': model.name,
      'currency': model.currency,
      'language': model.language,
      'tier': model.tier.name,
      'createdAt': model.createdAt.toIso8601String(),
      'updatedAt': model.updatedAt.toIso8601String(),
    };
  }

  static BusinessModel fromJson(Map<String, dynamic> json) {
    return BusinessModel()
      ..id = json['id']
      ..userId = json['userId']
      ..name = json['name']
      ..currency = json['currency']
      ..language = json['language']
      ..tier = SubscriptionTier.fromString(json['tier'] ?? 'free')
      ..createdAt = DateTime.parse(json['createdAt'])
      ..updatedAt = DateTime.parse(json['updatedAt'])
      ..syncedAt = DateTime.now()
      ..isSynced = true;
  }
}
