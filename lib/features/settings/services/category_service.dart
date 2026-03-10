import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:restaurant_menu_app/features/settings/models/category.dart';

class CategoryService {
  static const String _categoriesKey = 'custom_categories';

  /// Get all categories
  Future<List<Category>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString(_categoriesKey);

    if (categoriesJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(categoriesJson);
      final categories = decoded.map((json) => Category.fromJson(json)).toList();
      // Sort by sortOrder
      categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return categories;
    } catch (e) {
      return [];
    }
  }

  /// Get category names for specific language
  Future<List<String>> getCategoryNames(String languageCode) async {
    final categories = await getCategories();
    return categories.map((cat) => cat.getName(languageCode)).toList();
  }

  /// Add a new category
  Future<bool> addCategory({required String nameRu, required String nameTk, int? sortOrder}) async {
    if (nameRu.trim().isEmpty || nameTk.trim().isEmpty) {
      return false;
    }

    final categories = await getCategories();

    // Check if category with same Russian name exists
    if (categories.any((cat) => cat.nameRu.toLowerCase() == nameRu.trim().toLowerCase())) {
      return false;
    }

    // Auto-assign sortOrder if not provided (put at the end)
    final order = sortOrder ?? (categories.isEmpty ? 0 : categories.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1);

    final newCategory = Category(id: DateTime.now().millisecondsSinceEpoch.toString(), nameRu: nameRu.trim(), nameTk: nameTk.trim(), sortOrder: order);

    categories.add(newCategory);
    return await _saveCategories(categories);
  }

  /// Update category
  Future<bool> updateCategory({required String id, required String nameRu, required String nameTk, int? sortOrder}) async {
    if (nameRu.trim().isEmpty || nameTk.trim().isEmpty) {
      return false;
    }

    final categories = await getCategories();
    final index = categories.indexWhere((cat) => cat.id == id);

    if (index == -1) return false;

    categories[index] = Category(id: id, nameRu: nameRu.trim(), nameTk: nameTk.trim(), sortOrder: sortOrder ?? categories[index].sortOrder);

    return await _saveCategories(categories);
  }

  /// Delete a category
  Future<bool> deleteCategory(String id) async {
    final categories = await getCategories();
    categories.removeWhere((cat) => cat.id == id);
    return await _saveCategories(categories);
  }

  /// Get category by ID
  Future<Category?> getCategoryById(String id) async {
    final categories = await getCategories();
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Save categories to SharedPreferences
  Future<bool> _saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = json.encode(categories.map((cat) => cat.toJson()).toList());
    return await prefs.setString(_categoriesKey, categoriesJson);
  }

  /// Import categories (replaces existing categories)
  Future<bool> importCategories(List<Category> categories) async {
    return await _saveCategories(categories);
  }

  /// Clear all categories
  Future<bool> clearCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_categoriesKey);
  }

  /// Reorder categories
  Future<bool> reorderCategories(List<Category> reorderedCategories) async {
    // Update sortOrder based on list position
    for (int i = 0; i < reorderedCategories.length; i++) {
      reorderedCategories[i] = reorderedCategories[i].copyWith(sortOrder: i);
    }
    return await _saveCategories(reorderedCategories);
  }
}
