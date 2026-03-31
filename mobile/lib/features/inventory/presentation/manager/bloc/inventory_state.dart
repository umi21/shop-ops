import 'package:equatable/equatable.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';

abstract class InventoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InventoryInitialState extends InventoryState {}

class InventoryLoadingState extends InventoryState {}

class InventoryLoadedState extends InventoryState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  InventoryLoadedState({
    required this.products,
    required this.filteredProducts,
    required this.categories,
    required this.selectedCategory,
    this.searchQuery = '',
    this.errorMessage,
  });

  InventoryLoadedState copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
  }) {
    return InventoryLoadedState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    products,
    filteredProducts,
    categories,
    selectedCategory,
    searchQuery,
    errorMessage,
  ];
}

class InventoryErrorState extends InventoryState {
  final String message;

  InventoryErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
