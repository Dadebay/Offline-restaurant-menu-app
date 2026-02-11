import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';
import 'package:restaurant_menu_app/features/menu/services/excel_service.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final ExcelService _excelService;

  MenuBloc({ExcelService? excelService}) : _excelService = excelService ?? ExcelService(), super(MenuInitial()) {
    on<LoadMenu>(_onLoadMenu);
    on<FilterMenuByCategory>(_onFilterByCategory);
    on<AddMenuItem>(_onAddMenuItem);
    on<UpdateMenuItem>(_onUpdateMenuItem);
    on<DeleteMenuItem>(_onDeleteMenuItem);
    on<ExportToExcel>(_onExportToExcel);
    on<ImportFromExcel>(_onImportFromExcel);
  }

  // In-memory list to track current items
  final List<MenuItem> _currentItems = [];

  Future<void> _onLoadMenu(LoadMenu event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    try {
      // Step 1: Load from Excel
      final items = await _excelService.loadMenuFromExcel();

      _currentItems.clear();
      _currentItems.addAll(items);

      _emitLoaded(emit, List.from(_currentItems));
    } catch (e) {
      emit(MenuError('Failed to load menu: $e'));
    }
  }

  void _onFilterByCategory(FilterMenuByCategory event, Emitter<MenuState> emit) {
    if (state is MenuLoaded) {
      _emitLoaded(emit, _currentItems, selectedCategory: event.category);
    }
  }

  Future<void> _onAddMenuItem(AddMenuItem event, Emitter<MenuState> emit) async {
    try {
      // Step 1: Save to Excel file first
      await _excelService.addMenuItem(event.item);

      // Step 2: Update in-memory list
      _currentItems.add(event.item);

      // Step 3: Update UI state
      _emitLoaded(emit, List.from(_currentItems));
    } catch (e) {
      emit(MenuError('Failed to add item: $e'));
    }
  }

  Future<void> _onUpdateMenuItem(UpdateMenuItem event, Emitter<MenuState> emit) async {
    try {
      // Step 1: Update in-memory list
      final index = _currentItems.indexWhere((item) => item.id == event.item.id);
      if (index != -1) {
        _currentItems[index] = event.item;
      }

      // Step 2: Save all items to Excel
      await _excelService.saveAllMenuItems(_currentItems);

      // Step 3: Update UI state
      _emitLoaded(emit, List.from(_currentItems));
    } catch (e) {
      emit(MenuError('Failed to update item: $e'));
    }
  }

  Future<void> _onDeleteMenuItem(DeleteMenuItem event, Emitter<MenuState> emit) async {
    try {
      // Step 1: Remove from in-memory list
      _currentItems.removeWhere((item) => item.id == event.itemId);

      // Step 2: Save updated list to Excel
      await _excelService.saveAllMenuItems(_currentItems);

      // Step 3: Update UI state
      _emitLoaded(emit, List.from(_currentItems));
    } catch (e) {
      emit(MenuError('Failed to delete item: $e'));
    }
  }

  Future<void> _onExportToExcel(ExportToExcel event, Emitter<MenuState> emit) async {
    try {
      final currentState = state;
      emit(MenuLoading());

      final filePath = await _excelService.exportToExcel(_currentItems, event.categories);

      if (filePath != null) {
        emit(MenuExportSuccess(filePath));
      } else {
        emit(MenuError('Failed to export: Permission denied or file creation failed'));
      }

      // Restore previous state
      if (currentState is MenuLoaded) {
        emit(currentState);
      }
    } catch (e) {
      emit(MenuError('Failed to export: $e'));
    }
  }

  Future<void> _onImportFromExcel(ImportFromExcel event, Emitter<MenuState> emit) async {
    try {
      emit(MenuLoading());

      final data = await _excelService.importFromExcel();

      if (data == null) {
        emit(MenuError('Import cancelled or failed'));
        return;
      }

      final items = data['items'] as List<MenuItem>;
      final categories = data['categories'] as List;

      // Save imported items to local Excel
      await _excelService.saveAllMenuItems(items);

      // Update in-memory list
      _currentItems.clear();
      _currentItems.addAll(items);

      // Emit success state with categories for UI to handle
      emit(MenuImportSuccess(items, categories));

      // Then emit loaded state
      _emitLoaded(emit, List.from(_currentItems));
    } catch (e) {
      emit(MenuError('Failed to import: $e'));
    }
  }

  void _emitLoaded(Emitter<MenuState> emit, List<MenuItem> items, {String? selectedCategory}) {
    // 1. Filter available items for home screen
    final availableItems = items.where((i) => i.available).toList();

    // 2. Group by category (only available items)
    final Map<String, List<MenuItem>> grouped = {};
    for (var item in availableItems) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }

    emit(MenuLoaded(allItems: availableItems, allItemsIncludingUnavailable: items, categorizedItems: grouped, selectedCategory: selectedCategory));
  }
}
