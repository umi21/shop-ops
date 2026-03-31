import 'package:mobile/features/sales/data/models/sale_model.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';

class SaleMapper {
  static Sale toEntity(SaleModel model) {
    return Sale(
      id: model.id,
      businessId: model.businessId,
      productId: model.productId,
      unitPrice: model.unitPrice,
      quantity: model.quantity,
      total: model.total,
      createdAt: model.createdAt,
      isVoided: model.isVoided,
    );
  }

  static SaleModel toModel(
    Sale entity, {
    DateTime? syncedAt,
    bool isSynced = false,
  }) {
    return SaleModel()
      ..id = entity.id
      ..businessId = entity.businessId
      ..productId = entity.productId
      ..unitPrice = entity.unitPrice
      ..quantity = entity.quantity
      ..total = entity.total
      ..createdAt = entity.createdAt
      ..isVoided = entity.isVoided
      ..syncedAt = syncedAt ?? DateTime.now()
      ..isSynced = isSynced;
  }

  static Map<String, dynamic> toJson(SaleModel model) {
    return {
      'id': model.id,
      'businessId': model.businessId,
      'productId': model.productId,
      'unitPrice': model.unitPrice,
      'quantity': model.quantity,
      'total': model.total,
      'createdAt': model.createdAt.toIso8601String(),
      'isVoided': model.isVoided,
    };
  }

  static SaleModel fromJson(Map<String, dynamic> json) {
    return SaleModel()
      ..id = json['id']
      ..businessId = json['businessId']
      ..productId = json['productId']
      ..unitPrice = (json['unitPrice'] as num).toDouble()
      ..quantity = json['quantity']
      ..total = (json['total'] as num).toDouble()
      ..createdAt = DateTime.parse(json['createdAt'])
      ..isVoided = json['isVoided'] ?? false
      ..syncedAt = DateTime.now()
      ..isSynced = true;
  }
}
