import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:restaurant_menu_app/core/localization/app_localizations.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_bloc.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_state.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_event.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';
import 'package:restaurant_menu_app/features/menu/screens/add_product_screen.dart';
import 'package:restaurant_menu_app/features/language/bloc/language_bloc.dart';
import 'package:restaurant_menu_app/features/settings/services/category_service.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  final CategoryService _categoryService = CategoryService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isBase64(String path) => path.startsWith('data:image');
  bool _isLocalFile(String path) => path.startsWith('/') || path.startsWith('file://');

  List<MenuItem> _filterItems(List<MenuItem> items, String currentLang) {
    return items.where((item) {
      // Filter by category
      final categoryMatch = _selectedCategory == 'all' || item.category == _selectedCategory;

      // Filter by search query
      final searchQuery = _searchController.text.toLowerCase();
      final nameMatch = item.getName(currentLang).toLowerCase().contains(searchQuery);
      final categoryNameMatch = item.category.toLowerCase().contains(searchQuery);

      return categoryMatch && (nameMatch || categoryNameMatch);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = context.watch<LanguageBloc>().state.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('product_management')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())).then((_) => context.read<MenuBloc>().add(LoadMenu()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.translate('search_products'),
                    hintStyle: const TextStyle(fontFamily: 'Gilroy', color: Colors.grey),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                            : null,
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(fontFamily: 'Gilroy'),
                ),
                const SizedBox(height: 12),

                // Category Filter
                FutureBuilder<List<String>>(
                  future: _categoryService.getCategoryNames(currentLang),
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? [];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        dropdownColor: Colors.grey[900],
                        style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white, fontSize: 14),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: [
                          DropdownMenuItem(value: 'all', child: Text(AppLocalizations.of(context)!.translate('all_categories'))),
                          ...categories.map((category) => DropdownMenuItem(value: category, child: Text(category))),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value ?? 'all';
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: BlocBuilder<MenuBloc, MenuState>(
              builder: (context, state) {
                if (state is MenuLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MenuError) {
                  return Center(child: Text(state.message));
                } else if (state is MenuLoaded) {
                  final allItems = state.allItemsIncludingUnavailable;
                  final filteredItems = _filterItems(allItems, currentLang);

                  if (allItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.translate('no_products'), style: const TextStyle(fontFamily: 'Gilroy', fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  if (filteredItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.translate('no_results'), style: const TextStyle(fontFamily: 'Gilroy', fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildProductCard(context, item);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, MenuItem item) {
    final currentLang = context.watch<LanguageBloc>().state.locale.languageCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(width: 80, height: 80, child: _buildImage(item.imageUrl))),
            const SizedBox(width: 16),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.getName(currentLang), style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w700, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(item.category, style: TextStyle(fontFamily: 'Gilroy', color: Theme.of(context).primaryColor, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${item.price} TMT', style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),

            // Actions
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit Button
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductScreen(itemToEdit: item))).then((_) => context.read<MenuBloc>().add(LoadMenu()));
                  },
                ),

                // Delete Button
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteConfirmDialog(context, item)),

                // Toggle Availability
                Switch(
                  value: item.available,
                  onChanged: (value) {
                    final updatedItem = MenuItem(
                      id: item.id,
                      nameEn: item.nameEn,
                      nameRu: item.nameRu,
                      nameTk: item.nameTk,
                      descriptionEn: item.descriptionEn,
                      descriptionRu: item.descriptionRu,
                      descriptionTk: item.descriptionTk,
                      price: item.price,
                      imageUrl: item.imageUrl,
                      category: item.category,
                      available: value,
                    );
                    context.read<MenuBloc>().add(UpdateMenuItem(updatedItem));
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (_isBase64(imageUrl)) {
      try {
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(bytes, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder());
      } catch (e) {
        return _buildPlaceholder();
      }
    } else if (_isLocalFile(imageUrl)) {
      return Image.file(File(imageUrl), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder());
    } else {
      return CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, placeholder: (_, __) => _buildPlaceholder(), errorWidget: (_, __, ___) => _buildPlaceholder());
    }
  }

  Widget _buildPlaceholder() {
    return Container(color: Colors.grey[800], child: const Icon(Icons.restaurant, color: Colors.grey, size: 40));
  }

  void _showDeleteConfirmDialog(BuildContext context, MenuItem item) {
    final currentLang = context.read<LanguageBloc>().state.locale.languageCode;
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.translate('delete_product')),
            content: Text('${AppLocalizations.of(context)!.translate('delete_confirm')} "${item.getName(currentLang)}"?', style: const TextStyle(fontFamily: 'Gilroy')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(AppLocalizations.of(context)!.translate('cancel'))),
              TextButton(
                onPressed: () {
                  context.read<MenuBloc>().add(DeleteMenuItem(item.id));
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate('product_deleted'), style: const TextStyle(fontFamily: 'Gilroy')), backgroundColor: Colors.green));
                },
                child: Text(AppLocalizations.of(context)!.translate('delete'), style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
