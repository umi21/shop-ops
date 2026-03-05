import 'package:equatable/equatable.dart';

class AddProductState extends Equatable {
  final int stock;
  final double costPrice;
  final double sellingPrice;
  final double marginAmount;
  final double marginPercentage;

  const AddProductState({
    this.stock = 0,
    this.costPrice = 0.0,
    this.sellingPrice = 0.0,
    this.marginAmount = 0.0,
    this.marginPercentage = 0.0,
  });

  AddProductState copyWith({
    int? stock,
    double? costPrice,
    double? sellingPrice,
    double? marginAmount,
    double? marginPercentage,
  }) {
    return AddProductState(
      stock: stock ?? this.stock,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      marginAmount: marginAmount ?? this.marginAmount,
      marginPercentage: marginPercentage ?? this.marginPercentage,
    );
  }

  @override
  List<Object?> get props => [stock, costPrice, sellingPrice, marginAmount, marginPercentage];
}