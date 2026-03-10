import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';
import 'package:restaurant_menu_app/features/settings/models/category.dart';

class ExcelService {
  static const String _fileName = 'menu.xlsx';
  static const String _sheetName = 'Menu';
  static const String _categoriesSheetName = 'Categories';

  Future<String> getExcelFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_fileName';
  }

  Future<void> _createExcelFile(String path) async {
    final excel = Excel.createExcel();
    final sheet = excel[_sheetName];

    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Category'),
      TextCellValue('NameRu'),
      TextCellValue('NameTk'),
      TextCellValue('Price'),
      TextCellValue('Image URL'),
      TextCellValue('Available'),
    ]);

    final bytes = excel.save();
    if (bytes == null) return;

    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  Future<void> addMenuItem(MenuItem item) async {
    final path = await getExcelFilePath();
    final file = File(path);

    if (!await file.exists()) {
      await _createExcelFile(path);
    }

    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    Sheet? sheet = excel.tables[_sheetName];
    sheet ??= excel.tables[excel.tables.keys.first];

    if (sheet == null) {
      throw Exception('No sheet found in Excel file');
    }

    sheet.appendRow([
      TextCellValue(item.id),
      TextCellValue(item.category),
      TextCellValue(item.nameRu),
      TextCellValue(item.nameTk),
      TextCellValue(item.price.toString()),
      TextCellValue(item.imageUrl),
      TextCellValue(item.available ? 'TRUE' : 'FALSE'),
    ]);

    final newBytes = excel.save();
    if (newBytes != null) {
      await file.writeAsBytes(newBytes, flush: true);
    }
  }

  Future<void> saveAllMenuItems(List<MenuItem> items) async {
    final path = await getExcelFilePath();
    final excel = Excel.createExcel();
    final sheet = excel[_sheetName];

    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Category'),
      TextCellValue('NameRu'),
      TextCellValue('NameTk'),
      TextCellValue('Price'),
      TextCellValue('Image URL'),
      TextCellValue('Available'),
    ]);

    for (final item in items) {
      sheet.appendRow([
        TextCellValue(item.id),
        TextCellValue(item.category),
        TextCellValue(item.nameRu),
        TextCellValue(item.nameTk),
        TextCellValue(item.price.toString()),
        TextCellValue(item.imageUrl),
        TextCellValue(item.available ? 'TRUE' : 'FALSE'),
      ]);
    }

    final bytes = excel.save();
    if (bytes == null) return;

    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  Future<List<MenuItem>> loadMenuFromExcel() async {
    final path = await getExcelFilePath();
    final file = File(path);

    if (!await file.exists()) {
      return [];
    }

    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      Sheet? sheet = excel.tables[_sheetName];
      sheet ??= excel.tables[excel.tables.keys.first];
      if (sheet == null) return [];

      final items = <MenuItem>[];

      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        if (row.isEmpty) continue;

        try {
          // New format: ID,Category,NameRu,NameTk,Price,ImageURL,Available
          // Old format: ID,Category,NameEn,NameRu,NameTk,DescEn,DescRu,DescTk,Price,ImageURL,Available
          final isOldFormat = row.length > 10;

          final id = row[0]?.value.toString() ?? '';
          final category = row[1]?.value.toString() ?? '';

          final nameRu = isOldFormat ? (row[3]?.value.toString() ?? '') : (row[2]?.value.toString() ?? '');
          final nameTk = isOldFormat ? (row[4]?.value.toString() ?? '') : (row[3]?.value.toString() ?? '');
          final priceString = isOldFormat ? (row[8]?.value.toString() ?? '0.0') : (row[4]?.value.toString() ?? '0.0');
          final imageUrl = isOldFormat ? (row[9]?.value.toString() ?? '') : (row[5]?.value.toString() ?? '');
          final availableString = (isOldFormat ? row[10]?.value.toString() : row[6]?.value.toString())?.toUpperCase() ?? 'TRUE';

          if (nameRu.isEmpty) continue;

          items.add(
            MenuItem(
              id: id.isEmpty ? i.toString() : id,
              category: category,
              nameRu: nameRu,
              nameTk: nameTk,
              price: double.tryParse(priceString) ?? 0.0,
              imageUrl: imageUrl,
              available: availableString == 'TRUE',
            ),
          );
        } catch (_) {
          // Ignore row-level parse errors for resilience.
        }
      }

      return items;
    } catch (_) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      return [];
    }
  }

  Future<String?> exportToExcel(List<MenuItem> items, List<Category> categories) async {
    try {
      final excel = Excel.createExcel();

      final menuSheet = excel[_sheetName];
      menuSheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Category'),
        TextCellValue('NameRu'),
        TextCellValue('NameTk'),
        TextCellValue('Price'),
        TextCellValue('Image URL'),
        TextCellValue('Available'),
      ]);

      for (final item in items) {
        menuSheet.appendRow([
          TextCellValue(item.id),
          TextCellValue(item.category),
          TextCellValue(item.nameRu),
          TextCellValue(item.nameTk),
          TextCellValue(item.price.toString()),
          TextCellValue(item.imageUrl),
          TextCellValue(item.available ? 'TRUE' : 'FALSE'),
        ]);
      }

      final categoriesSheet = excel[_categoriesSheetName];
      categoriesSheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('NameRu'),
        TextCellValue('NameTk'),
        TextCellValue('SortOrder'),
      ]);

      for (final category in categories) {
        categoriesSheet.appendRow([
          TextCellValue(category.id),
          TextCellValue(category.nameRu),
          TextCellValue(category.nameTk),
          TextCellValue(category.sortOrder.toString()),
        ]);
      }

      final bytes = excel.save();
      if (bytes == null) return null;

      Directory? directory;
      if (Platform.isAndroid || Platform.isIOS) {
        directory = await getExternalStorageDirectory();
      }
      directory ??= await getApplicationDocumentsDirectory();

      final fileName = 'restaurant_menu_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final outputPath = '${directory.path}/$fileName';

      final file = File(outputPath);
      await file.writeAsBytes(bytes);
      return outputPath;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> importFromExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null || result.files.single.path == null) return null;

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      final items = <MenuItem>[];
      final menuSheet = excel.tables[_sheetName];

      if (menuSheet != null) {
        for (int i = 1; i < menuSheet.maxRows; i++) {
          final row = menuSheet.row(i);
          if (row.isEmpty) continue;

          try {
            final hasIdColumn = row.length > 6;
            final hasOldColumns = row.length > 10;

            final id = hasIdColumn ? (row[0]?.value.toString() ?? '') : '';
            final categoryIndex = hasIdColumn ? 1 : 0;

            final category = row[categoryIndex]?.value.toString() ?? '';
            final nameRu = hasOldColumns ? (row[categoryIndex + 2]?.value.toString() ?? '') : (row[categoryIndex + 1]?.value.toString() ?? '');
            final nameTk = hasOldColumns ? (row[categoryIndex + 3]?.value.toString() ?? '') : (row[categoryIndex + 2]?.value.toString() ?? '');
            final priceString = hasOldColumns ? (row[categoryIndex + 7]?.value.toString() ?? '0.0') : (row[categoryIndex + 3]?.value.toString() ?? '0.0');
            final imageUrl = hasOldColumns ? (row[categoryIndex + 8]?.value.toString() ?? '') : (row[categoryIndex + 4]?.value.toString() ?? '');
            final availableString = (hasOldColumns ? row[categoryIndex + 9]?.value.toString() : row[categoryIndex + 5]?.value.toString())?.toUpperCase() ?? 'TRUE';

            if (nameRu.isEmpty) continue;

            items.add(
              MenuItem(
                id: id.isEmpty ? '${DateTime.now().millisecondsSinceEpoch}$i' : id,
                category: category,
                nameRu: nameRu,
                nameTk: nameTk,
                price: double.tryParse(priceString) ?? 0.0,
                imageUrl: imageUrl,
                available: availableString == 'TRUE',
              ),
            );
          } catch (_) {}
        }
      }

      final categories = <Category>[];
      final categoriesSheet = excel.tables[_categoriesSheetName];

      if (categoriesSheet != null) {
        for (int i = 1; i < categoriesSheet.maxRows; i++) {
          final row = categoriesSheet.row(i);
          if (row.isEmpty) continue;

          try {
            final id = row[0]?.value.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
            final oldFormat = row.length > 4;
            final nameRu = oldFormat ? (row[2]?.value.toString() ?? '') : (row[1]?.value.toString() ?? '');
            final nameTk = oldFormat ? (row[3]?.value.toString() ?? '') : (row[2]?.value.toString() ?? '');
            final sortOrderStr = oldFormat ? row[4]?.value.toString() : row[3]?.value.toString();
            final sortOrder = int.tryParse(sortOrderStr ?? '') ?? i;

            if (nameRu.isEmpty) continue;
            categories.add(Category(id: id, nameRu: nameRu, nameTk: nameTk, sortOrder: sortOrder));
          } catch (_) {}
        }
      }

      return {'items': items, 'categories': categories};
    } catch (_) {
      return null;
    }
  }
}
