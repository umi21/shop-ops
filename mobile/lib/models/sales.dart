import 'package:flutter/material.dart';

class SaleGroup {
  final String label;
  final double total;
  final List<Sale> sales;

  const SaleGroup({
    required this.label,
    required this.total,
    required this.sales,
  });
}

class Sale {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final double amount;
  final bool isReturn;

  const Sale({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isReturn,
  });
}