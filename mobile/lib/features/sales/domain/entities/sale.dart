import 'package:equatable/equatable.dart';

class Sale extends Equatable {
  final String id;
  final String productName;
  final int units;
  final double amount;
  final DateTime date;

  const Sale({
    required this.id,
    required this.productName,
    required this.units,
    required this.amount,
    required this.date,
  });

  @override
  List<Object?> get props => [id, productName, units, amount, date];
}
