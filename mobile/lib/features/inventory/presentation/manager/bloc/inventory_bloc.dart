import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';
import 'package:mobile/features/inventory/domain/usecases/add_product_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/adjust_stock_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/delete_product_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/get_products_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/update_product_usecase.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetProductsUseCase getProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final AdjustStockUseCase adjustStockUseCase;

  List<Product> _allProducts = [];

  InventoryBloc({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.adjustStockUseCase,
  }) : super(InventoryInitialState()) {
    on<LoadInventoryEvent>(_onLoadInventory);
    on<ChangeCategoryEvent>(_onChangeCategory);
    on<SearchProductsEvent>(_onSearchProducts);
    on<AddProductEvent>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<AdjustStockEvent>(_onAdjustStock);
  }

  List<String> _getCategories(List<Product> products) {
    return ['All Items'];
  }

  List<Product> _filterProducts(
    List<Product> products,
    String category,
    String searchQuery,
  ) {
    var filtered = products;

    if (category != 'All Items') {
      filtered = filtered.where((p) {
        if (p.name.toLowerCase().contains(category.toLowerCase())) {
          return true;
        }
        return false;
      }).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                p.id.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  Future<void> _onLoadInventory(
    LoadInventoryEvent event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoadingState());

    final result = await getProductsUseCase(event.businessId);

    result.fold((failure) => emit(InventoryErrorState(failure.message)), (
      products,
    ) {
      _allProducts = products;
      final categories = _getCategories(products);
      emit(
        InventoryLoadedState(
          products: products,
          filteredProducts: products,
          categories: categories,
          selectedCategory: 'All Items',
        ),
      );
    });
  }

  void _onChangeCategory(
    ChangeCategoryEvent event,
    Emitter<InventoryState> emit,
  ) {
    if (state is InventoryLoadedState) {
      final currentState = state as InventoryLoadedState;
      final filtered = _filterProducts(
        _allProducts,
        event.category,
        currentState.searchQuery,
      );

      emit(
        currentState.copyWith(
          selectedCategory: event.category,
          filteredProducts: filtered,
        ),
      );
    }
  }

  void _onSearchProducts(
    SearchProductsEvent event,
    Emitter<InventoryState> emit,
  ) {
    if (state is InventoryLoadedState) {
      final currentState = state as InventoryLoadedState;
      final filtered = _filterProducts(
        _allProducts,
        currentState.selectedCategory,
        event.query,
      );

      emit(
        currentState.copyWith(
          searchQuery: event.query,
          filteredProducts: filtered,
        ),
      );
    }
  }

  Future<void> _onAddProduct(
    AddProductEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryLoadedState) {
      final currentState = state as InventoryLoadedState;

      final result = await addProductUseCase(
        AddProductParams(product: event.product),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
        (product) {
          _allProducts = [..._allProducts, product];
          final filtered = _filterProducts(
            _allProducts,
            currentState.selectedCategory,
            currentState.searchQuery,
          );

          emit(
            currentState.copyWith(
              products: _allProducts,
              filteredProducts: filtered,
            ),
          );
        },
      );
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryLoadedState) {
      final currentState = state as InventoryLoadedState;

      final result = await updateProductUseCase(
        UpdateProductParams(product: event.product),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
        (product) {
          _allProducts = _allProducts.map((p) {
            return p.id == product.id ? product : p;
          }).toList();

          final filtered = _filterProducts(
            _allProducts,
            currentState.selectedCategory,
            currentState.searchQuery,
          );

          emit(
            currentState.copyWith(
              products: _allProducts,
              filteredProducts: filtered,
            ),
          );
        },
      );
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryLoadedState) {
      final currentState = state as InventoryLoadedState;

      final result = await deleteProductUseCase(event.productId);

      result.fold(
        (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
        (_) {
          _allProducts = _allProducts
              .where((p) => p.id != event.productId)
              .toList();

          final filtered = _filterProducts(
            _allProducts,
            currentState.selectedCategory,
            currentState.searchQuery,
          );

          emit(
            currentState.copyWith(
              products: _allProducts,
              filteredProducts: filtered,
            ),
          );
        },
      );
    }
  }

  Future<void> _onAdjustStock(
    AdjustStockEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryLoadedState) {
      final currentState = state as InventoryLoadedState;

      final result = await adjustStockUseCase(
        AdjustStockParams(
          productId: event.productId,
          quantityChange: event.quantityChange,
        ),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
        (product) {
          _allProducts = _allProducts.map((p) {
            return p.id == product.id ? product : p;
          }).toList();

          final filtered = _filterProducts(
            _allProducts,
            currentState.selectedCategory,
            currentState.searchQuery,
          );

          emit(
            currentState.copyWith(
              products: _allProducts,
              filteredProducts: filtered,
            ),
          );
        },
      );
    }
  }
}
