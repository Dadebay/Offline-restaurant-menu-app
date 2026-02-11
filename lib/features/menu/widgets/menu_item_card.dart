import 'dart:convert';
import 'package:restaurant_menu_app/core/localization/app_localizations.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';
import 'package:restaurant_menu_app/features/cart/bloc/cart_bloc.dart';
import 'package:restaurant_menu_app/features/cart/bloc/cart_event.dart';
import 'package:shimmer/shimmer.dart';
import 'package:restaurant_menu_app/features/language/bloc/language_bloc.dart';
import 'package:restaurant_menu_app/features/menu/widgets/product_detail_dialog.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;

  const MenuItemCard({super.key, required this.item});

  bool _isLocalFile(String path) => path.startsWith('/') || path.startsWith('file://');
  bool _isBase64(String path) => path.startsWith('data:image');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLang = context.watch<LanguageBloc>().state.locale.languageCode;

    return GestureDetector(
      onTap: () {
        showDialog(context: context, builder: (context) => ProductDetailDialog(item: item));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Darker card background
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Image Section (Top ~60%)
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(),

                  // Price Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
                      child: Text('${item.price} TMT', style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),

                  // Sold Out Overlay
                  if (!item.available)
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context)!.translate('sold_out'),
                        style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Content Section (Bottom)
            Expanded(
              flex: 5, // Give more space to content (was 4)
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Section (Takes available space)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.getName(currentLang),
                            style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Flexible(
                            child: Text(
                              item.getDescription(currentLang),
                              style: TextStyle(fontFamily: 'Gilroy', color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.4),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Add Button (Fixed at bottom)
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed:
                            item.available
                                ? () {
                                  context.read<CartBloc>().add(AddCartItem(item));
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   SnackBar(
                                  //     backgroundColor: theme.colorScheme.surface,
                                  //     behavior: SnackBarBehavior.floating,
                                  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  //     content: Row(
                                  //       children: [
                                  //         Icon(Icons.check_circle, color: theme.colorScheme.primary),
                                  //         const SizedBox(width: 12),
                                  //         Expanded(
                                  //           child: Text(
                                  //             '${item.getName(currentLang)} ${AppLocalizations.of(context)!.translate('item_added')}',
                                  //             style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white, fontWeight: FontWeight.w600),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     action: SnackBarAction(label: AppLocalizations.of(context)!.translate('undo'), textColor: theme.colorScheme.primary, onPressed: () {}),
                                  //   ),
                                  // );
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.black, // Dark text on primary button
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.translate('add_to_order'),
                          style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (item.imageUrl.isEmpty) {
      return Container(color: const Color(0xFF2A2A2A), child: const Icon(Icons.restaurant, color: Colors.grey, size: 48));
    }

    if (_isBase64(item.imageUrl)) {
      try {
        return Image.memory(base64Decode(item.imageUrl.split(',').last), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildErrorWidget());
      } catch (_) {
        return _buildErrorWidget();
      }
    }

    if (_isLocalFile(item.imageUrl)) {
      return Image.file(File(item.imageUrl), fit: BoxFit.contain, errorBuilder: (_, __, ___) => _buildErrorWidget());
    }

    return CachedNetworkImage(
      imageUrl: item.imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(baseColor: const Color(0xFF1A1A1A), highlightColor: const Color(0xFF2A2A2A), child: Container(color: Colors.white)),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(color: const Color(0xFF2A2A2A), child: const Icon(Icons.broken_image, color: Colors.grey, size: 48));
  }
}
