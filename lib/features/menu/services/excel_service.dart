import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';
import 'package:restaurant_menu_app/features/settings/models/category.dart';

/// Service for handling Excel file operations
///
/// Uses app-specific directory which doesn't require special storage permissions.
///
/// Logical Flow:
/// 1. Get the Excel file path (app documents directory)
/// 2. If file doesn't exist, create it with headers
/// 3. If file exists, load it
/// 4. Add new menu item as a row
/// 5. Save the file back
class ExcelService {
  static const String _fileName = 'menu.xlsx';
  static const String _sheetName = 'Menu';
  static const String _categoriesSheetName = 'Categories';

  /// Get the path where Excel file will be stored
  /// Uses app-specific directory (no special permissions needed)
  Future<String> getExcelFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_fileName';
  }

  /// Create a new Excel file with headers
  Future<void> _createExcelFile(String path) async {
    final excel = Excel.createExcel();
    final sheet = excel[_sheetName];

    // Add header row with multilang support
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Category'),
      TextCellValue('NameEn'),
      TextCellValue('NameRu'),
      TextCellValue('NameTk'),
      TextCellValue('DescriptionEn'),
      TextCellValue('DescriptionRu'),
      TextCellValue('DescriptionTk'),
      TextCellValue('Price'),
      TextCellValue('Image URL'),
      TextCellValue('Available'),
    ]);

    // Save the file
    final bytes = excel.save();
    if (bytes != null) {
      final file = File(path);
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
    }
  }

  /// Add a menu item to the Excel file
  ///
  /// Logic:
  /// 1. Get file path
  /// 2. Check if file exists, create if not
  /// 3. Load Excel file
  /// 4. Append new row with menu item data
  /// 5. Save file
  Future<void> addMenuItem(MenuItem item) async {
    // Step 1: Get file path
    final path = await getExcelFilePath();
    final file = File(path);

    // Step 2: Create file if it doesn't exist
    if (!await file.exists()) {
      await _createExcelFile(path);
    }

    // Step 3: Load Excel file
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    // Get the Menu sheet (or first sheet if Menu doesn't exist)
    Sheet? sheet = excel.tables[_sheetName];
    sheet ??= excel.tables[excel.tables.keys.first];

    if (sheet == null) {
      throw Exception('No sheet found in Excel file');
    }

    // Step 4: Append new row with multilang support
    sheet.appendRow([
      TextCellValue(item.id),
      TextCellValue(item.category),
      TextCellValue(item.nameEn),
      TextCellValue(item.nameRu),
      TextCellValue(item.nameTk),
      TextCellValue(item.descriptionEn),
      TextCellValue(item.descriptionRu),
      TextCellValue(item.descriptionTk),
      TextCellValue(item.price.toString()),
      TextCellValue(item.imageUrl),
      TextCellValue(item.available ? 'TRUE' : 'FALSE'),
    ]);

    // Step 5: Save file
    final newBytes = excel.save();
    if (newBytes != null) {
      await file.writeAsBytes(newBytes, flush: true);
    }
  }

  /// Save all menu items to Excel (overwrites existing file)
  Future<void> saveAllMenuItems(List<MenuItem> items) async {
    print('💾 saveAllMenuItems called with ${items.length} items');
    print('🏷️  First 3 item IDs: ${items.take(3).map((e) => e.id).toList()}');
    final path = await getExcelFilePath();
    print('📁 Excel path: $path');
    final excel = Excel.createExcel();
    final sheet = excel[_sheetName];

    // Add header row with multilang support (including ID)
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Category'),
      TextCellValue('NameEn'),
      TextCellValue('NameRu'),
      TextCellValue('NameTk'),
      TextCellValue('DescriptionEn'),
      TextCellValue('DescriptionRu'),
      TextCellValue('DescriptionTk'),
      TextCellValue('Price'),
      TextCellValue('Image URL'),
      TextCellValue('Available'),
    ]);

    // Add all items (including ID)
    for (final item in items) {
      sheet.appendRow([
        TextCellValue(item.id),
        TextCellValue(item.category),
        TextCellValue(item.nameEn),
        TextCellValue(item.nameRu),
        TextCellValue(item.nameTk),
        TextCellValue(item.descriptionEn),
        TextCellValue(item.descriptionRu),
        TextCellValue(item.descriptionTk),
        TextCellValue(item.price.toString()),
        TextCellValue(item.imageUrl),
        TextCellValue(item.available ? 'TRUE' : 'FALSE'),
      ]);
    }

    // Save file
    final bytes = excel.save();
    if (bytes != null) {
      final file = File(path);
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      print('✅ saveAllMenuItems completed. File size: ${bytes.length} bytes');
    } else {
      print('❌ saveAllMenuItems FAILED - bytes is null');
    }
  }

  /// Load all menu items from the Excel file
  ///
  /// Logic:
  /// 1. Get file path
  /// 2. If file doesn't exist, return empty list
  /// 3. Load Excel file
  /// 4. Parse each row (skipping header) into MenuItem
  Future<List<MenuItem>> loadMenuFromExcel() async {
    print('📥 loadMenuFromExcel called');
    // Step 1: Get file path
    final path = await getExcelFilePath();
    print('📁 Excel path: $path');
    final file = File(path);

    // Step 2: Check if file exists
    if (!await file.exists()) {
      print('⚠️ Excel file does not exist');
      return [];
    }

    // Step 3: Load Excel file
    // The loading logic is now wrapped in the try-catch block below to handle corruption.

    try {
      // Step 3: Load Excel file
      final bytes = await file.readAsBytes();
      print('📊 File size: ${bytes.length} bytes');
      final excel = Excel.decodeBytes(bytes);

      Sheet? sheet = excel.tables[_sheetName];
      sheet ??= excel.tables[excel.tables.keys.first];

      if (sheet == null) {
        print('⚠️ No sheet found in Excel file');
        return [];
      }

      print('📋 Sheet has ${sheet.maxRows} rows');
      final List<MenuItem> items = [];

      // Step 4: Parse rows (skip header row at index 0)
      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        if (row.isEmpty) continue;

        try {
          // Expected columns: ID, Category, NameEn, NameRu, NameTk, DescEn, DescRu, DescTk, Price, ImageURL, Available
          final id = row[0]?.value.toString() ?? '';
          final category = row[1]?.value.toString() ?? '';
          final nameEn = row[2]?.value.toString() ?? '';
          final nameRu = row[3]?.value.toString() ?? '';
          final nameTk = row[4]?.value.toString() ?? '';
          final descriptionEn = row[5]?.value.toString() ?? '';
          final descriptionRu = row[6]?.value.toString() ?? '';
          final descriptionTk = row[7]?.value.toString() ?? '';
          final priceString = row[8]?.value.toString() ?? '0.0';
          final imageUrl = row[9]?.value.toString() ?? '';
          final availableString = row[10]?.value.toString().toUpperCase() ?? 'TRUE';

          if (nameEn.isEmpty) continue;

          items.add(
            MenuItem(
              id: id.isEmpty ? i.toString() : id, // Use row index as fallback for old data
              category: category,
              nameEn: nameEn,
              nameRu: nameRu,
              nameTk: nameTk,
              descriptionEn: descriptionEn,
              descriptionRu: descriptionRu,
              descriptionTk: descriptionTk,
              price: double.tryParse(priceString) ?? 0.0,
              imageUrl: imageUrl,
              available: availableString == 'TRUE',
            ),
          );
        } catch (e) {
          // Silent error for safe loading of individual rows
          print('⚠️ Error parsing row $i: $e');
        }
      }

      print('✅ Loaded ${items.length} items successfully');
      return items;
    } catch (e) {
      // Catch corruption errors (like numFmtId)
      print('❌ Error loading Excel file: $e. Recreating file...');
      try {
        if (await file.exists()) {
          await file.delete();
          print('🗑️ Corrupted file deleted');
        }
      } catch (deleteError) {
        print('❌ Failed to delete corrupted file: $deleteError');
      }
      return []; // Return empty so default items are used
    }
  }

  /// Export all data (menu items and categories) to app storage
  /// Returns the file path if successful, null otherwise
  Future<String?> exportToExcel(List<MenuItem> items, List<Category> categories) async {
    try {
      // Create Excel file
      final excel = Excel.createExcel();

      // Create Menu sheet
      final menuSheet = excel[_sheetName];
      menuSheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Category'),
        TextCellValue('NameEn'),
        TextCellValue('NameRu'),
        TextCellValue('NameTk'),
        TextCellValue('DescriptionEn'),
        TextCellValue('DescriptionRu'),
        TextCellValue('DescriptionTk'),
        TextCellValue('Price'),
        TextCellValue('Image URL'),
        TextCellValue('Available'),
      ]);

      for (final item in items) {
        menuSheet.appendRow([
          TextCellValue(item.id),
          TextCellValue(item.category),
          TextCellValue(item.nameEn),
          TextCellValue(item.nameRu),
          TextCellValue(item.nameTk),
          TextCellValue(item.descriptionEn),
          TextCellValue(item.descriptionRu),
          TextCellValue(item.descriptionTk),
          TextCellValue(item.price.toString()),
          TextCellValue(item.imageUrl), // Base64 images included
          TextCellValue(item.available ? 'TRUE' : 'FALSE'),
        ]);
      }

      // Create Categories sheet
      final categoriesSheet = excel[_categoriesSheetName];
      categoriesSheet.appendRow([TextCellValue('ID'), TextCellValue('NameEn'), TextCellValue('NameRu'), TextCellValue('NameTk'), TextCellValue('SortOrder')]);

      for (final category in categories) {
        categoriesSheet
            .appendRow([TextCellValue(category.id), TextCellValue(category.nameEn), TextCellValue(category.nameRu), TextCellValue(category.nameTk), TextCellValue(category.sortOrder.toString())]);
      }

      // Save to app-accessible directory (no permissions required)
      final bytes = excel.save();
      if (bytes == null) return null;

      Directory? directory;

      if (Platform.isAndroid || Platform.isIOS) {
        // Use external storage directory - doesn't require permissions
        // Path: /storage/emulated/0/Android/data/[package]/files/
        directory = await getExternalStorageDirectory();
      }

      if (directory == null) {
        // Fallback to app documents directory
        directory = await getApplicationDocumentsDirectory();
      }

      final fileName = 'restaurant_menu_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final outputPath = '${directory.path}/$fileName';

      final file = File(outputPath);
      await file.writeAsBytes(bytes);

      print('Excel exported to: $outputPath');
      return outputPath;
    } catch (e) {
      print('Export error: $e');
      return null;
    }
  }

  /// Import data from Excel file
  /// Returns a map with 'items' and 'categories' keys
  Future<Map<String, dynamic>?> importFromExcel() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);

      if (result == null || result.files.single.path == null) {
        return null;
      }

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      // Parse Menu sheet
      final List<MenuItem> items = [];
      final menuSheet = excel.tables[_sheetName];

      if (menuSheet != null) {
        for (int i = 1; i < menuSheet.maxRows; i++) {
          final row = menuSheet.row(i);
          if (row.isEmpty) continue;

          try {
            // Check if file has ID column (new format) or not (old format)
            // If first column looks like a category name, it's old format
            final hasIdColumn = row.length > 10; // New format has 11 columns

            final id = hasIdColumn ? (row[0]?.value.toString() ?? '') : '';
            final categoryIndex = hasIdColumn ? 1 : 0;

            final category = row[categoryIndex]?.value.toString() ?? '';
            final nameEn = row[categoryIndex + 1]?.value.toString() ?? '';
            final nameRu = row[categoryIndex + 2]?.value.toString() ?? '';
            final nameTk = row[categoryIndex + 3]?.value.toString() ?? '';
            final descriptionEn = row[categoryIndex + 4]?.value.toString() ?? '';
            final descriptionRu = row[categoryIndex + 5]?.value.toString() ?? '';
            final descriptionTk = row[categoryIndex + 6]?.value.toString() ?? '';
            final priceString = row[categoryIndex + 7]?.value.toString() ?? '0.0';
            final imageUrl = row[categoryIndex + 8]?.value.toString() ?? ''; // Base64 images preserved
            final availableString = row[categoryIndex + 9]?.value.toString().toUpperCase() ?? 'TRUE';

            if (nameEn.isEmpty) continue;

            items.add(
              MenuItem(
                id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() + i.toString() : id,
                category: category,
                nameEn: nameEn,
                nameRu: nameRu,
                nameTk: nameTk,
                descriptionEn: descriptionEn,
                descriptionRu: descriptionRu,
                descriptionTk: descriptionTk,
                price: double.tryParse(priceString) ?? 0.0,
                imageUrl: imageUrl,
                available: availableString == 'TRUE',
              ),
            );
          } catch (e) {
            print('Error parsing menu row $i: $e');
          }
        }
      }

      // Parse Categories sheet
      final List<Category> categories = [];
      final categoriesSheet = excel.tables[_categoriesSheetName];

      if (categoriesSheet != null) {
        for (int i = 1; i < categoriesSheet.maxRows; i++) {
          final row = categoriesSheet.row(i);
          if (row.isEmpty) continue;

          try {
            final id = row[0]?.value.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
            final nameEn = row[1]?.value.toString() ?? '';
            final nameRu = row[2]?.value.toString() ?? '';
            final nameTk = row[3]?.value.toString() ?? '';
            final sortOrderStr = row.length > 4 ? row[4]?.value.toString() : null;
            final sortOrder = sortOrderStr != null ? (int.tryParse(sortOrderStr) ?? i) : i;

            if (nameEn.isEmpty) continue;

            categories.add(Category(id: id, nameEn: nameEn, nameRu: nameRu, nameTk: nameTk, sortOrder: sortOrder));
          } catch (e) {
            print('Error parsing category row $i: $e');
          }
        }
      }

      return {'items': items, 'categories': categories};
    } catch (e) {
      print('Import error: $e');
      return null;
    }
  }
}
