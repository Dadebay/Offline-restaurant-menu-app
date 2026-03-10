import 'package:restaurant_menu_app/features/settings/services/category_service.dart';
import 'package:restaurant_menu_app/features/menu/services/excel_service.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';

Future<void> generateTestData() async {
  final categoryService = CategoryService();
  final excelService = ExcelService();

  print('🔄 Generating test data...');

  // Create 10 test categories
  final categories = [
    {'ru': 'Закуски', 'tk': 'Täze tagamlar'},
    {'ru': 'Супы', 'tk': 'Çorbalar'},
    {'ru': 'Салаты', 'tk': 'Salatlar'},
    {'ru': 'Основные блюда', 'tk': 'Esasy tagamlar'},
    {'ru': 'Гриль', 'tk': 'Kebaplar'},
    {'ru': 'Десерты', 'tk': 'Suyji tagamlar'},
    {'ru': 'Напитки', 'tk': 'Icgiler'},
    {'ru': 'Пицца', 'tk': 'Pitsa'},
    {'ru': 'Паста', 'tk': 'Makaron'},
    {'ru': 'Морепродукты', 'tk': 'Deniz onumleri'},
  ];

  print('📝 Creating categories...');
  for (var cat in categories) {
    await categoryService.addCategory(nameRu: cat['ru']!, nameTk: cat['tk']!);
    print('✅ Created category: ${cat['ru']}');
  }

  print('\n📝 Creating products...');
  int productCount = 0;

  // For each category, create 10 products
  for (var i = 0; i < categories.length; i++) {
    final categoryName = categories[i]['ru']!;

    for (var j = 1; j <= 10; j++) {
      final item = MenuItem(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + i.toString() + '_' + j.toString(),
        category: categoryName,
        nameRu: '${categories[i]['ru']} Блюдо $j',
        nameTk: '${categories[i]['tk']} $j',
        price: (15 + (i * 5) + j).toDouble(),
        imageUrl: '', // Empty as requested
        available: true,
      );

      await excelService.addMenuItem(item);
      productCount++;
    }
    print('✅ Created 10 products for: $categoryName');
  }

  print('\n🎉 Test data generation complete!');
  print('📊 Total: ${categories.length} categories, $productCount products');
}
