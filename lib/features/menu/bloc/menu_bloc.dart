import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';
import 'package:restaurant_menu_app/features/menu/services/excel_service.dart';
import 'package:restaurant_menu_app/features/settings/services/category_service.dart';
import 'package:restaurant_menu_app/features/settings/models/category.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final ExcelService _excelService;
  final CategoryService _categoryService;

  MenuBloc({ExcelService? excelService, CategoryService? categoryService})
      : _excelService = excelService ?? ExcelService(),
        _categoryService = categoryService ?? CategoryService(),
        super(MenuInitial()) {
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
    print('🔄 LoadMenu EVENT - Before load, _currentItems count: ${_currentItems.length}');
    emit(MenuLoading());
    try {
      // Step 1: Load from Excel
      final items = await _excelService.loadMenuFromExcel();
      print('📥 Loaded ${items.length} items from Excel');
      print('📋 Item IDs from Excel: ${items.map((e) => e.id).take(5).toList()}...');

      _currentItems.clear();
      _currentItems.addAll(items);
      print('✅ _currentItems updated. New count: ${_currentItems.length}');

      _emitLoaded(emit, List.from(_currentItems));
    } catch (e) {
      print('❌ LoadMenu ERROR: $e');
      emit(MenuError('Failed to load menu: $e'));
    }
  }

  void _onFilterByCategory(FilterMenuByCategory event, Emitter<MenuState> emit) {
    if (state is MenuLoaded) {
      _emitLoaded(emit, _currentItems, selectedCategory: event.category);
    }
  }

  Future<void> _onAddMenuItem(AddMenuItem event, Emitter<MenuState> emit) async {
    print('➕ AddMenuItem EVENT - Item ID: ${event.item.id}, Category: ${event.item.category}');
    print('📊 Before add, _currentItems count: ${_currentItems.length}');
    try {
      // Step 1: Save to Excel file first
      await _excelService.addMenuItem(event.item);
      print('✅ Item added to Excel');

      // Step 2: Update in-memory list
      _currentItems.add(event.item);
      print('✅ Item added to _currentItems. New count: ${_currentItems.length}');

      // Step 3: Update UI state
      _emitLoaded(emit, List.from(_currentItems));
    } catch (e) {
      print('❌ AddMenuItem ERROR: $e');
      emit(MenuError('Failed to add item: $e'));
    }
  }

  Future<void> _onUpdateMenuItem(UpdateMenuItem event, Emitter<MenuState> emit) async {
    print('✏️ UpdateMenuItem EVENT - Item ID: ${event.item.id}, New Category: ${event.item.category}');
    print('📊 Before update, _currentItems count: ${_currentItems.length}');
    print('🔍 Searching for item with ID: ${event.item.id}');
    try {
      // Step 1: Update in-memory list
      final index = _currentItems.indexWhere((item) => item.id == event.item.id);
      print('📍 Found item at index: $index');
      if (index != -1) {
        print('🔄 Updating item at index $index');
        print('   Old category: ${_currentItems[index].category}');
        print('   New category: ${event.item.category}');
        _currentItems[index] = event.item;
      } else {
        print('⚠️ Item with ID ${event.item.id} NOT FOUND in _currentItems!');
        print('   Available IDs: ${_currentItems.map((e) => e.id).toList()}');
      }

      // Step 2: Save all items to Excel
      print('💾 Saving ${_currentItems.length} items to Excel...');
      await _excelService.saveAllMenuItems(_currentItems);
      print('✅ All items saved to Excel');

      // Step 3: Update UI state
      _emitLoaded(emit, List.from(_currentItems));
    } catch (e) {
      print('❌ UpdateMenuItem ERROR: $e');
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
    print('📥 ImportFromExcel EVENT started');
    try {
      emit(MenuLoading());

      final data = await _excelService.importFromExcel();

      if (data == null) {
        print('⚠️ Import cancelled or no data');
        emit(MenuError('Import cancelled or failed'));
        return;
      }

      final items = data['items'] as List<MenuItem>;
      final categories = (data['categories'] as List).cast<Category>();
      print('📊 Imported ${items.length} items and ${categories.length} categories');

      // Save imported categories to SharedPreferences
      if (categories.isNotEmpty) {
        print('💾 Saving ${categories.length} categories...');
        await _categoryService.importCategories(categories);
        print('✅ Categories saved successfully');
      }

      // Save imported items to local Excel
      print('💾 Saving ${items.length} items to Excel...');
      await _excelService.saveAllMenuItems(items);
      print('✅ Items saved successfully');

      // Update in-memory list
      _currentItems.clear();
      _currentItems.addAll(items);

      // Emit success state with categories for UI to handle
      emit(MenuImportSuccess(items, categories));

      // Then emit loaded state
      _emitLoaded(emit, List.from(_currentItems));
      print('✅ Import completed successfully');
    } catch (e) {
      print('❌ Import ERROR: $e');
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
