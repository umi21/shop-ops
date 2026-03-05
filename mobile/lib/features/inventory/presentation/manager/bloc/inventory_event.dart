import 'package:equatable/equatable.dart';

abstract class InventoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Événement déclenché à l'ouverture de la page
class LoadInventoryEvent extends InventoryEvent {}

// Événement déclenché quand on clique sur une catégorie
class ChangeCategoryEvent extends InventoryEvent {
  final String category;
  ChangeCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}