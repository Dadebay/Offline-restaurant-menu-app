import 'package:equatable/equatable.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';
import 'package:restaurant_menu_app/features/settings/models/category.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

class LoadMenu extends MenuEvent {}

class FilterMenuByCategory extends MenuEvent {
  final String category;
  const FilterMenuByCategory(this.category);

  @override
  List<Object> get props => [category];
}

class AddMenuItem extends MenuEvent {
  final MenuItem item;
  const AddMenuItem(this.item);

  @override
  List<Object> get props => [item];
}

class UpdateMenuItem extends MenuEvent {
  final MenuItem item;
  const UpdateMenuItem(this.item);

  @override
  List<Object> get props => [item];
}

class DeleteMenuItem extends MenuEvent {
  final String itemId;
  const DeleteMenuItem(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class ExportToExcel extends MenuEvent {
  final List<Category> categories;
  const ExportToExcel(this.categories);

  @override
  List<Object> get props => [categories];
}

class ImportFromExcel extends MenuEvent {
  const ImportFromExcel();
}
