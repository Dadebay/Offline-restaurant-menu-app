import 'package:equatable/equatable.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<MenuItem> allItems; // Only available items for home screen
  final List<MenuItem> allItemsIncludingUnavailable; // All items for product management
  final Map<String, List<MenuItem>> categorizedItems;
  final String? selectedCategory;

  const MenuLoaded({required this.allItems, required this.allItemsIncludingUnavailable, required this.categorizedItems, this.selectedCategory});

  @override
  List<Object> get props => [allItems, allItemsIncludingUnavailable, categorizedItems, selectedCategory ?? ''];
}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object> get props => [message];
}

class MenuExportSuccess extends MenuState {
  final String filePath;

  const MenuExportSuccess(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class MenuImportSuccess extends MenuState {
  final List<MenuItem> items;
  final List categories;

  const MenuImportSuccess(this.items, this.categories);

  @override
  List<Object> get props => [items, categories];
}
