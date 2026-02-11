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
      return decoded.map((json) => Category.fromJson(json)).toList();
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
  Future<bool> addCategory({required String nameEn, required String nameRu, required String nameTk}) async {
    if (nameEn.trim().isEmpty || nameRu.trim().isEmpty || nameTk.trim().isEmpty) {
      return false;
    }

    final categories = await getCategories();

    // Check if category with same English name exists
    if (categories.any((cat) => cat.nameEn.toLowerCase() == nameEn.trim().toLowerCase())) {
      return false;
    }

    final newCategory = Category(id: DateTime.now().millisecondsSinceEpoch.toString(), nameEn: nameEn.trim(), nameRu: nameRu.trim(), nameTk: nameTk.trim());

    categories.add(newCategory);
    return await _saveCategories(categories);
  }

  /// Update category
  Future<bool> updateCategory({required String id, required String nameEn, required String nameRu, required String nameTk}) async {
    if (nameEn.trim().isEmpty || nameRu.trim().isEmpty || nameTk.trim().isEmpty) {
      return false;
    }

    final categories = await getCategories();
    final index = categories.indexWhere((cat) => cat.id == id);

    if (index == -1) return false;

    categories[index] = Category(id: id, nameEn: nameEn.trim(), nameRu: nameRu.trim(), nameTk: nameTk.trim());

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
}
