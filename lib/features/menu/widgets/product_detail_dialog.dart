import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant_menu_app/core/localization/app_localizations.dart';
import 'package:restaurant_menu_app/features/cart/bloc/cart_bloc.dart';
import 'package:restaurant_menu_app/features/cart/bloc/cart_event.dart';
import 'package:restaurant_menu_app/features/language/bloc/language_bloc.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';
import 'package:restaurant_menu_app/features/settings/services/category_service.dart';
import 'package:restaurant_menu_app/features/settings/models/category.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailDialog extends StatefulWidget {
  final MenuItem item;

  const ProductDetailDialog({super.key, required this.item});

  @override
  State<ProductDetailDialog> createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<ProductDetailDialog> {
  final CategoryService _categoryService = CategoryService();
  String? _categoryDisplayName;

  @override
  void initState() {
    super.initState();
    _loadCategoryName();
  }

  Future<void> _loadCategoryName() async {
    try {
      final categories = await _categoryService.getCategories();
      final currentLang = context.read<LanguageBloc>().state.locale.languageCode;

      // Try to find matching category
      Category? matchingCategory;
      for (var cat in categories) {
        if (cat.nameEn == widget.item.category || cat.nameRu == widget.item.category || cat.nameTk == widget.item.category) {
          matchingCategory = cat;
          break;
        }
      }

      if (matchingCategory != null && mounted) {
        setState(() {
          _categoryDisplayName = matchingCategory!.getName(currentLang);
        });
      }
    } catch (e) {
      // If category lookup fails, use the stored category name
    }
  }

  bool _isLocalFile(String path) => path.startsWith('/') || path.startsWith('file://');
  bool _isBase64(String path) => path.startsWith('data:image');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLang = context.watch<LanguageBloc>().state.locale.languageCode;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: isLandscape ? 40 : 20, vertical: isLandscape ? 20 : 40),
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: isLandscape ? 900 : 500, maxHeight: isLandscape ? 600 : MediaQuery.of(context).size.height * 0.7),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 10))],
          ),
          clipBehavior: Clip.antiAlias,
          child: isLandscape ? _buildLandscapeLayout(context, theme, currentLang) : _buildPortraitLayout(context, theme, currentLang),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, ThemeData theme, String currentLang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image section with close button overlay
        SizedBox(
          height: 320,
          child: Stack(
            children: [
              _buildImage(),
              // Close button overlay on image
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.6), padding: const EdgeInsets.all(8)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),

        // Details section (bottom)
        Expanded(child: _buildDetailsSection(context, theme, currentLang)),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, ThemeData theme, String currentLang) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image section (left)
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              _buildImage(),
              // Close button overlay on image
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.6), padding: const EdgeInsets.all(8)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),

        // Details section (right)
        Expanded(flex: 5, child: _buildDetailsSection(context, theme, currentLang)),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context, ThemeData theme, String currentLang) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(widget.item.getName(currentLang), style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 12),

          // Category
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
            ),
            child: Text(_categoryDisplayName ?? widget.item.category, style: TextStyle(fontFamily: 'Gilroy', color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
          ),

          const SizedBox(height: 20),

          // Description
          Expanded(
            child: SingleChildScrollView(
              child: Text(widget.item.getDescription(currentLang), style: TextStyle(fontFamily: 'Gilroy', color: Colors.white.withOpacity(0.85), fontSize: 16, height: 1.6)),
            ),
          ),

          const SizedBox(height: 20),

          // Price
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.translate('price_label'), style: TextStyle(fontFamily: 'Gilroy', color: Colors.white.withOpacity(0.6), fontSize: 15)),
                Text('${widget.item.price} TMT', style: TextStyle(fontFamily: 'Gilroy', color: theme.colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Add to order button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed:
                  widget.item.available
                      ? () {
                        context.read<CartBloc>().add(AddCartItem(widget.item));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: theme.colorScheme.surface,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: theme.colorScheme.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${widget.item.getName(currentLang)} ${AppLocalizations.of(context)!.translate('item_added')}',
                                    style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            action: SnackBarAction(label: AppLocalizations.of(context)!.translate('undo'), textColor: theme.colorScheme.primary, onPressed: () {}),
                          ),
                        );
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.item.available ? theme.colorScheme.primary : Colors.grey,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                widget.item.available ? AppLocalizations.of(context)!.translate('add_to_order') : AppLocalizations.of(context)!.translate('sold_out'),
                style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (widget.item.imageUrl.isEmpty) {
      return Container(color: const Color(0xFF2A2A2A), child: const Center(child: Icon(Icons.restaurant, color: Colors.grey, size: 64)));
    }

    if (_isBase64(widget.item.imageUrl)) {
      try {
        return Image.memory(base64Decode(widget.item.imageUrl.split(',').last), fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (_, __, ___) => _buildErrorWidget());
      } catch (_) {
        return _buildErrorWidget();
      }
    }

    if (_isLocalFile(widget.item.imageUrl)) {
      return Image.file(File(widget.item.imageUrl), fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (_, __, ___) => _buildErrorWidget());
    }

    return CachedNetworkImage(
      imageUrl: widget.item.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Shimmer.fromColors(baseColor: const Color(0xFF1A1A1A), highlightColor: const Color(0xFF2A2A2A), child: Container(color: Colors.white)),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(color: const Color(0xFF2A2A2A), child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 64)));
  }
}
