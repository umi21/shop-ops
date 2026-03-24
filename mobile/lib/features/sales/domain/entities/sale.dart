import 'package:equatable/equatable.dart';

class Sale extends Equatable {
  final String id;
  final String businessId;
  final String productId;
  final double unitPrice;
  final int quantity;
  final double total;
  final DateTime createdAt;
  final bool isVoided;

  const Sale({
    required this.id,
    required this.businessId,
    required this.productId,
    required this.unitPrice,
    required this.quantity,
    required this.total,
    required this.createdAt,
    this.isVoided = false,
  });

  factory Sale.create({
    required String id,
    required String businessId,
    required String productId,
    required double unitPrice,
    required int quantity,
    DateTime? createdAt,
  }) {
    final total = unitPrice * quantity;
    return Sale(
      id: id,
      businessId: businessId,
      productId: productId,
      unitPrice: unitPrice,
      quantity: quantity,
      total: total,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  Sale copyWith({
    String? id,
    String? businessId,
    String? productId,
    double? unitPrice,
    int? quantity,
    double? total,
    DateTime? createdAt,
    bool? isVoided,
  }) {
    return Sale(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      productId: productId ?? this.productId,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      isVoided: isVoided ?? this.isVoided,
    );
  }

  @override
  List<Object?> get props => [
    id,
    businessId,
    productId,
    unitPrice,
    quantity,
    total,
    createdAt,
    isVoided,
  ];
}
