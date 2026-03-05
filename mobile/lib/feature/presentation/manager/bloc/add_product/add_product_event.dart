import 'package:equatable/equatable.dart';

abstract class AddProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateStockEvent extends AddProductEvent {
  final int newStock;
  UpdateStockEvent(this.newStock);

  @override
  List<Object?> get props => [newStock];
}

class UpdatePricesEvent extends AddProductEvent {
  final double costPrice;
  final double sellingPrice;
  
  UpdatePricesEvent({required this.costPrice, required this.sellingPrice});

  @override
  List<Object?> get props => [costPrice, sellingPrice];
}