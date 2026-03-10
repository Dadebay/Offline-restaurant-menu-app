import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restaurant_menu_app/core/localization/app_localizations.dart';
import 'package:restaurant_menu_app/features/language/bloc/language_bloc.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_bloc.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_event.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';
import 'package:restaurant_menu_app/features/settings/services/category_service.dart';

class AddProductScreen extends StatefulWidget {
  final MenuItem? itemToEdit;

  const AddProductScreen({super.key, this.itemToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameRuController = TextEditingController();
  final _nameTkController = TextEditingController();
  final _priceController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _categoryService = CategoryService();

  File? _selectedImage;
  bool _available = true;
  bool _isSaving = false;
  List<String> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.itemToEdit != null) {
      final item = widget.itemToEdit!;
      _selectedCategory = item.category;
      _nameRuController.text = item.nameRu;
      _nameTkController.text = item.nameTk;
      _priceController.text = item.price.toString();
      _available = item.available;
    }
  }

  Future<void> _loadCategories() async {
    final currentLang = context.read<LanguageBloc>().state.locale.languageCode;
    final labels = await _categoryService.getCategoryNames(currentLang);

    setState(() {
      _categories = labels;
      if (_categories.isNotEmpty && (_selectedCategory == null || !_categories.contains(_selectedCategory))) {
        _selectedCategory = _categories.first;
      }
    });
  }

  @override
  void dispose() {
    _nameRuController.dispose();
    _nameTkController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      PermissionStatus status;
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        status = await Permission.photos.request();
      }

      if (!status.isGranted && !status.isLimited) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('permission_denied')),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.translate('settings'),
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      }

      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.translate('error')}$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSourceOption(Icons.photo_library, AppLocalizations.of(context)!.translate('gallery'), () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              }),
              _buildSourceOption(Icons.camera_alt, AppLocalizations.of(context)!.translate('camera'), () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceOption(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onTap,
          icon: Icon(icon, size: 32, color: const Color(0xFFFFB74D)),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.05),
            padding: const EdgeInsets.all(20),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Future<String> _processImageToBase64(File image) async {
    final bytes = await image.readAsBytes();
    final compressedBytes = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 720,
      minHeight: 720,
      quality: 65,
      format: CompressFormat.jpeg,
    );
    return 'data:image/jpeg;base64,${base64Encode(compressedBytes)}';
  }

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.itemToEdit == null && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('select_image')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _processImageToBase64(_selectedImage!);
      } else {
        imageUrl = widget.itemToEdit!.imageUrl;
      }

      final menuItem = MenuItem(
        id: widget.itemToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        category: _selectedCategory!,
        nameRu: _nameRuController.text.trim(),
        nameTk: _nameTkController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: imageUrl,
        available: _available,
      );

      if (!mounted) return;

      if (widget.itemToEdit != null) {
        context.read<MenuBloc>().add(UpdateMenuItem(menuItem));
      } else {
        context.read<MenuBloc>().add(AddMenuItem(menuItem));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.itemToEdit != null ? 'Product updated successfully' : AppLocalizations.of(context)!.translate('delicacy_added'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.translate('error')}$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.itemToEdit != null ? 'Edit Product' : AppLocalizations.of(context)!.translate('new_delicacy'),
          style: const TextStyle(
            fontFamily: 'Gilroy',
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : (widget.itemToEdit != null && widget.itemToEdit!.imageUrl.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: _buildExistingImage(widget.itemToEdit!.imageUrl),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 32,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  AppLocalizations.of(context)!.translate('add_photo'),
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.translate('category_label'),
                    labelStyle: const TextStyle(color: Colors.white60, fontFamily: 'Gilroy'),
                    border: InputBorder.none,
                    icon: Icon(Icons.category_outlined, color: theme.colorScheme.primary),
                  ),
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white, fontFamily: 'Gilroy', fontSize: 16),
                  hint: Text(
                    AppLocalizations.of(context)!.translate('category_hint'),
                    style: const TextStyle(color: Colors.white38, fontFamily: 'Gilroy'),
                  ),
                  items: _categories.map((category) => DropdownMenuItem<String>(value: category, child: Text(category))).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  validator: (value) => value == null || value.isEmpty ? 'Please select a category' : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.translate('dish_name_label'),
                style: const TextStyle(
                  fontFamily: 'Gilroy',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildGlassInput(
                controller: _nameRuController,
                label: '🇷🇺 Русское название',
                icon: Icons.restaurant_outlined,
                hint: 'Пицца Маргарита',
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildGlassInput(
                controller: _nameTkController,
                label: '🇹🇲 Türkmen ady',
                icon: Icons.restaurant_outlined,
                hint: 'Pitsa Margarita',
                theme: theme,
              ),
              const SizedBox(height: 20),
              _buildGlassInput(
                controller: _priceController,
                label: AppLocalizations.of(context)!.translate('price_label'),
                icon: Icons.payments_outlined,
                hint: '0.00',
                suffix: ' TKM',
                isNumeric: true,
                theme: theme,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: SwitchListTile(
                  title: Text(
                    AppLocalizations.of(context)!.translate('available_label'),
                    style: const TextStyle(
                      fontFamily: 'Gilroy',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  value: _available,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (value) => setState(() => _available = value),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveMenuItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                        )
                      : Text(
                          AppLocalizations.of(context)!.translate('save_to_menu'),
                          style: const TextStyle(
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    String? hint,
    String? suffix,
    int maxLines = 1,
    bool isNumeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Gilroy',
              color: Color(0xFFFFB74D),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : null,
            style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontFamily: 'Gilroy', color: Colors.white.withOpacity(0.3)),
              prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.3)),
              suffixText: suffix,
              suffixStyle: TextStyle(
                fontFamily: 'Gilroy',
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context)!.translate('required_field');
              }
              if (isNumeric && (double.tryParse(value.trim()) ?? 0) <= 0) {
                return AppLocalizations.of(context)!.translate('invalid_price');
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  bool _isBase64(String path) => path.startsWith('data:image');
  bool _isLocalFile(String path) => path.startsWith('/') || path.startsWith('file://');

  Widget _buildExistingImage(String imageUrl) {
    if (_isBase64(imageUrl)) {
      try {
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        );
      } catch (_) {
        return _buildImagePlaceholder();
      }
    }
    if (_isLocalFile(imageUrl)) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(child: Icon(Icons.restaurant, color: Colors.grey, size: 40)),
    );
  }
}
