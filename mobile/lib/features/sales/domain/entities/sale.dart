import 'package:equatable/equatable.dart';

class Sale extends Equatable {
  final String id;
  final String businessId;
  final String productId;
  final String? productName;
  final double unitPrice;
  final int quantity;
  final double total;
  final DateTime createdAt;
  final bool isVoided;

  const Sale({
    required this.id,
    required this.businessId,
    required this.productId,
    this.productName,
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
    String? productName,
    required double unitPrice,
    required int quantity,
    DateTime? createdAt,
  }) {
    final total = unitPrice * quantity;
    return Sale(
      id: id,
      businessId: businessId,
      productId: productId,
      productName: productName,
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
    String? productName,
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
      productName: productName ?? this.productName,
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
    productName,
    unitPrice,
    quantity,
    total,
    createdAt,
    isVoided,
  ];
}
