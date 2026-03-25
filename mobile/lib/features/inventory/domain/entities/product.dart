import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String businessId;
  final String name;
  final double defaultSellingPrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.businessId,
    required this.name,
    required this.defaultSellingPrice,
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
    double? defaultSellingPrice,
    int? stockQuantity,
    int? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      defaultSellingPrice: defaultSellingPrice ?? this.defaultSellingPrice,
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
    defaultSellingPrice,
    stockQuantity,
    lowStockThreshold,
    createdAt,
    updatedAt,
  ];
}
