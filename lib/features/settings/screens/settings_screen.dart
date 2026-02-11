import 'dart:io';
import 'package:flutter/material.dart';
import 'package:restaurant_menu_app/core/localization/app_localizations.dart';
import 'package:restaurant_menu_app/features/settings/screens/product_management_screen.dart';
import 'package:restaurant_menu_app/features/settings/screens/category_management_screen.dart';
import 'package:restaurant_menu_app/features/settings/screens/change_password_screen.dart';
import 'package:restaurant_menu_app/test_data_generator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_bloc.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_event.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_state.dart';
import 'package:restaurant_menu_app/features/cart/screens/order_history_screen.dart';
import 'package:restaurant_menu_app/features/settings/services/category_service.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final CategoryService _categoryService = CategoryService();

  @override
  Widget build(BuildContext context) {
    return BlocListener<MenuBloc, MenuState>(
      listener: (context, state) {
        if (state is MenuExportSuccess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.translate('export_success')}\n${state.filePath}', style: const TextStyle(fontFamily: 'Gilroy')),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Automatically share the file
          Future.delayed(const Duration(milliseconds: 500), () {
            final file = File(state.filePath);
            if (file.existsSync()) {
              Share.shareXFiles([XFile(state.filePath)], subject: 'Restaurant Menu Data', text: 'Restaurant menu export - ${DateTime.now().toString().split(' ')[0]}');
            }
          });
        } else if (state is MenuImportSuccess) {
          // Import categories
          _categoryService.importCategories(state.categories.cast());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppLocalizations.of(context)!.translate('import_success')}\n${state.items.length} ${AppLocalizations.of(context)!.translate('products')}, ${state.categories.length} ${AppLocalizations.of(context)!.translate('categories')}',
                style: const TextStyle(fontFamily: 'Gilroy'),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is MenuError && (state.message.contains('export') || state.message.contains('import') || state.message.contains('Import'))) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Gilroy')), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.translate('settings'))),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Management
            _buildSettingCard(
              icon: Icons.inventory,
              title: AppLocalizations.of(context)!.translate('product_management'),
              subtitle: AppLocalizations.of(context)!.translate('manage_products_desc'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagementScreen()));
              },
            ),
            const SizedBox(height: 16),

            // Category Management
            _buildSettingCard(
              icon: Icons.category,
              title: AppLocalizations.of(context)!.translate('category_management'),
              subtitle: AppLocalizations.of(context)!.translate('manage_categories_desc'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryManagementScreen()));
              },
            ),
            const SizedBox(height: 16),

            // Export to Excel
            _buildSettingCard(
              icon: Icons.upload_file,
              title: AppLocalizations.of(context)!.translate('export_excel'),
              subtitle: AppLocalizations.of(context)!.translate('export_excel_desc'),
              onTap: () async {
                final categories = await _categoryService.getCategories();
                context.read<MenuBloc>().add(ExportToExcel(categories));
              },
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            // Import from Excel
            _buildSettingCard(
              icon: Icons.download,
              title: AppLocalizations.of(context)!.translate('import_excel'),
              subtitle: AppLocalizations.of(context)!.translate('import_excel_desc'),
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (dialogContext) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.translate('import_excel')),
                        content: Text(AppLocalizations.of(context)!.translate('import_warning'), style: const TextStyle(fontFamily: 'Gilroy')),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(AppLocalizations.of(context)!.translate('cancel'))),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              context.read<MenuBloc>().add(const ImportFromExcel());
                            },
                            child: Text(AppLocalizations.of(context)!.translate('import'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                );
              },
              color: Colors.green,
            ),
            const SizedBox(height: 16),

            // Order History
            _buildSettingCard(
              icon: Icons.receipt_long,
              title: AppLocalizations.of(context)!.translate('order_history'),
              subtitle: AppLocalizations.of(context)!.translate('order_history_desc'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
              },
            ),
            const SizedBox(height: 16),

            // Generate Test Data
            _buildSettingCard(
              icon: Icons.data_array,
              title: 'Generate Test Data',
              subtitle: 'Add 10 categories with 10 products each',
              onTap: () async {
                // Show loading dialog
                showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

                try {
                  await generateTestData();
                  Navigator.pop(context); // Close loading dialog

                  // Reload menu
                  context.read<MenuBloc>().add(LoadMenu());

                  // Show success
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Test data generated: 10 categories, 100 products'), backgroundColor: Colors.green));
                } catch (e) {
                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red));
                }
              },
              color: Colors.orange,
            ),
            const SizedBox(height: 16),

            // Change Password
            _buildSettingCard(
              icon: Icons.lock,
              title: AppLocalizations.of(context)!.translate('change_password'),
              subtitle: AppLocalizations.of(context)!.translate('change_password_desc'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
              },
            ),
            const SizedBox(height: 16),

            // Logout
            _buildSettingCard(
              icon: Icons.exit_to_app,
              title: AppLocalizations.of(context)!.translate('logout'),
              subtitle: AppLocalizations.of(context)!.translate('logout_desc'),
              onTap: () {
                Navigator.pop(context);
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, Color? color}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color ?? Theme.of(context).primaryColor, size: 32),
        title: Text(title, style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Gilroy', fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
