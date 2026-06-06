class Sale {
  final String id;
  final String productName;
  final double amount;
  final int quantity;
  final DateTime timestamp;
  final bool isVoided;
  final String? productId;
  final String businessId;

  const Sale({
    required this.id,
    required this.productName,
    required this.amount,
    required this.quantity,
    required this.timestamp,
    required this.businessId,
    this.isVoided = false,
    this.productId,
  });

  double get totalAmount => amount * quantity;
}

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