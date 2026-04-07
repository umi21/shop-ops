import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String businessId;
  final String name;
  final String? imageUrl;
  final double defaultSellingPrice;
  final double costPrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.businessId,
    required this.name,
    this.imageUrl,
    required this.defaultSellingPrice,
    this.costPrice = 0.0,
    required this.stockQuantity,
    required this.lowStockThreshold,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => stockQuantity <= lowStockThreshold;
  bool get isOutOfStock => stockQuantity == 0;

  Product copyWith({
    String? id,
    String? businessId,
    String? name,
    String? imageUrl,
    double? defaultSellingPrice,
    double? costPrice,
    int? stockQuantity,
    int? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      defaultSellingPrice: defaultSellingPrice ?? this.defaultSellingPrice,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    businessId,
    name,
    imageUrl,
    defaultSellingPrice,
    costPrice,
    stockQuantity,
    lowStockThreshold,
    createdAt,
    updatedAt,
  ];
}
