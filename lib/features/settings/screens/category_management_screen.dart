import 'package:flutter/material.dart';
import 'package:restaurant_menu_app/core/localization/app_localizations.dart';
import 'package:restaurant_menu_app/features/settings/services/category_service.dart';
import 'package:restaurant_menu_app/features/settings/models/category.dart';
import 'package:restaurant_menu_app/features/language/bloc/language_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _categoryService = CategoryService();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final categories = await _categoryService.getCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  void _showAddCategoryDialog() {
    final enController = TextEditingController();
    final ruController = TextEditingController();
    final tkController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.translate('add_category'), style: const TextStyle(fontFamily: 'Gilroy', fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // English
                    TextFormField(
                      controller: enController,
                      decoration: InputDecoration(
                        labelText: '🇬🇧 English',
                        labelStyle: const TextStyle(fontFamily: 'Gilroy'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.language),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required field';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Russian
                    TextFormField(
                      controller: ruController,
                      decoration: InputDecoration(
                        labelText: '🇷🇺 Русский',
                        labelStyle: const TextStyle(fontFamily: 'Gilroy'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.language),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Обязательное поле';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Turkmen
                    TextFormField(
                      controller: tkController,
                      decoration: InputDecoration(
                        labelText: '🇹🇲 Türkmen',
                        labelStyle: const TextStyle(fontFamily: 'Gilroy'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.language),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Hökmany meýdan';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.translate('cancel'), style: const TextStyle(fontFamily: 'Gilroy'))),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final success = await _categoryService.addCategory(nameEn: enController.text.trim(), nameRu: ruController.text.trim(), nameTk: tkController.text.trim());

                              if (!context.mounted) return;

                              Navigator.pop(context);

                              if (success) {
                                _loadCategories();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate('category_added')), backgroundColor: Colors.green));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate('category_exists')), backgroundColor: Colors.red));
                              }
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.translate('add'), style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    final enController = TextEditingController(text: category.nameEn);
    final ruController = TextEditingController(text: category.nameRu);
    final tkController = TextEditingController(text: category.nameTk);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit, color: Theme.of(context).primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.translate('edit_category'), style: const TextStyle(fontFamily: 'Gilroy', fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // English
                    TextFormField(
                      controller: enController,
                      decoration: InputDecoration(
                        labelText: '🇬🇧 English',
                        labelStyle: const TextStyle(fontFamily: 'Gilroy'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.language),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required field';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Russian
                    TextFormField(
                      controller: ruController,
                      decoration: InputDecoration(
                        labelText: '🇷🇺 Русский',
                        labelStyle: const TextStyle(fontFamily: 'Gilroy'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.language),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Обязательное поле';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Turkmen
                    TextFormField(
                      controller: tkController,
                      decoration: InputDecoration(
                        labelText: '🇹🇲 Türkmen',
                        labelStyle: const TextStyle(fontFamily: 'Gilroy'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.language),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Hökmany meýdan';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.translate('cancel'), style: const TextStyle(fontFamily: 'Gilroy'))),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final success = await _categoryService.updateCategory(
                                id: category.id,
                                nameEn: enController.text.trim(),
                                nameRu: ruController.text.trim(),
                                nameTk: tkController.text.trim(),
                              );

                              if (!context.mounted) return;

                              Navigator.pop(context);

                              if (success) {
                                _loadCategories();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate('category_updated')), backgroundColor: Colors.green));
                              }
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.translate('save'), style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _confirmDelete(Category category) {
    final currentLang = context.read<LanguageBloc>().state.locale.languageCode;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
            title: Text(AppLocalizations.of(context)!.translate('delete_category'), style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.translate('delete_category_confirm'), style: const TextStyle(fontFamily: 'Gilroy'), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.withOpacity(0.3))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.category, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(category.getName(currentLang), style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.translate('cancel'), style: const TextStyle(fontFamily: 'Gilroy'))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await _categoryService.deleteCategory(category.id);

                  if (!context.mounted) return;

                  Navigator.pop(context);
                  _loadCategories();

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate('category_deleted')), backgroundColor: Colors.orange));
                },
                child: Text(AppLocalizations.of(context)!.translate('delete'), style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.bold)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = context.watch<LanguageBloc>().state.locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.translate('category_management')), backgroundColor: Theme.of(context).scaffoldBackgroundColor),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _categories.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
                    const SizedBox(height: 24),
                    Text(AppLocalizations.of(context)!.translate('no_categories'), style: const TextStyle(fontFamily: 'Gilroy', fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('Tap + to add your first category', style: TextStyle(fontFamily: 'Gilroy', fontSize: 14, color: Colors.grey.withOpacity(0.7))),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.category, color: Theme.of(context).primaryColor),
                      ),
                      title: Text(category.getName(currentLang), style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w700, fontSize: 16)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '🇬🇧 ${category.nameEn}  •  🇷🇺 ${category.nameRu}  •  🇹🇲 ${category.nameTk}',
                          style: TextStyle(fontFamily: 'Gilroy', fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor), onPressed: () => _showEditCategoryDialog(category), tooltip: 'Edit'),
                          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _confirmDelete(category), tooltip: 'Delete'),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.translate('add_category'), style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
      ),
    );
  }
}
