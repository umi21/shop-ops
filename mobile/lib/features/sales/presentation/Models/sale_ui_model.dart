import 'package:flutter/material.dart';
import '../../domain/entities/sales.dart';

class SaleUiModel {
  final Sale sale;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const SaleUiModel({
    required this.sale,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  // Convenience getters so _SaleTile doesn't need to change much
  String get title => sale.productName;
  String get subtitle =>
      '${sale.quantity} units • ${_formatTime(sale.timestamp)}';
  double get amount => sale.totalAmount;
  bool get isReturn => sale.isVoided;

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

class SaleGroupUiModel {
  final String label;
  final double total;
  final List<SaleUiModel> sales;

  const SaleGroupUiModel({
    required this.label,
    required this.total,
    required this.sales,
  });
}