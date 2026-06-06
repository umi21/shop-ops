import 'package:mobile/features/inventory/data/models/product_model.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';

class ProductMapper {
  static Product toEntity(ProductModel model) {
    return Product(
      id: model.id,
      businessId: model.businessId,
      name: model.name,
      imageUrl: model.imageUrl,
      defaultSellingPrice: model.defaultSellingPrice,
      costPrice: model.costPrice,
      stockQuantity: model.stockQuantity,
      lowStockThreshold: model.lowStockThreshold,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static ProductModel toModel(
    Product entity, {
    DateTime? syncedAt,
    bool isSynced = false,
  }) {
    return ProductModel()
      ..id = entity.id
      ..businessId = entity.businessId
      ..name = entity.name
      ..imageUrl = entity.imageUrl
      ..defaultSellingPrice = entity.defaultSellingPrice
      ..costPrice = entity.costPrice
      ..stockQuantity = entity.stockQuantity
      ..lowStockThreshold = entity.lowStockThreshold
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..syncedAt = syncedAt ?? DateTime.now()
      ..isSynced = isSynced;
  }

  static Map<String, dynamic> toJson(ProductModel model) {
    return {
      'id': model.id,
      'businessId': model.businessId,
      'name': model.name,
      'imageUrl': model.imageUrl,
      'defaultSellingPrice': model.defaultSellingPrice,
      'costPrice': model.costPrice,
      'stockQuantity': model.stockQuantity,
      'lowStockThreshold': model.lowStockThreshold,
      'createdAt': model.createdAt.toIso8601String(),
      'updatedAt': model.updatedAt.toIso8601String(),
    };
  }

  static ProductModel fromJson(Map<String, dynamic> json) {
    return ProductModel()
      ..id = json['id']
      ..businessId = json['businessId']
      ..name = json['name']
      ..imageUrl = json['imageUrl']
      ..defaultSellingPrice = (json['defaultSellingPrice'] as num).toDouble()
      ..costPrice = (json['costPrice'] as num?)?.toDouble() ?? 0.0
      ..stockQuantity = json['stockQuantity']
      ..lowStockThreshold = json['lowStockThreshold'] ?? 5
      ..createdAt = DateTime.parse(json['createdAt'])
      ..updatedAt = DateTime.parse(json['updatedAt'])
      ..syncedAt = DateTime.now()
      ..isSynced = true;
  }
}
