import 'package:flutter_bloc/flutter_bloc.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class ProductEntity {
  final String name, sku, imageUrl, category;
  final int quantity;
  ProductEntity({required this.name, required this.sku, required this.quantity, required this.imageUrl, required this.category});
}

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final List<String> _categories = ['All Items', 'Beverages', 'Dairy', 'Bakery', 'Fruit'];
  
  // Simulated Data
  final List<ProductEntity> _allProducts = [
    ProductEntity(name: 'Whole Milk 1L', sku: 'SKU: MK-2024', quantity: 0, category: 'Dairy', imageUrl: 'url'),
    ProductEntity(name: 'Arabica Coffee', sku: 'SKU: CF-8812', quantity: 4, category: 'Beverages', imageUrl: 'url'),
    ProductEntity(name: 'Sourdough Loaf', sku: 'SKU: BK-1102', quantity: 24, category: 'Bakery', imageUrl: 'url'),
    ProductEntity(name: 'Bananas (Bunch)', sku: 'SKU: FR-0091', quantity: 18, category: 'Fruit', imageUrl: 'url'),
    ProductEntity(name: 'Eggs (Dozen)', sku: 'SKU: DY-4421', quantity: 2, category: 'Dairy', imageUrl: 'url'),
    ProductEntity(name: 'Mineral Water 500ml', sku: 'SKU: BV-9901', quantity: 42, category: 'Beverages', imageUrl: 'url'),
  ];

  InventoryBloc() : super(InventoryLoadingState()) {
    // Load Event Management
    on<LoadInventoryEvent>((event, emit) {
      // We emit the loaded state with 'All Items' as default
      emit(InventoryLoadedState(
        products: _allProducts,
        categories: _categories,
        selectedCategory: 'All Items',
      ));
    });

    // Category Change Event Management
    on<ChangeCategoryEvent>((event, emit) {
      final filteredList = event.category == 'All Items'
          ? _allProducts
          : _allProducts.where((p) => p.category == event.category).toList();

      // We emit the new state with the filtered list
      emit(InventoryLoadedState(
        products: filteredList,
        categories: _categories,
        selectedCategory: event.category,
      ));
    });
  }
}