import 'package:equatable/equatable.dart';
import 'inventory_bloc.dart'; // Pour importer ProductEntity

abstract class InventoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

// État initial (pendant le chargement)
class InventoryLoadingState extends InventoryState {}

// État quand les données sont prêtes à être affichées
class InventoryLoadedState extends InventoryState {
  final List<ProductEntity> products;
  final List<String> categories;
  final String selectedCategory;

  InventoryLoadedState({
    required this.products,
    required this.categories,
    required this.selectedCategory,
  });

  @override
  List<Object?> get props => [products, categories, selectedCategory];
}