import 'package:mobile/features/sales/domain/entities/sale.dart';

class SaleModel extends Sale {
  const SaleModel({
    required super.id,
    required super.productName,
    required super.units,
    required super.amount,
    required super.date,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      productName: json['productName'],
      units: json['units'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'units': units,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
