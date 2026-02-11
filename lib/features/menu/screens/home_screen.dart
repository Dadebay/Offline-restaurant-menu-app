import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:restaurant_menu_app/features/cart/bloc/cart_bloc.dart';
import 'package:restaurant_menu_app/features/cart/bloc/cart_state.dart';
import 'package:restaurant_menu_app/features/cart/screens/order_screen.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_bloc.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_event.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_state.dart';
import 'package:restaurant_menu_app/features/menu/widgets/menu_item_card.dart';
import 'package:restaurant_menu_app/core/localization/app_localizations.dart';
import 'package:restaurant_menu_app/features/language/bloc/language_bloc.dart';
import 'package:restaurant_menu_app/features/settings/screens/login_screen.dart';
import 'package:restaurant_menu_app/features/settings/services/category_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;
  final CategoryService _categoryService = CategoryService();
  Map<String, String> _categoryTranslations = {};

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(LoadMenu());
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryService.getCategories();
    final currentLocale = context.read<LanguageBloc>().state.locale;
    final languageCode = currentLocale.languageCode;

    final Map<String, String> translations = {};
    for (var category in categories) {
      translations[category.nameEn] = category.getName(languageCode);
    }

    if (mounted) {
      setState(() {
        _categoryTranslations = translations;
      });
    }
  }

  String _getTranslatedCategory(String categoryEn) {
    return _categoryTranslations[categoryEn] ?? categoryEn;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LanguageBloc, LanguageState>(
      listener: (context, state) {
        // Reload categories when language changes
        _loadCategories();
      },
      child: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state is MenuLoading) {
            return Scaffold(body: const Center(child: CircularProgressIndicator()));
          } else if (state is MenuError) {
            return Scaffold(body: _buildStatusView(context: context, icon: Icons.error_outline, title: AppLocalizations.of(context)!.translate('error_title'), message: state.message));
          } else if (state is MenuLoaded) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return _buildTabletLayout(context, state);
                } else {
                  return _buildMobileLayout(context, state);
                }
              },
            );
          }
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    );
  }

  // --- Layouts ---

  Widget _buildTabletLayout(BuildContext context, MenuLoaded state) {
    final categories = state.categorizedItems.keys.toList();
    _selectedCategory ??= categories.isNotEmpty ? categories.first : null;
    final items = state.categorizedItems[_selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
          },
          icon: Icon(IconlyLight.setting, color: Colors.transparent),
        ),
        title: Text(
          AppLocalizations.of(context)!.translate('menu'),
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w800, fontFamily: 'Gilroy', fontSize: 28),
        ),
        actions: [
          PopupMenuButton<Locale>(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedLanguageSquare, color: Colors.white, size: 30.0),
            onSelected: (Locale locale) {
              context.read<LanguageBloc>().add(ChangeLanguage(locale));
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<Locale>>[
                  const PopupMenuItem<Locale>(value: Locale('en', 'US'), child: Text('English')),
                  const PopupMenuItem<Locale>(value: Locale('ru', 'RU'), child: Text('Русский')),
                  const PopupMenuItem<Locale>(value: Locale('tk', 'TM'), child: Text('Türkmençe')),
                ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(_getTranslatedCategory(category)),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedCategory = category),
                  showCheckmark: false,
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontFamily: 'Gilroy'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide.none,
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: _buildCartFAB(context),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: CustomScrollView(
          slivers: [
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildStatusView(
                  context: context,
                  icon: Icons.restaurant_menu,
                  title: AppLocalizations.of(context)!.translate('no_items'),
                  message: AppLocalizations.of(context)!.translate('no_items_msg'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 32, crossAxisSpacing: 32, childAspectRatio: 0.7),
                  delegate: SliverChildBuilderDelegate((context, index) => MenuItemCard(item: items[index]), childCount: items.length),
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, MenuLoaded state) {
    final categories = state.categorizedItems.keys.toList();
    _selectedCategory ??= categories.isNotEmpty ? categories.first : null;
    final items = state.categorizedItems[_selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
          },
          icon: Icon(IconlyLight.setting, color: Colors.transparent),
        ),
        title: Text(
          AppLocalizations.of(context)!.translate('menu'),
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w800, fontFamily: 'Gilroy', fontSize: 28),
        ),
        actions: [
          PopupMenuButton<Locale>(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedLanguageSquare, color: Colors.white, size: 30.0),
            onSelected: (Locale locale) {
              context.read<LanguageBloc>().add(ChangeLanguage(locale));
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<Locale>>[
                  const PopupMenuItem<Locale>(value: Locale('en'), child: Text('English')),
                  const PopupMenuItem<Locale>(value: Locale('tk'), child: Text('Türkmen')),
                  const PopupMenuItem<Locale>(value: Locale('ru'), child: Text('Русский')),
                ],
          ),
          SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(_getTranslatedCategory(category)),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedCategory = category),
                  showCheckmark: false,
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontFamily: 'Gilroy'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide.none,
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: _buildCartFAB(context),
      body:
          items.isEmpty
              ? _buildStatusView(
                context: context,
                icon: Icons.restaurant_menu,
                title: AppLocalizations.of(context)!.translate('no_items'),
                message: AppLocalizations.of(context)!.translate('no_items_msg'),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 0.7),
                itemCount: items.length,
                itemBuilder: (context, index) => MenuItemCard(item: items[index]),
              ),
    );
  }

  // --- Components ---

  Widget _buildStatusView({required BuildContext context, required IconData icon, required String title, String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          if (message != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCartFAB(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.totalItems == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8)),
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderScreen())),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  HugeIcon(icon: HugeIcons.strokeRoundedShoppingBasket01, color: Colors.black, size: 32.0),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle, border: Border.all(color: Theme.of(context).primaryColor, width: 2)),
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      child: Center(child: Text('${state.totalItems}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Gilroy'))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
