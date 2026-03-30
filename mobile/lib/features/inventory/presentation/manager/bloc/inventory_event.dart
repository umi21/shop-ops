import 'package:equatable/equatable.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';

abstract class InventoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadInventoryEvent extends InventoryEvent {
  final String businessId;
  LoadInventoryEvent(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

class ChangeCategoryEvent extends InventoryEvent {
  final String category;
  ChangeCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchProductsEvent extends InventoryEvent {
  final String query;
  SearchProductsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class AddProductEvent extends InventoryEvent {
  final Product product;
  AddProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductEvent extends InventoryEvent {
  final Product product;
  UpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends InventoryEvent {
  final String productId;
  DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class AdjustStockEvent extends InventoryEvent {
  final String productId;
  final int quantityChange;
  AdjustStockEvent(this.productId, this.quantityChange);

  @override
  List<Object?> get props => [productId, quantityChange];
}
